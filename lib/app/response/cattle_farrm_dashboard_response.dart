import 'dart:convert';

class CattleFarmDashboardResponse {
  bool? success;
  int? statusCode;
  String? message;
  Data? data;

  CattleFarmDashboardResponse({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory CattleFarmDashboardResponse.fromRawJson(String str) => CattleFarmDashboardResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CattleFarmDashboardResponse.fromJson(Map<String, dynamic> json) => CattleFarmDashboardResponse(
    success: json["success"],
    statusCode: json["status_code"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "status_code": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  int? farmId;
  String? farmName;
  Weather? weather;
  bool? automationEnabled;
  Device? device;

  Data({
    this.farmId,
    this.farmName,
    this.weather,
    this.automationEnabled,
    this.device,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    farmId: json["farm_id"],
    farmName: json["farm_name"],
    weather: json["weather"] == null ? null : Weather.fromJson(json["weather"]),
    automationEnabled: json["automation_enabled"],
    device: json["device"] == null ? null : Device.fromJson(json["device"]),
  );

  Map<String, dynamic> toJson() => {
    "farm_id": farmId,
    "farm_name": farmName,
    "weather": weather?.toJson(),
    "automation_enabled": automationEnabled,
    "device": device?.toJson(),
  };
}

class Weather {
  String? sunlightLevel;
  String? solarRadiation;
  WeatherDistrict? weatherDistrict;
  String? weatherTemperature;
  String? weatherHumidity;
  String? weatherDescription;

  Weather({
    this.sunlightLevel,
    this.solarRadiation,
    this.weatherDistrict,
    this.weatherTemperature,
    this.weatherHumidity,
    this.weatherDescription,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    sunlightLevel: json["sunlight_level"],
    solarRadiation: json["solar_radiation"],
    weatherDistrict: json["weather_district"] == null ? null : WeatherDistrict.fromJson(json["weather_district"]),
    weatherTemperature: json["weather_temperature"],
    weatherHumidity: json["weather_humidity"],
    weatherDescription: json["weather_description"],
  );

  Map<String, dynamic> toJson() => {
    "sunlight_level": sunlightLevel,
    "solar_radiation": solarRadiation,
    "weather_district": weatherDistrict?.toJson(),
    "weather_temperature": weatherTemperature,
    "weather_humidity": weatherHumidity,
    "weather_description": weatherDescription,
  };
}

class WeatherDistrict {
  String? district;

  WeatherDistrict({this.district});

  factory WeatherDistrict.fromJson(Map<String, dynamic> json) => WeatherDistrict(
    district: json["district"],
  );

  Map<String, dynamic> toJson() => {
    "district": district,
  };
}

class Device {
  int? deviceId;
  String? deviceName;
  String? deviceStatus;
  String? clientId;
  bool? isOnline;
  List<Sensor>? sensors;
  List<Switch>? switches;

  Device({
    this.deviceId,
    this.deviceName,
    this.deviceStatus,
    this.clientId,
    this.isOnline,
    this.sensors,
    this.switches,
  });

  factory Device.fromRawJson(String str) => Device.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    deviceId: json["device_id"],
    deviceName: json["device_name"],
    deviceStatus: json["device_status"],
    clientId: json["client_id"],
    isOnline: json["is_online"],
    sensors: json["sensors"] == null ? [] : List<Sensor>.from(json["sensors"]!.map((x) => Sensor.fromJson(x))),
    switches: json["switches"] == null ? [] : List<Switch>.from(json["switches"]!.map((x) => Switch.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "device_id": deviceId,
    "device_name": deviceName,
    "device_status": deviceStatus,
    "client_id": clientId,
    "is_online": isOnline,
    "sensors": sensors == null ? [] : List<dynamic>.from(sensors!.map((x) => x.toJson())),
    "switches": switches == null ? [] : List<dynamic>.from(switches!.map((x) => x.toJson())),
  };
}

class Sensor {
  int? sensorId;
  String? name;
  String? unit;
  String? lastValue;
  String? dangerStatus;
  String? dataTime;
  int? sensorStatus;

  Sensor({
    this.sensorId,
    this.name,
    this.unit,
    this.lastValue,
    this.dangerStatus,
    this.dataTime,
    this.sensorStatus,
  });

  factory Sensor.fromRawJson(String str) => Sensor.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Sensor.fromJson(Map<String, dynamic> json) => Sensor(
    sensorId: json["sensor_id"],
    name: json["name"],
    unit: json["unit"],
    lastValue: json["last_value"],
    dangerStatus: json["danger_status"],
    dataTime: json["data_time"],
    sensorStatus: json["sensor_status"],
  );

  Map<String, dynamic> toJson() => {
    "sensor_id": sensorId,
    "name": name,
    "unit": unit,
    "last_value": lastValue,
    "danger_status": dangerStatus,
    "data_time": dataTime,
    "sensor_status": sensorStatus,
  };
}

class Switch {
  String? switchId;
  String? switchName;
  bool? isOn;
  bool? isActive;
  dynamic updatedAt;

  Switch({
    this.switchId,
    this.switchName,
    this.isOn,
    this.isActive,
    this.updatedAt,
  });

  factory Switch.fromRawJson(String str) => Switch.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Switch.fromJson(Map<String, dynamic> json) => Switch(
    switchId: json["switch_id"],
    switchName: json["switch_name"],
    isOn: json["is_on"],
    isActive: json["is_active"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "switch_id": switchId,
    "switch_name": switchName,
    "is_on": isOn,
    "is_active": isActive,
    "updated_at": updatedAt,
  };
}
