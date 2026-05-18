import 'dart:convert';

class CattleNotificationsResponse {
  bool? success;
  int? statusCode;
  String? message;
  List<NotificationData>? data;

  CattleNotificationsResponse({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory CattleNotificationsResponse.fromRawJson(String str) =>
      CattleNotificationsResponse.fromJson(json.decode(str));

  factory CattleNotificationsResponse.fromJson(Map<String, dynamic> json) =>
      CattleNotificationsResponse(
        success: json["success"],
        statusCode: json["status_code"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<NotificationData>.from(
                json["data"]!.map((x) => NotificationData.fromJson(x))),
      );
}

class NotificationData {
  int? id;
  int? sensor;
  String? sensorName;
  double? value;
  String? urgency;
  String? message;
  bool? isRead;
  String? notifiedAt;

  NotificationData({
    this.id,
    this.sensor,
    this.sensorName,
    this.value,
    this.urgency,
    this.message,
    this.isRead,
    this.notifiedAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        id: json["id"],
        sensor: json["sensor"],
        sensorName: json["sensor_name"],
        value: json["value"]?.toDouble(),
        urgency: json["urgency"],
        message: json["message"],
        isRead: json["is_read"],
        notifiedAt: json["notified_at"],
      );
}
