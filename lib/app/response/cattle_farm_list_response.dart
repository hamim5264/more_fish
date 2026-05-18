import 'dart:convert';

class CattleFarmListResponse {
  bool? success;
  int? statusCode;
  String? message;
  List<Datum>? data;

  CattleFarmListResponse({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory CattleFarmListResponse.fromRawJson(String str) => CattleFarmListResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CattleFarmListResponse.fromJson(Map<String, dynamic> json) => CattleFarmListResponse(
    success: json["success"],
    statusCode: json["status_code"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "status_code": statusCode,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? id;
  String? name;
  String? location;

  Datum({
    this.id,
    this.name,
    this.location,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    location: json["location"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "location": location,
  };
}
