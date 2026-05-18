import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../service/service.dart';
import '../../../response/cattle_farrm_dashboard_response.dart';

/// Handles Cattle Care header values (date/time + weather)
class CattleHeaderController extends GetxController {
  final formattedDate = ''.obs;
  final formattedTime = ''.obs;

  final tempText = ''.obs;
  final humidityText = ''.obs;
  final district = 'Dhaka'.obs;
  final description = ''.obs;
  final sunlight = ''.obs;

  final isLoadingWeather = false.obs;
  final weatherError = ''.obs;

  Timer? _timer;

  final String _apiKey = ApiService.apiKey;
  final String city = 'dhaka';

  @override
  void onInit() {
    super.onInit();

    // Start local clock
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

    // Initial fallback weather
    fetchWeatherData(city);
  }

  void _tick() {
    final now = DateTime.now();
    formattedDate.value = DateFormat('d-MMM-yyyy').format(now);
    formattedTime.value = DateFormat('h:mm:ss a').format(now);
  }

  /// Updates header with real-time data from farm dashboard backend
  void updateFromDashboard(Weather? weather) {
    if (weather == null) return;

    district.value = weather.weatherDistrict?.district ?? 'Dhaka';
    description.value = weather.weatherDescription ?? '';
    sunlight.value = weather.sunlightLevel ?? '';
    tempText.value = "${weather.weatherTemperature}°C";
    humidityText.value = "${weather.weatherHumidity}%";
  }

  Future<void> fetchWeatherData(String city) async {
    isLoadingWeather.value = true;
    weatherError.value = '';
    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body) as Map<String, dynamic>;
        final main = (jsonMap['main'] as Map?) ?? {};
        final weatherArr = (jsonMap['weather'] as List?) ?? [];
        
        final t = main['temp'];
        final h = main['humidity'];
        
        tempText.value = t == null ? '' : '${(t as num).toStringAsFixed(2)}°C';
        humidityText.value = h == null ? '' : '${h.toString()}%';
        
        if (weatherArr.isNotEmpty) {
          description.value = weatherArr[0]['description'] ?? '';
        }
      } else {
        weatherError.value = 'Weather unavailable';
      }
    } catch (_) {
      weatherError.value = 'Weather unavailable';
    } finally {
      isLoadingWeather.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
