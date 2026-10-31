import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/app_strings.dart';
import '../services/decision_engine.dart';
import '../services/settings_service.dart';
import '../services/weather_services.dart';
import '../widgets/sensor_card.dart';

enum WeatherState { loading, live, failed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SensorData data;
  WeatherState weatherState = WeatherState.loading;

  @override
  void initState() {
    super.initState();
    final s = farmSettings.value;
    data = SensorData(
      crop: s.crop,
      location: s.location,
      soilMoisture: 25,
      temperature: 31,
      humidity: 60,
      rainProbability: 20,
    );
    farmSettings.addListener(onSettingsChanged);
    refreshWeather();
  }

  @override
  void dispose() {
    farmSettings.removeListener(onSettingsChanged);
    super.dispose();
  }

  // Runs when Settings saves a new crop or location.
  void onSettingsChanged() {
    final s = farmSettings.value;
    setState(() {
      data = SensorData(
        crop: s.crop,
        location: s.location,
        soilMoisture: data.soilMoisture,
        temperature: data.temperature,
        humidity: data.humidity,
        rainProbability: data.rainProbability,
      );
    });
    refreshWeather();
  }

  // SensorData is immutable, so we build a new one each time.
  void updateData({
    double? moisture,
    double? temperature,
    double? humidity,
    double? rain,
  }) {
    setState(() {
      data = SensorData(
        crop: data.crop,
        location: data.location,
        soilMoisture: moisture ?? data.soilMoisture,
        temperature: temperature ?? data.temperature,
        humidity: humidity ?? data.humidity,
        rainProbability: rain ?? data.rainProbability,
      );
    });
  }

  Future<void> refreshWeather() async {
    final s = farmSettings.value;
    setState(() => weatherState = WeatherState.loading);
    try {
      final w = await fetchWeather(s.latitude, s.longitude);
      if (!mounted) return;
      updateData(
        rain: w.rainProbability,
        temperature: w.temperature,
        humidity: w.humidity,
      );
      setState(() => weatherState = WeatherState.live);
    } catch (e) {
      if (!mounted) return;
      setState(() => weatherState = WeatherState.failed);
    }
  }

  String recommendationText(BuildContext context, Recommendation r) {
    switch (r) {
      case Recommendation.irrigate:
        return tr(context, 'rec_irrigate');
      case Recommendation.delay:
        return tr(context, 'rec_delay');
      case Recommendation.notNeeded:
        return tr(context, 'rec_not_needed');
    }
  }

  List<Color> heroColors(Recommendation r) {
    switch (r) {
      case Recommendation.irrigate:
        return const [Color(0xFFE53935), Color(0xFFFF7043)];
      case Recommendation.delay:
        return const [Color(0xFFEF6C00), Color(0xFFF9A825)];
      case Recommendation.notNeeded:
        return const [Color(0xFF2E7D32), Color(0xFF66BB6A)];
    }
  }

  IconData heroIcon(Recommendation r) {
    switch (r) {
      case Recommendation.irrigate:
        return Icons.water_drop;
      case Recommendation.delay:
        return Icons.schedule;
      case Recommendation.notNeeded:
        return Icons.check_circle;
    }
  }

  String weatherText(BuildContext context) {
    switch (weatherState) {
      case WeatherState.loading:
        return tr(context, 'weather_loading');
      case WeatherState.live:
        return '${tr(context, 'weather_live')}: ${data.location}';
      case WeatherState.failed:
        return tr(context, 'weather_failed');
    }
  }

  Widget heroCard(BuildContext context, Recommendation r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: heroColors(r),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grass, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${cropName(context, data.crop)} · ${data.location}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0x33FFFFFF),
              shape: BoxShape.circle,
            ),
            child: Icon(heroIcon(r), color: Colors.white, size: 36),
          ),
          const SizedBox(height: 14),
          Text(
            recommendationText(context, r),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${tr(context, 'dry_limit')}: ${moistureLimitFor(data.crop).round()}%',
            style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget weatherPill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_sync_outlined, color: Colors.green.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weatherText(context),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  tr(context, 'weather_note'),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: tr(context, 'refresh'),
            onPressed: refreshWeather,
          ),
        ],
      ),
    );
  }

  Widget demoControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Icon(Icons.tune, color: Colors.green.shade700),
          title: Text(
            tr(context, 'demo_title'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${tr(context, 'demo_moisture')}: ${data.soilMoisture.round()}%'),
            Slider(
              value: data.soilMoisture,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${data.soilMoisture.round()}%',
              onChanged: (v) => updateData(moisture: v),
            ),
            Text(
                '${tr(context, 'demo_rain')}: ${data.rainProbability.round()}%'),
            Slider(
              value: data.rainProbability,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${data.rainProbability.round()}%',
              onChanged: (v) => updateData(rain: v),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = decide(data.soilMoisture, data.rainProbability, data.crop);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'app_name')),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            tooltip: tr(context, 'language'),
            onSelected: setLanguage,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
              PopupMenuItem(value: 'hi', child: Text('हिन्दी')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          heroCard(context, result),
          const SizedBox(height: 16),
          GridView.extent(
            maxCrossAxisExtent: 220,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              SensorCard(
                icon: Icons.water_drop,
                label: tr(context, 'soil_moisture'),
                value: '${data.soilMoisture.round()}%',
                tone: Colors.blue,
              ),
              SensorCard(
                icon: Icons.thermostat,
                label: tr(context, 'temperature'),
                value: '${data.temperature.round()}°C',
                tone: Colors.orange,
              ),
              SensorCard(
                icon: Icons.opacity,
                label: tr(context, 'humidity'),
                value: '${data.humidity.round()}%',
                tone: Colors.teal,
              ),
              SensorCard(
                icon: Icons.cloud,
                label: tr(context, 'rain_chance'),
                value: '${data.rainProbability.round()}%',
                tone: Colors.indigo,
              ),
            ],
          ),
          const SizedBox(height: 16),
          weatherPill(context),
          const SizedBox(height: 12),
          demoControls(context),
        ],
      ),
    );
  }
}