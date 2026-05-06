import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Timer? _aeratorPollTimer;
  var isFetching = false.obs;
  var commandInProgress = false.obs;
  bool _firstFetch = true;

  var aeratorIds = <int>[].obs;

  static const String _cacheAeratorKey = 'morefish_aerator_cache';

  static const String _cachePondListKey = 'morefish_pond_list_cache';
  static const String _cachePondDataKey = 'morefish_pond_data_cache';
  static const String _cacheSensorListKey = 'morefish_sensor_list_cache';
  static const String _cacheCompanyListKey = 'morefish_company_list_cache';
  static const String _cacheSelectedAstIdKey = 'morefish_selected_ast_id';
  static const String _cacheSelectedAstNameKey = 'morefish_selected_ast_name';

  @override
  void onInit() {
    super.onInit();
    debugPrint('[WaterQuality] onInit -> pondList + companyList + polling');
    _loadCachedState();
    pondList();
    CompanyList();
    _startPolling();
    _startAeratorPolling();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _aeratorPollTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    debugPrint('[WaterQuality] Polling started (every 1 minute)');
    _pollTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (isFetching.value) return;
      if (selectedAstId.value == 0) return;

      debugPrint('[poll] Polling pond data for id: ${selectedAstId.value}');
      pondData(id: selectedAstId.value);
    });
  }

  void _startAeratorPolling() {
    debugPrint('[WaterQuality] Aerator polling started (every 2 seconds)');
    _aeratorPollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // Conditions: we have a selected asset and we have known aerator ids
      if (selectedAstId.value == 0) return;
      if (aeratorIds.isEmpty) return; // don't change UI shape after first fetch
      _pollAeratorState();
    });
  }

  void _pollAeratorState() async {
    try {
      // lightweight: fetch pond data but only update isRunning flags
      var response = await devicesRepository.getPondData(
        id: selectedAstId.value,
      );
      response.fold(
        (l) {
          // ignore errors for polling
        },
        (r) {
          try {
            final aerators = r.data.devices[0].aerators;
            for (int i = 0; i < aerators.length; i++) {
              final pk = aerators[i].aeratorPk;
              final idx = aeratorIds.indexOf(pk);
              if (idx >= 0) {
                // update existing switch state only
                aeratorSwitch[idx] = aerators[i].isRunning;
              } else {
                // new aerator discovered after first fetch: cache but do not add to UI
                _cacheSingleAerator(pk, aerators[i].isRunning);
              }
            }
          } catch (_) {}
        },
      );
    } catch (_) {}
  }

  pondList() async {
    debugPrint('[API] getPondList() requested');
    var response = await devicesRepository.getPondList();
    response.fold((l) => print("${l.message}"), (r) {
      debugPrint('[API] getPondList() success -> ponds: ${r.data.length}');
      pondListResponse.value = r;
      _cachePondList(r);
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
    _cacheSelectedAstId(selectedAstId.value);

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
        _cachePondData(r);

        // Reset and populate aerator switches from fresh API data
        final aerators = r.data.devices[0].aerators;
        if (_firstFetch) {
          aeratorIds.clear();
          aeratorSwitch.clear();
          for (int i = 0; i < aerators.length; i++) {
            aeratorIds.add(aerators[i].aeratorPk);
            aeratorSwitch.add(aerators[i].isRunning);
          }
          // Cache discovered aerators so we remember them between app launches
          _cacheAeratorListFromData(aerators);
        } else {
          // After initial load we DO NOT change the number of switches in the UI.
          // Only update the `is_running` state for known aerators. New aerators
          // are cached but not added to the UI to avoid layout shifts.
          for (int i = 0; i < aerators.length; i++) {
            final pk = aerators[i].aeratorPk;
            final idx = aeratorIds.indexOf(pk);
            if (idx >= 0) {
              aeratorSwitch[idx] = aerators[i].isRunning;
            } else {
              _cacheSingleAerator(pk, aerators[i].isRunning);
            }
          }
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
        _cacheSensorList(r);
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
        _cacheCompanyList(r);
      },
    );
  }

  Future<void> selectAsset({required String name, required int id}) async {
    selectedAstName.value = name;
    selectedAstId.value = id;
    await _cacheSelectedAstId(id);
    await _cacheSelectedAstName(name);
    pondData(id: id);
  }

  Future<void> _loadCachedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cachedPondList = prefs.getString(_cachePondListKey);
      if (cachedPondList != null && cachedPondList.isNotEmpty) {
        pondListResponse.value = PondListResponse.fromRawJson(cachedPondList);
      }

      final cachedPondData = prefs.getString(_cachePondDataKey);
      if (cachedPondData != null && cachedPondData.isNotEmpty) {
        pondDataResponse.value = PondDataResponse.fromRawJson(cachedPondData);
        aeratorSwitch.clear();
      }

      final cachedSensorList = prefs.getString(_cacheSensorListKey);
      if (cachedSensorList != null && cachedSensorList.isNotEmpty) {
        sensorListResponse.value = SensorListResponse.fromRawJson(
          cachedSensorList,
        );
      }

      final cachedCompanyList = prefs.getString(_cacheCompanyListKey);
      if (cachedCompanyList != null && cachedCompanyList.isNotEmpty) {
        companyListResponse.value = CompanyListResponse.fromRawJson(
          cachedCompanyList,
        );
      }

      final cachedAstId = prefs.getInt(_cacheSelectedAstIdKey);
      if (cachedAstId != null) {
        selectedAstId.value = cachedAstId;
      }

      final cachedAstName = prefs.getString(_cacheSelectedAstNameKey);
      if (cachedAstName != null && cachedAstName.isNotEmpty) {
        selectedAstName.value = cachedAstName;
      }

      // Load cached aerator states (if any). This populates the local arrays so
      // the UI can show cached switch states before the first full fetch.
      final cachedAerator = prefs.getString(_cacheAeratorKey);
      if (cachedAerator != null && cachedAerator.isNotEmpty) {
        try {
          final Map<String, dynamic> m = jsonDecode(cachedAerator);
          aeratorIds.clear();
          aeratorSwitch.clear();
          m.forEach((k, v) {
            final pk = int.tryParse(k) ?? 0;
            if (pk != 0) {
              aeratorIds.add(pk);
              aeratorSwitch.add(v == true);
            }
          });
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _cachePondList(PondListResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachePondListKey, response.toRawJson());
  }

  Future<void> _cachePondData(PondDataResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _stripAerators(response);
    await prefs.setString(_cachePondDataKey, jsonEncode(payload));
  }

  Future<void> _cacheSensorList(SensorListResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheSensorListKey, response.toRawJson());
  }

  Future<void> _cacheAeratorListFromData(List aerators) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> m = {};
      for (final a in aerators) {
        try {
          final pk = a.aeratorPk;
          m[pk.toString()] = a.isRunning;
        } catch (_) {}
      }
      await prefs.setString(_cacheAeratorKey, jsonEncode(m));
    } catch (_) {}
  }

  Future<void> _cacheSingleAerator(int pk, bool isRunning) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_cacheAeratorKey);
      Map<String, dynamic> m = {};
      if (existing != null && existing.isNotEmpty) {
        try {
          m = Map<String, dynamic>.from(jsonDecode(existing));
        } catch (_) {}
      }
      m[pk.toString()] = isRunning;
      await prefs.setString(_cacheAeratorKey, jsonEncode(m));
    } catch (_) {}
  }

  Future<void> _cacheCompanyList(CompanyListResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheCompanyListKey, response.toRawJson());
  }

  Future<void> _cacheSelectedAstId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheSelectedAstIdKey, id);
  }

  Future<void> _cacheSelectedAstName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheSelectedAstNameKey, name.trim());
  }

  Map<String, dynamic> _stripAerators(PondDataResponse response) {
    final payload = response.toJson();
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      final devices = data['devices'];
      if (devices is List) {
        for (final device in devices) {
          if (device is Map<String, dynamic>) {
            device['aerators'] = <dynamic>[];
          }
        }
      }
    }
    return payload;
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
//