import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../repo/devices_repo.dart';
import '../../../response/aerator_command_response.dart';
import '../../../response/company_list_response.dart';
import '../../../response/pond_data_response.dart';
import '../../../response/pond_list_response.dart';
import '../../../response/sensor_list_response.dart';

class WaterQualityDeviceController extends GetxController {
  DevicesRepository devicesRepository = DevicesRepository();

  var pondListResponse = Rxn<PondListResponse>();
  var pondDataResponse = Rxn<PondDataResponse>();
  var sensorListResponse = Rxn<SensorListResponse>();
  var companyListResponse = Rxn<CompanyListResponse>();
  var aeratorCommandResponse = Rxn<AeratorCommandResponse>();

  var aeratorSwitch = [].obs;
  var selectedAstName = ''.obs;
  var selectedAstId = 0.obs;
  var comId = 19.obs;

  Timer? _pollTimer;
  var isFetching = false.obs;
  var commandInProgress = false.obs;
  bool _firstFetch = true;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[WaterQuality] onInit -> pondList + companyList + polling');
    pondList();
    CompanyList();
    _startPolling();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    debugPrint('[WaterQuality] Polling started (every 1 second)');
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isFetching.value) return;
      if (selectedAstId.value == 0) return;

      debugPrint('[poll] Polling pond data for id: ${selectedAstId.value}');
      pondData(id: selectedAstId.value);
    });
  }

  pondList() async {
    debugPrint('[API] getPondList() requested');
    var response = await devicesRepository.getPondList();
    response.fold((l) => print("${l.message}"), (r) {
      debugPrint('[API] getPondList() success -> ponds: ${r.data.length}');
      pondListResponse.value = r;
      if (r.data.isNotEmpty) {
        debugPrint('[Flow] First pond selected -> id: ${r.data[0].id}');
        pondData(id: r.data[0].id);
      }
    });
  }

  pondData({id}) async {
    if (isFetching.value) return;
    isFetching.value = true;

    // loader removed

    if (id != null) selectedAstId.value = id;

    debugPrint('[API] getPondData() requested -> asset_id: $id');
    var response = await devicesRepository.getPondData(id: id);
    response.fold(
      (l) {
        debugPrint('[API] getPondData() failed -> ${l.message}');
        print("${l.message}");
        isFetching.value = false;
        _firstFetch = false;
      },
      (r) {
        debugPrint('[API] getPondData() success');
        pondDataResponse.value = r;

        // Reset and populate aerator switches from fresh API data
        aeratorSwitch.clear();
        final aerators = r.data.devices[0].aerators;
        for (int i = 0; i < aerators.length; i++) {
          aeratorSwitch.add(aerators[i].isRunning);
        }

        // Fetch sensor list for graph
        try {
          final deviceId = r.data.devices[0].deviceId;
          if (deviceId != null && deviceId.toString().isNotEmpty) {
            debugPrint('[Flow] sensorList() triggered -> device_id: $deviceId');
            sensorList(deviceId: deviceId);
          }
        } catch (e) {
          debugPrint('Failed to extract device id: $e');
        }

        isFetching.value = false;
        _firstFetch = false;
      },
    );
  }

  sensorList({dynamic deviceId}) async {
    if (deviceId == null) return;
    debugPrint('[API] getSensorList() requested -> device_id: $deviceId');
    var response = await devicesRepository.getSensorList(deviceId: deviceId);
    response.fold(
      (l) {
        debugPrint('[API] getSensorList() failed -> ${l.message}');
        print("${l.message}");
      },
      (r) {
        debugPrint('[API] getSensorList() success');
        sensorListResponse.value = r;
      },
    );
  }

  CompanyList() async {
    debugPrint('[API] getCompanyList() requested');
    var response = await devicesRepository.getCompanyList();
    response.fold(
      (l) {
        debugPrint('[API] getCompanyList() failed -> ${l.message}');
        print("${l.message}");
      },
      (r) {
        debugPrint(
          '[API] getCompanyList() success -> companies: ${r.data?.length}',
        );
        companyListResponse.value = r;
      },
    );
  }

  // ==================== UPDATED AERATOR COMMAND ====================
  aeratorCommand({id, command, int? index}) async {
    if (commandInProgress.value) return;

    commandInProgress.value = true;

    // loader removed

    debugPrint(
      '[API] setAeratorCommand() requested -> id: $id, command: $command',
    );
    var response = await devicesRepository.setAeratorCommand(
      id: id,
      command: command,
    );

    response.fold(
      (l) {
        // Error case (e.g. "it is not connected", device offline, etc.)
        String errorMsg = l.message;
        debugPrint('[API] setAeratorCommand() failed -> $errorMsg');

        try {
          Get.snackbar('Error', errorMsg, snackPosition: SnackPosition.BOTTOM);
        } catch (_) {}

        // No optimistic update, so no need to revert switch
        commandInProgress.value = false;
      },
      (r) {
        // Success case
        debugPrint('[API] setAeratorCommand() success -> ${r.msg}');
        aeratorCommandResponse.value = r;

        try {
          Get.snackbar(
            'Success',
            r.msg ?? 'Command sent successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (_) {}

        // Refresh pond data to get latest is_running state from server
        pondData(id: selectedAstId.value);
        commandInProgress.value = false;
      },
    );
  }
}
