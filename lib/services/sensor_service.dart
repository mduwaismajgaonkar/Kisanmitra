import 'dart:convert';
import 'package:http/http.dart' as http;

class SensorReading {
  final double moisture;
  final double temperature;
  final double humidity;

  const SensorReading({
    required this.moisture,
    required this.temperature,
    required this.humidity,
  });
}

// baseUrl looks like: http://192.168.1.50
Future<SensorReading> fetchSensorReading(String baseUrl) async {
  final response = await http
      .get(Uri.parse('$baseUrl/data'))
      .timeout(const Duration(seconds: 4));

  if (response.statusCode != 200) {
    throw Exception('ESP32 replied with status ${response.statusCode}');
  }

  final json = jsonDecode(response.body) as Map<String, dynamic>;
  return SensorReading(
    moisture: (json['moisture'] as num).toDouble(),
    temperature: (json['temperature'] as num).toDouble(),
    humidity: (json['humidity'] as num).toDouble(),
  );
}