import 'dart:convert';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../response/cattle_farm_list_response.dart';
import '../response/cattle_farrm_dashboard_response.dart';
import '../service/local_storage.dart';
import 'cattle_live_models.dart';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../service/failure.dart';
import '../service/service.dart';

import '../response/cattle_notifications_response.dart';

abstract class CattleLiveRepository {
  Future<List<CattleDevice>> getDevices();
  Future<CattleLiveData> getLatestLiveData({required String deviceId});
}



class CattleLiveDataRepository{

  Future<Either<Failure, CattleFarmListResponse>> getFarmList() async {
    var loginTokenStorage = Get.find<LoginTokenStorage>();
    var token = loginTokenStorage.getCattleToken();
    try {
      var request = http.Request('GET', Uri.parse("${ApiService.baseUrl}/cattle_care/farms/list/"));
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        CattleFarmListResponse cattleFarmListResponse = CattleFarmListResponse.fromRawJson(data);
        return Right(cattleFarmListResponse);
      }
      else {
        return Left(Failure('Failed to fetch cattle with status: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }


  Future<Either<Failure, CattleFarmDashboardResponse>> getFarmDashboard({id}) async {
    var loginTokenStorage = Get.find<LoginTokenStorage>();
    var token = loginTokenStorage.getCattleToken();
    try {
      var request = http.Request('GET', Uri.parse("${ApiService.baseUrl}/cattle_care/farms/dashboard/?farm_id=$id"));
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        CattleFarmDashboardResponse cattleFarmDashboardResponse = CattleFarmDashboardResponse.fromRawJson(data);
        return Right(cattleFarmDashboardResponse);
      }
      else {
        return Left(Failure('Failed to fetch cattle with status: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  Future<Either<Failure, CattleNotificationsResponse>> getNotifications() async {
    var loginTokenStorage = Get.find<LoginTokenStorage>();
    var token = loginTokenStorage.getCattleToken();
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/cattle_care/notifications/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Right(CattleNotificationsResponse.fromRawJson(response.body));
      } else {
        return Left(Failure('Failed to fetch notifications with status: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }

  Future<Either<Failure, bool>> setSwitchState({
    required String switchId,
    required bool turnOn,
  }) async {
    var loginTokenStorage = Get.find<LoginTokenStorage>();
    var token = loginTokenStorage.getCattleToken();
    try {
      final url = Uri.parse("${ApiService.baseUrl}/cattle_care/switches/command/");
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'switch_id': switchId,
          'command': turnOn ? 1 : 0,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return const Right(true);
        } else {
          return Left(Failure(decoded['message'] ?? 'Switch command failed'));
        }
      } else {
        return Left(Failure('Failed with status: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure('Error: $e'));
    }
  }



}