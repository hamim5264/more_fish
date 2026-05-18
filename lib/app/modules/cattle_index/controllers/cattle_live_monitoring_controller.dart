import 'dart:async';
import 'package:get/get.dart';
import '../../../repo/cattle_live_repo.dart';
import '../../../response/cattle_farm_list_response.dart';
import '../../../response/cattle_farrm_dashboard_response.dart';
import 'cattle_header_controller.dart';

class CattleLiveMonitoringController extends GetxController {
  final CattleLiveDataRepository cattleLiveDataRepository =
      CattleLiveDataRepository();

  final cattleFarmListResponse = Rxn<CattleFarmListResponse>();
  final cattleFarmDashboardResponse = Rxn<CattleFarmDashboardResponse>();

  final selectedDeviceId = ''.obs;
  final isLoading = false.obs;
  final error = ''.obs;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    fetchFarmList();
    _startBackgroundRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _startBackgroundRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (selectedDeviceId.value.isNotEmpty) {
        refreshLiveData(showLoader: false);
      }
    });
  }

  Future<void> fetchFarmList() async {
    if (cattleFarmListResponse.value == null) {
      isLoading.value = true;
    }
    error.value = '';
    var response = await cattleLiveDataRepository.getFarmList();
    response.fold(
      (l) {
        isLoading.value = false;
        error.value = l.message;
      },
      (r) {
        cattleFarmListResponse.value = r;
        if (r.data != null && r.data!.isNotEmpty) {
          final firstFarmId = r.data![0].id.toString();
          selectedDeviceId.value = firstFarmId;
          fetchFarmDashboard(id: firstFarmId);
        } else {
          isLoading.value = false;
        }
      },
    );
  }

  Future<void> fetchFarmDashboard({
    required String id,
    bool showLoader = true,
  }) async {
    if (showLoader && cattleFarmDashboardResponse.value == null) {
      isLoading.value = true;
    }
    error.value = '';
    var response = await cattleLiveDataRepository.getFarmDashboard(id: id);
    response.fold(
      (l) {
        error.value = l.message;
      },
      (r) {
        cattleFarmDashboardResponse.value = r;
        if (Get.isRegistered<CattleHeaderController>()) {
          Get.find<CattleHeaderController>().updateFromDashboard(
            r.data?.weather,
          );
        }
      },
    );
    isLoading.value = false;
  }

  Future<void> onDeviceChanged(String id) async {
    selectedDeviceId.value = id;
    cattleFarmDashboardResponse.value = null;
    await fetchFarmDashboard(id: id);
  }

  Future<void> refreshLiveData({bool showLoader = true}) async {
    if (selectedDeviceId.value.isNotEmpty) {
      await fetchFarmDashboard(
        id: selectedDeviceId.value,
        showLoader: showLoader,
      );
    } else {
      // ✅ If we don't have a device yet (maybe initial load failed), try farm list again
      await fetchFarmList();
    }
  }

  Future<void> toggleSwitch(String switchId, bool turnOn) async {
    var result = await cattleLiveDataRepository.setSwitchState(
      switchId: switchId,
      turnOn: turnOn,
    );
    result.fold(
      (l) {
        Get.snackbar("Error", l.message, snackPosition: SnackPosition.BOTTOM);
      },
      (r) {
        refreshLiveData(showLoader: false);
      },
    );
  }

  Sensor? getSensor(String name) {
    final sensors = cattleFarmDashboardResponse.value?.data?.device?.sensors;
    if (sensors == null) return null;
    try {
      return sensors.firstWhere(
        (s) => s.name?.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
