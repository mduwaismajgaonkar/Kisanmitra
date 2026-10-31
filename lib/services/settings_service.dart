import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FarmSettings {
  final String crop;
  final String location;
  final double latitude;
  final double longitude;

  const FarmSettings({
    required this.crop,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'crop': crop,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory FarmSettings.fromJson(Map<String, dynamic> json) => FarmSettings(
        crop: json['crop'] as String,
        location: json['location'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}

const FarmSettings defaultSettings = FarmSettings(
  crop: 'Wheat',
  location: 'Hubballi',
  latitude: 15.3647,
  longitude: 75.1240,
);

const String settingsKey = 'farm_settings';

// Any screen can listen to this. When it changes, they update.
final ValueNotifier<FarmSettings> farmSettings =
    ValueNotifier<FarmSettings>(defaultSettings);

Future<void> loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(settingsKey);
  if (raw == null) return;
  try {
    farmSettings.value =
        FarmSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  } catch (e) {
    // Saved data was damaged, so keep the defaults.
  }
}

Future<void> saveSettings(FarmSettings s) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(settingsKey, jsonEncode(s.toJson()));
  farmSettings.value = s;
}

class PlaceResult {
  final String name;
  final String region;
  final double latitude;
  final double longitude;

  const PlaceResult({
    required this.name,
    required this.region,
    required this.latitude,
    required this.longitude,
  });
}

// Turns a place name into coordinates. Returns null if nothing is found.
// Prefers real towns and cities over airports, stations and so on.
Future<PlaceResult?> findPlace(String name) async {
  final url = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
    'name': name,
    'count': '10',
    'language': 'en',
    'format': 'json',
  });

  final response = await http.get(url).timeout(const Duration(seconds: 6));
  if (response.statusCode != 200) {
    throw Exception('Place search replied with ${response.statusCode}');
  }

  final json = jsonDecode(response.body) as Map<String, dynamic>;
  final results = json['results'] as List?;
  if (results == null || results.isEmpty) return null;

  Map<String, dynamic> best = results.first as Map<String, dynamic>;
  for (final r in results) {
    final m = r as Map<String, dynamic>;
    final code = (m['feature_code'] as String?) ?? '';
    if (code.startsWith('PPL')) {
      best = m;
      break;
    }
  }

  return PlaceResult(
    name: best['name'] as String,
    region: (best['admin1'] as String?) ?? '',
    latitude: (best['latitude'] as num).toDouble(),
    longitude: (best['longitude'] as num).toDouble(),
  );
}