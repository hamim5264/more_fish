import 'dart:async';

import 'package:flutter/widgets.dart';
// loader removed
import 'package:get/get.dart';
import '../../../repo/poultry_api_live_repo.dart';
import '../../../repo/poultry_live_models.dart';
import '../../../repo/poultry_live_repo.dart';
import '../../../routes/app_pages.dart';
import '../../../service/local_storage.dart';

class PoultryLiveMonitoringController extends GetxController
    with WidgetsBindingObserver {
  PoultryLiveMonitoringController({PoultryLiveRepository? repository})
    : _repo = repository ?? PoultryApiLiveRepository();

  final PoultryLiveRepository _repo;

  final devices = <PoultryDevice>[].obs;
  final selectedDeviceId = ''.obs;

  final liveData = Rxn<PoultryLiveData>();
  final isLoading = false.obs;
  final error = ''.obs;

  final switchBusy = <String, bool>{}.obs;
  final switchUiState = <String, bool>{}.obs;

  Timer? _pollTimer;
  bool _isRefreshInProgress = false;
  DateTime? _lastPageVisibleRefreshAt;

  static const Duration _refreshInterval = Duration(seconds: 1);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (selectedDeviceId.value.isNotEmpty) {
        refreshLiveData();
        _startPolling();
      }
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _pollTimer?.cancel();
    }
  }

  Future<void> loadDevices() async {
    final showOverlay = liveData.value == null;

    try {
      isLoading.value = true;
      error.value = '';

      final list = await _repo.getDevices();
      devices.assignAll(list);

      if (list.isNotEmpty) {
        switchUiState.clear();
        selectedDeviceId.value = list.first.id;
        await refreshLiveData();
        _startPolling();
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _bootstrap() async {
    final canProceed = await _ensureLoggedIn();
    if (!canProceed) {
      if (Get.isOverlaysOpen != true) Get.back();
      return;
    }
    await loadDevices();
  }

  Future<bool> _ensureLoggedIn() async {
    final loginTokenStorage = Get.find<LoginTokenStorage>();

    if (loginTokenStorage.hasValidPoultryToken()) {
      return true;
    }

    final result = await Get.toNamed(
      Routes.POULTRY_LOGIN,
      arguments: {'fromGuard': true},
    );

    final nextToken = loginTokenStorage.getPoultryToken();
    return result == true || _hasValidToken(nextToken);
  }

  bool _hasValidToken(String? token) {
    if (token == null) return false;
    final n = token.trim().toLowerCase();
    return n.isNotEmpty && n != 'null' && n != 'undefined';
  }

  Future<void> onDeviceChanged(String deviceId) async {
    switchUiState.clear();
    selectedDeviceId.value = deviceId;
    await refreshLiveData();
    _startPolling();
  }

  Future<void> refreshWhenPageVisible() async {
    final now = DateTime.now();
    final last = _lastPageVisibleRefreshAt;

    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      return;
    }

    _lastPageVisibleRefreshAt = now;

    if (selectedDeviceId.value.isEmpty || devices.isEmpty) {
      await loadDevices();
      return;
    }

    await refreshLiveData();
    _startPolling();
  }

  Future<void> refreshLiveData({bool silent = false}) async {
    if (_isRefreshInProgress) return;

    final id = selectedDeviceId.value;
    if (id.isEmpty) return;

    _isRefreshInProgress = true;

    try {
      if (!silent) {
        isLoading.value = true;
      }
      error.value = '';

      liveData.value = await _repo.getLatestLiveData(deviceId: id);
      _syncSwitchUiStateWithLiveData();
    } catch (e) {
      error.value = e.toString();
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
      _isRefreshInProgress = false;
    }
  }

  void openSensorGraph(PoultrySensorMetric metric) {
    final farmId = int.tryParse(selectedDeviceId.value.trim());

    if (farmId == null) {
      Get.snackbar(
        'Error',
        'Invalid farm selected',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      Routes.GRAPH,
      arguments: {
        'flow': 'poultry',
        'farmId': farmId,
        'sensorKey': metric.name,
        'sensorName': metric.title,
        'unit': metric.unit,
        'type': 'daily',
      },
    );
  }

  // =========================
  // ✅ UPDATED SWITCH METHOD
  // =========================
  Future<void> onSwitchChanged({
    required PoultrySwitch item,
    required bool nextValue,
  }) async {
    if (item.switchId.trim().isEmpty) return;

    final busy = switchBusy[item.switchId] ?? false;
    if (busy) return;

    switchBusy[item.switchId] = true;

    try {
      final loadingText = nextValue
          ? 'The switch is turning on'
          : 'The switch is turning off';
      // loader removed

      debugPrint(
        'Switch POST: ${item.switchId} -> ${nextValue ? "ON" : "OFF"}',
      );

      /// STEP 1: POST to backend
      await _repo.setSwitchState(switchId: item.switchId, turnOn: nextValue);

      /// STEP 2: wait + refresh
      await Future.delayed(const Duration(seconds: 2));
      await refreshLiveData(silent: true);

      // loader removed
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update switch',
        snackPosition: SnackPosition.BOTTOM,
      );
      await refreshLiveData(silent: true);
    } finally {
      switchBusy[item.switchId] = false;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();

    _pollTimer = Timer.periodic(_refreshInterval, (_) {
      // Poll dashboard every second to keep switch states updated.
      refreshLiveData(silent: true);
    });
  }

  void _syncSwitchUiStateWithLiveData() {
    final switches = liveData.value?.switches ?? const <PoultrySwitch>[];
    if (switches.isEmpty) {
      switchUiState.clear();
      return;
    }

    final nextState = <String, bool>{};
    for (final sw in switches) {
      nextState[sw.switchId] = sw.isOn;
    }
    switchUiState.assignAll(nextState);
  }
}
