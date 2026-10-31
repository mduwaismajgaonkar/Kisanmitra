import 'package:flutter/material.dart';
import '../services/app_strings.dart';
import '../services/settings_service.dart';

const List<String> cropOptions = [
  'Wheat',
  'Rice',
  'Maize',
  'Jowar',
  'Sugarcane',
  'Cotton',
  'Groundnut',
  'Tomato',
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String crop;
  late final TextEditingController locationController;
  bool saving = false;
  String message = '';

  @override
  void initState() {
    super.initState();
    final s = farmSettings.value;
    crop = s.crop;
    locationController = TextEditingController(text: s.location);
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final typed = locationController.text.trim();
    if (typed.isEmpty) {
      setState(() => message = tr(context, 'msg_type_place'));
      return;
    }

    setState(() {
      saving = true;
      message = '${tr(context, 'msg_searching')} $typed';
    });

    try {
      final place = await findPlace(typed);
      if (!mounted) return;

      if (place == null) {
        setState(() {
          saving = false;
          message = tr(context, 'msg_not_found');
        });
        return;
      }

      await saveSettings(FarmSettings(
        crop: crop,
        location: place.name,
        latitude: place.latitude,
        longitude: place.longitude,
      ));
      if (!mounted) return;

      locationController.text = place.name;
      final region = place.region.isEmpty ? '' : ', ${place.region}';
      setState(() {
        saving = false;
        message =
            '${tr(context, 'msg_saved')}: ${cropName(context, crop)} · ${place.name}$region';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        saving = false;
        message = tr(context, 'msg_no_internet');
      });
    }
  }

  Widget section(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'settings_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          section(
            tr(context, 'language'),
            SegmentedButton<String>(
                            segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'kn', label: Text('ಕನ್ನಡ')),
                ButtonSegment(value: 'hi', label: Text('हिन्दी')),
              ],
              selected: {lang},
              onSelectionChanged: (s) => setLanguage(s.first),
            ),
          ),
          const SizedBox(height: 16),
          section(
            tr(context, 'farm_details'),
            Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: crop,
                  decoration: InputDecoration(
                    labelText: tr(context, 'crop'),
                    border: const OutlineInputBorder(),
                  ),
                  items: cropOptions
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(cropName(context, c)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => crop = v);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: tr(context, 'location'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  onSubmitted: (_) => save(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: saving ? null : save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                        saving ? tr(context, 'saving') : tr(context, 'save')),
                  ),
                ),
              ],
            ),
          ),
          if (message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(message),
            ),
        ],
      ),
    );
  }
}