import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../repo/devices_repo.dart';
import '../../../response/pond_data_response.dart';

class AeratorConnectionController extends GetxController {
  static const String _cacheSelectedAstIdKey = 'morefish_selected_ast_id';

  final DevicesRepository devicesRepository = DevicesRepository();

  final pondDataResponse = Rxn<PondDataResponse>();
  final aerators = <Aerator>[].obs;
  final selectedAssetId = 0.obs;
  final isLoading = false.obs;

  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedAssetId().then((_) {
      _fetchAeratorData();
      _startPolling();
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _fetchAeratorData(silent: true);
    });
  }

  Future<void> _loadSelectedAssetId() async {
    final args = Get.arguments;
    if (args is Map && args['assetId'] != null) {
      selectedAssetId.value = _parseAssetId(args['assetId']);
      if (selectedAssetId.value != 0) return;
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedAssetId = prefs.getInt(_cacheSelectedAstIdKey);
    if (cachedAssetId != null && cachedAssetId > 0) {
      selectedAssetId.value = cachedAssetId;
      return;
    }

    selectedAssetId.value = 62;
  }

  Future<void> _fetchAeratorData({bool silent = false}) async {
    if (selectedAssetId.value == 0) {
      await _loadSelectedAssetId();
    }

    if (selectedAssetId.value == 0) return;

    if (!silent) {
      isLoading.value = true;
    }

    final response = await devicesRepository.getPondData(
      id: selectedAssetId.value,
    );

    response.fold(
      (failure) {
        debugPrint(
          '[AeratorConnection] getPondData failed -> ${failure.message}',
        );
        if (!silent) {
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        isLoading.value = false;
      },
      (pondResponse) {
        pondDataResponse.value = pondResponse;
        aerators.assignAll(_extractAerators(pondResponse));
        isLoading.value = false;
      },
    );
  }

  Future<void> forceRefresh() async {
    await _fetchAeratorData();
  }

  List<Aerator> _extractAerators(PondDataResponse response) {
    if (response.data.devices.isEmpty) {
      return <Aerator>[];
    }

    return response.data.devices
        .expand((device) => device.aerators)
        .toList(growable: false);
  }

  int _parseAssetId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
