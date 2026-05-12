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

class CleanAirLiveMonitoringController extends GetxController {
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
  var busyAeratorPks = <int>{}.obs;
  bool _firstFetch = true;

  var aeratorIds = <int>[].obs;

  String get cachePrefix => 'pharma';

  String get _cacheAeratorKey => '${cachePrefix}_aerator_cache';

  String get _cachePondListKey => '${cachePrefix}_pond_list_cache';
  String get _cachePondDataKey => '${cachePrefix}_pond_data_cache';
  String get _cacheSensorListKey => '${cachePrefix}_sensor_list_cache';
  String get _cacheCompanyListKey => '${cachePrefix}_company_list_cache';
  String get _cacheSelectedAstIdKey => '${cachePrefix}_selected_ast_id';
  String get _cacheSelectedAstNameKey => '${cachePrefix}_selected_ast_name';

  @override
  void onInit() {
    super.onInit();
    debugPrint('[Pharma Live] onInit -> pondList + companyList + polling');
    _bootstrap();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _aeratorPollTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    debugPrint('[Pharma Live] Polling started (every 1 minute)');
    _pollTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (isFetching.value) return;
      if (selectedAstId.value == 0) return;

      debugPrint('[poll] Polling pond data for id: ${selectedAstId.value}');
      pondData(id: selectedAstId.value);
    });
  }

  void _startAeratorPolling() {
    debugPrint('[Pharma Live] Aerator polling started (every 2 seconds)');
    _aeratorPollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (selectedAstId.value == 0) return;
      if (aeratorIds.isEmpty) return;
      _pollAeratorState();
    });
  }

  Future<void> _bootstrap() async {
    await _loadCachedState();
    pondList();
    CompanyList();
    _startPolling();
    _startAeratorPolling();
  }

  void _pollAeratorState() async {
    try {
      var response = await devicesRepository.getPondData(
        id: selectedAstId.value,
        isPharmaFlow: true,
      );
      response.fold((l) {}, (r) {
        try {
          final aerators = r.data.devices[0].aerators;
          for (int i = 0; i < aerators.length; i++) {
            final pk = aerators[i].aeratorPk;
            final idx = aeratorIds.indexOf(pk);
            if (idx >= 0) {
              aeratorSwitch[idx] = aerators[i].isRunning;
            } else {
              _cacheSingleAerator(pk, aerators[i].isRunning);
            }
          }
        } catch (_) {}
      });
    } catch (_) {}
  }

  pondList() async {
    debugPrint('[API] getPondList() requested');
    var response = await devicesRepository.getPondList(isPharmaFlow: true);
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

    if (id != null) selectedAstId.value = id;
    _cacheSelectedAstId(selectedAstId.value);

    debugPrint('[API] getPondData() requested -> asset_id: $id');
    var response = await devicesRepository.getPondData(
      id: id,
      isPharmaFlow: true,
    );
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

        final aerators = r.data.devices[0].aerators;
        if (aerators.isNotEmpty) {
          _syncAeratorSwitchState(aerators);
          _cacheAeratorListFromData(aerators);
        } else {
          debugPrint(
            '[Flow] Pond response returned no aerators; keeping cached switch state',
          );
        }

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
    var response = await devicesRepository.getSensorList(
      deviceId: deviceId,
      isPharmaFlow: true,
    );
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
    var response = await devicesRepository.getCompanyList(isPharmaFlow: true);
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
        _syncAeratorSwitchStateFromCachedResponse(pondDataResponse.value!);
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

      if (aeratorIds.isEmpty || aeratorSwitch.isEmpty) {
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
      }
    } catch (_) {}
  }

  Future<void> _cachePondList(PondListResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachePondListKey, response.toRawJson());
  }

  Future<void> _cachePondData(PondDataResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = response.toJson();
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      final devices = data['devices'];
      if (devices is List && devices.isNotEmpty) {
        final firstDevice = devices.first;
        if (firstDevice is Map<String, dynamic>) {
          final aerators = firstDevice['aerators'];
          if (aerators is! List || aerators.isEmpty) {
            final cached = prefs.getString(_cachePondDataKey);
            if (cached != null && cached.isNotEmpty) {
              try {
                final previous = Map<String, dynamic>.from(jsonDecode(cached));
                final previousData = previous['data'];
                if (previousData is Map<String, dynamic>) {
                  final previousDevices = previousData['devices'];
                  if (previousDevices is List && previousDevices.isNotEmpty) {
                    final previousFirstDevice = previousDevices.first;
                    if (previousFirstDevice is Map<String, dynamic> &&
                        previousFirstDevice['aerators'] is List) {
                      firstDevice['aerators'] = previousFirstDevice['aerators'];
                    }
                  }
                }
              } catch (_) {}
            }
          }
        }
      }
    }
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

  void _syncAeratorSwitchStateFromCachedResponse(PondDataResponse response) {
    final aerators = _extractAerators(response);
    if (aerators.isNotEmpty) {
      _syncAeratorSwitchState(aerators);
    }
  }

  List<Aerator> _extractAerators(PondDataResponse response) {
    try {
      if (response.data.devices.isEmpty) return const <Aerator>[];
      return response.data.devices.first.aerators;
    } catch (_) {
      return const <Aerator>[];
    }
  }

  void _syncAeratorSwitchState(List<Aerator> aerators) {
    if (aerators.isEmpty) return;

    if (aeratorIds.isEmpty || aeratorSwitch.isEmpty) {
      aeratorIds
        ..clear()
        ..addAll(aerators.map((a) => a.aeratorPk));
      aeratorSwitch
        ..clear()
        ..addAll(aerators.map((a) => a.isRunning));
      return;
    }

    for (final aerator in aerators) {
      final idx = aeratorIds.indexOf(aerator.aeratorPk);
      if (idx >= 0 && idx < aeratorSwitch.length) {
        aeratorSwitch[idx] = aerator.isRunning;
      } else {
        _cacheSingleAerator(aerator.aeratorPk, aerator.isRunning);
      }
    }
  }

  bool aeratorSwitchValueFor(int aeratorPk, {bool fallback = false}) {
    final idx = aeratorIds.indexOf(aeratorPk);
    if (idx >= 0 && idx < aeratorSwitch.length) {
      return aeratorSwitch[idx] == true;
    }
    return fallback;
  }

  bool isAeratorBusy(int aeratorPk) => busyAeratorPks.contains(aeratorPk);

  aeratorCommand({
    id,
    command,
    int? index,
    bool? isOnline,
    int? aeratorPk,
  }) async {
    if (isOnline == false) {
      try {
        Get.snackbar(
          'Error',
          'This aerator is offline',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (_) {}
      return;
    }

    final pk = aeratorPk;
    if (pk != null && busyAeratorPks.contains(pk)) return;

    if (pk != null) {
      busyAeratorPks.add(pk);
      commandInProgress.value = true;
    }

    debugPrint(
      '[API] setAeratorCommand() requested -> id: $id, command: $command',
    );
    var response = await devicesRepository.setAeratorCommand(
      id: id,
      command: command,
      isPharmaFlow: true,
    );

    response.fold(
      (l) {
        String errorMsg = l.message;
        debugPrint('[API] setAeratorCommand() failed -> $errorMsg');

        try {
          Get.snackbar('Error', errorMsg, snackPosition: SnackPosition.BOTTOM);
        } catch (_) {}

        if (pk != null) {
          busyAeratorPks.remove(pk);
          commandInProgress.value = busyAeratorPks.isNotEmpty;
        } else {
          commandInProgress.value = false;
        }
      },
      (r) {
        debugPrint('[API] setAeratorCommand() success -> ${r.msg}');
        aeratorCommandResponse.value = r;

        try {
          Get.snackbar(
            'Success',
            r.msg ?? 'Command sent successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (_) {}

        pondData(id: selectedAstId.value);
        if (pk != null) {
          busyAeratorPks.remove(pk);
          commandInProgress.value = busyAeratorPks.isNotEmpty;
        } else {
          commandInProgress.value = false;
        }
      },
    );
  }
}
