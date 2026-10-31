import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherNow {
  final double rainProbability;
  final double temperature;
  final double humidity;

  const WeatherNow({
    required this.rainProbability,
    required this.temperature,
    required this.humidity,
  });
}

Future<WeatherNow> fetchWeather(double latitude, double longitude) async {
  final url = Uri.parse(
    'https://api.open-meteo.com/v1/forecast'
    '?latitude=$latitude&longitude=$longitude'
    '&current=temperature_2m,relative_humidity_2m'
    '&hourly=precipitation_probability&forecast_days=1&timezone=auto',
  );

  final response = await http.get(url).timeout(const Duration(seconds: 8));
  if (response.statusCode != 200) {
    throw Exception('Weather service replied with ${response.statusCode}');
  }

  final json = jsonDecode(response.body) as Map<String, dynamic>;

  final current = json['current'] as Map<String, dynamic>;
  final temperature = (current['temperature_2m'] as num).toDouble();
  final humidity = (current['relative_humidity_2m'] as num).toDouble();

  // The time looks like 2026-10-28T16:30 (local time at the farm).
  final timeText = current['time'] as String;
  final hour = int.parse(timeText.substring(11, 13));

  final list = json['hourly']['precipitation_probability'] as List;
  final i = hour < list.length ? hour : list.length - 1;
  final rainValue = list[i];

  return WeatherNow(
    rainProbability: rainValue == null ? 0 : (rainValue as num).toDouble(),
    temperature: temperature,
    humidity: humidity,
  );
}