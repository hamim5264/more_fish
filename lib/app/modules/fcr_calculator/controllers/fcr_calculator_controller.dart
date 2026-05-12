import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../repo/devices_repo.dart';
import '../../../service/local_storage.dart';
import '../../../service/service.dart';

class FcrCalculatorController extends GetxController {
  final feedAmountController = TextEditingController();
  final weightGainController = TextEditingController();

  final DevicesRepository _devicesRepository = DevicesRepository();
  final LoginTokenStorage _loginTokenStorage = Get.find<LoginTokenStorage>();

  final assetId = RxnInt();
  final fcrResult = RxnDouble();
  final validationMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAssetId();
  }

  Future<void> _loadAssetId() async {
    final result = await _devicesRepository.getPondList();
    result.fold(
      (failure) {
        assetId.value = null;
        validationMessage.value = failure.message;
      },
      (pondList) {
        if (pondList.data.isEmpty) {
          assetId.value = null;
          validationMessage.value = 'No assets found for this account.';
          return;
        }

        assetId.value = pondList.data.first.id;
      },
    );
  }

  Future<void> calculateFcr() async {
    final feedAmount = double.tryParse(feedAmountController.text.trim());
    final weightGain = double.tryParse(weightGainController.text.trim());

    if (feedAmount == null || weightGain == null) {
      validationMessage.value = 'Enter valid numeric values.';
      fcrResult.value = null;
      return;
    }

    if (feedAmount <= 0 || weightGain <= 0) {
      validationMessage.value = 'Values must be greater than zero.';
      fcrResult.value = null;
      return;
    }

    final selectedAssetId = assetId.value;
    if (selectedAssetId == null) {
      validationMessage.value = 'Asset not available for calculation.';
      fcrResult.value = null;
      return;
    }

    final token = _loginTokenStorage.getMoreFishToken();
    if (token == null || token.isEmpty) {
      validationMessage.value = 'Missing authorization token.';
      fcrResult.value = null;
      return;
    }

    validationMessage.value = '';

    try {
      final request = http.Request(
        'POST',
        Uri.parse("${ApiService.baseUrl}/devices/fcr/calculate/"),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      request.body = jsonEncode({
        'asset_id': selectedAssetId,
        'feed_weight_kg': feedAmount,
        'weight_gained_kg': weightGain,
        'notes': 'Optional label',
      });

      final response = await request.send();
      final rawBody = await response.stream.bytesToString();
      debugPrint('FCR API status: ${response.statusCode}');
      debugPrint('FCR API body: $rawBody');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(rawBody);
        final data = decoded is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>?
            : null;
        final fcrValue = data?['fcr'];

        if (fcrValue is num) {
          fcrResult.value = fcrValue.toDouble();
          return;
        }

        fcrResult.value = null;
        validationMessage.value = 'FCR value missing in response.';
        return;
      }

      fcrResult.value = null;
      validationMessage.value =
          'FCR calculation failed with status: ${response.statusCode}.';
    } catch (e) {
      fcrResult.value = null;
      validationMessage.value = 'Error: $e';
    }
  }

  void clearAll() {
    feedAmountController.clear();
    weightGainController.clear();
    validationMessage.value = '';
    fcrResult.value = null;
  }

  @override
  void onClose() {
    feedAmountController.dispose();
    weightGainController.dispose();
    super.onClose();
  }
}
