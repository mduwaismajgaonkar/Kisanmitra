import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String languageKey = 'language';

// 'en', 'kn' or 'hi'. Any screen can listen to this.
final ValueNotifier<String> appLanguage = ValueNotifier<String>('en');

Future<void> loadLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(languageKey);
  if (code != null && (code == 'en' || code == 'kn' || code == 'hi')) {
    appLanguage.value = code;
  }
}

Future<void> setLanguage(String code) async {
  appLanguage.value = code;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(languageKey, code);
}

// Screens that call tr(context, ...) rebuild automatically when the
// language changes, because this widget notifies them.
class LanguageScope extends InheritedNotifier<ValueNotifier<String>> {
  const LanguageScope({
    super.key,
    required ValueNotifier<String> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static String of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LanguageScope>();
    return scope?.notifier?.value ?? 'en';
  }
}

String tr(BuildContext context, String key) {
  final lang = LanguageScope.of(context);
  return _strings[lang]?[key] ?? _strings['en']![key] ?? key;
}

// Crop names are stored in English, and shown in the chosen language.
String cropName(BuildContext context, String crop) {
  final key = 'crop_$crop';
  final text = tr(context, key);
  return text == key ? crop : text;
}

const Map<String, Map<String, String>> _strings = {
  'en': {
    'app_name': 'KisanMitra',
    'nav_home': 'Home',
    'nav_calendar': 'Calendar',
    'nav_settings': 'Settings',
    'soil_moisture': 'Soil moisture',
    'temperature': 'Temperature',
    'humidity': 'Humidity',
    'rain_chance': 'Rain chance',
    'rec_irrigate': 'Irrigation may be required.',
    'rec_delay': 'Consider delaying irrigation and monitor conditions.',
    'rec_not_needed': 'Irrigation may not be required currently.',
    'dry_limit': 'Dry limit',
    'weather_loading': 'Loading weather...',
    'weather_live': 'Live weather',
    'weather_failed': 'Could not load weather. Using sample values.',
    'weather_note':
        'Temperature, humidity and rain come from the weather service. Soil moisture is a demo value.',
    'refresh': 'Refresh weather',
    'demo_title': 'Demo controls',
    'demo_moisture': 'Soil moisture',
    'demo_rain': 'Rain probability',
    'crop_Wheat': 'Wheat',
    'crop_Rice': 'Rice',
    'crop_Maize': 'Maize',
    'crop_Jowar': 'Jowar',
    'crop_Sugarcane': 'Sugarcane',
    'crop_Cotton': 'Cotton',
    'crop_Groundnut': 'Groundnut',
    'crop_Tomato': 'Tomato',
    'settings_title': 'Settings',
    'language': 'Language',
    'farm_details': 'Farm details',
    'crop': 'Crop',
    'location': 'Location (village or city)',
    'save': 'Save',
    'saving': 'Saving...',
    'msg_type_place': 'Please type a place name.',
    'msg_searching': 'Searching for',
    'msg_not_found': 'Could not find that place. Try another spelling.',
    'msg_saved': 'Saved',
    'msg_no_internet': 'Could not reach the place search. Check your internet.',
    'cal_title': 'Farm Activity Calendar',
    'act_add': 'Add activity',
    'act_edit': 'Edit activity',
    'act_note': 'Note (optional)',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'delete_q': 'Delete activity?',
    'delete_msg': 'This entry will be removed.',
    'activities': 'Activities',
    'none_yet': 'No activities recorded. Tap + to add one.',
    'act_irrigation': 'Irrigation',
    'act_fertilizer': 'Fertilizer',
    'act_sowing': 'Sowing',
    'act_spraying': 'Spraying',
    'act_harvesting': 'Harvesting',
    'act_other': 'Other',
  },
  'kn': {
    'app_name': 'ಕಿಸಾನ್ ಮಿತ್ರ',
    'nav_home': 'ಮುಖಪುಟ',
    'nav_calendar': 'ಕ್ಯಾಲೆಂಡರ್',
    'nav_settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
    'soil_moisture': 'ಮಣ್ಣಿನ ತೇವಾಂಶ',
    'temperature': 'ತಾಪಮಾನ',
    'humidity': 'ಆರ್ದ್ರತೆ',
    'rain_chance': 'ಮಳೆಯ ಸಾಧ್ಯತೆ',
    'rec_irrigate': 'ನೀರಾವರಿ ಅಗತ್ಯವಿರಬಹುದು.',
    'rec_delay': 'ನೀರಾವರಿಯನ್ನು ಮುಂದೂಡುವುದನ್ನು ಪರಿಗಣಿಸಿ ಮತ್ತು ಪರಿಸ್ಥಿತಿಯನ್ನು ಗಮನಿಸಿ.',
    'rec_not_needed': 'ಈಗ ನೀರಾವರಿ ಅಗತ್ಯವಿಲ್ಲದಿರಬಹುದು.',
    'dry_limit': 'ಒಣ ಮಿತಿ',
    'weather_loading': 'ಹವಾಮಾನ ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
    'weather_live': 'ಲೈವ್ ಹವಾಮಾನ',
    'weather_failed': 'ಹವಾಮಾನ ಲೋಡ್ ಆಗಲಿಲ್ಲ. ಮಾದರಿ ಮೌಲ್ಯಗಳನ್ನು ಬಳಸಲಾಗುತ್ತಿದೆ.',
    'weather_note':
        'ತಾಪಮಾನ, ಆರ್ದ್ರತೆ ಮತ್ತು ಮಳೆ ಹವಾಮಾನ ಸೇವೆಯಿಂದ ಬರುತ್ತವೆ. ಮಣ್ಣಿನ ತೇವಾಂಶ ಡೆಮೊ ಮೌಲ್ಯ.',
    'refresh': 'ಹವಾಮಾನ ನವೀಕರಿಸಿ',
    'demo_title': 'ಡೆಮೊ ನಿಯಂತ್ರಣಗಳು',
    'demo_moisture': 'ಮಣ್ಣಿನ ತೇವಾಂಶ',
    'demo_rain': 'ಮಳೆಯ ಸಂಭವನೀಯತೆ',
    'crop_Wheat': 'ಗೋಧಿ',
    'crop_Rice': 'ಭತ್ತ',
    'crop_Maize': 'ಮೆಕ್ಕೆಜೋಳ',
    'crop_Jowar': 'ಜೋಳ',
    'crop_Sugarcane': 'ಕಬ್ಬು',
    'crop_Cotton': 'ಹತ್ತಿ',
    'crop_Groundnut': 'ಶೇಂಗಾ',
    'crop_Tomato': 'ಟೊಮೆಟೊ',
    'settings_title': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
    'language': 'ಭಾಷೆ',
    'farm_details': 'ಹೊಲದ ವಿವರಗಳು',
    'crop': 'ಬೆಳೆ',
    'location': 'ಸ್ಥಳ (ಹಳ್ಳಿ ಅಥವಾ ನಗರ)',
    'save': 'ಉಳಿಸಿ',
    'saving': 'ಉಳಿಸಲಾಗುತ್ತಿದೆ...',
    'msg_type_place': 'ದಯವಿಟ್ಟು ಸ್ಥಳದ ಹೆಸರನ್ನು ಟೈಪ್ ಮಾಡಿ.',
    'msg_searching': 'ಹುಡುಕಲಾಗುತ್ತಿದೆ:',
    'msg_not_found': 'ಆ ಸ್ಥಳ ಸಿಗಲಿಲ್ಲ. ಬೇರೆ ಕಾಗುಣಿತ ಪ್ರಯತ್ನಿಸಿ.',
    'msg_saved': 'ಉಳಿಸಲಾಗಿದೆ',
    'msg_no_internet': 'ಸ್ಥಳ ಹುಡುಕಾಟ ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಇಂಟರ್ನೆಟ್ ಪರಿಶೀಲಿಸಿ.',
    'cal_title': 'ಹೊಲದ ಚಟುವಟಿಕೆ ಕ್ಯಾಲೆಂಡರ್',
    'act_add': 'ಚಟುವಟಿಕೆ ಸೇರಿಸಿ',
    'act_edit': 'ಚಟುವಟಿಕೆ ಸಂಪಾದಿಸಿ',
    'act_note': 'ಟಿಪ್ಪಣಿ (ಐಚ್ಛಿಕ)',
    'cancel': 'ರದ್ದುಮಾಡಿ',
    'delete': 'ಅಳಿಸಿ',
    'delete_q': 'ಚಟುವಟಿಕೆಯನ್ನು ಅಳಿಸಬೇಕೇ?',
    'delete_msg': 'ಈ ನಮೂದನ್ನು ತೆಗೆದುಹಾಕಲಾಗುತ್ತದೆ.',
    'activities': 'ಚಟುವಟಿಕೆಗಳು',
    'none_yet': 'ಯಾವುದೇ ಚಟುವಟಿಕೆ ದಾಖಲಾಗಿಲ್ಲ. ಸೇರಿಸಲು + ಒತ್ತಿ.',
    'act_irrigation': 'ನೀರಾವರಿ',
    'act_fertilizer': 'ಗೊಬ್ಬರ',
    'act_sowing': 'ಬಿತ್ತನೆ',
    'act_spraying': 'ಸಿಂಪಡಣೆ',
    'act_harvesting': 'ಕೊಯ್ಲು',
    'act_other': 'ಇತರೆ',
  },
  'hi': {
    'app_name': 'किसान मित्र',
    'nav_home': 'होम',
    'nav_calendar': 'कैलेंडर',
    'nav_settings': 'सेटिंग्स',
    'soil_moisture': 'मिट्टी की नमी',
    'temperature': 'तापमान',
    'humidity': 'आर्द्रता',
    'rain_chance': 'बारिश की संभावना',
    'rec_irrigate': 'सिंचाई की आवश्यकता हो सकती है।',
    'rec_delay': 'सिंचाई टालने पर विचार करें और स्थिति पर नज़र रखें।',
    'rec_not_needed': 'अभी सिंचाई की आवश्यकता नहीं हो सकती।',
    'dry_limit': 'सूखेपन की सीमा',
    'weather_loading': 'मौसम लोड हो रहा है...',
    'weather_live': 'लाइव मौसम',
    'weather_failed': 'मौसम लोड नहीं हो सका। नमूना मान उपयोग किए जा रहे हैं।',
    'weather_note':
        'तापमान, आर्द्रता और बारिश मौसम सेवा से आते हैं। मिट्टी की नमी एक डेमो मान है।',
    'refresh': 'मौसम रीफ़्रेश करें',
    'demo_title': 'डेमो नियंत्रण',
    'demo_moisture': 'मिट्टी की नमी',
    'demo_rain': 'बारिश की संभावना',
    'crop_Wheat': 'गेहूं',
    'crop_Rice': 'धान',
    'crop_Maize': 'मक्का',
    'crop_Jowar': 'ज्वार',
    'crop_Sugarcane': 'गन्ना',
    'crop_Cotton': 'कपास',
    'crop_Groundnut': 'मूंगफली',
    'crop_Tomato': 'टमाटर',
    'settings_title': 'सेटिंग्स',
    'language': 'भाषा',
    'farm_details': 'खेत का विवरण',
    'crop': 'फसल',
    'location': 'स्थान (गांव या शहर)',
    'save': 'सहेजें',
    'saving': 'सहेजा जा रहा है...',
    'msg_type_place': 'कृपया स्थान का नाम लिखें।',
    'msg_searching': 'खोज रहे हैं:',
    'msg_not_found': 'वह स्थान नहीं मिला। कोई दूसरी वर्तनी आज़माएं।',
    'msg_saved': 'सहेजा गया',
    'msg_no_internet': 'स्थान खोज तक नहीं पहुंच सके। इंटरनेट जांचें।',
    'cal_title': 'खेत गतिविधि कैलेंडर',
    'act_add': 'गतिविधि जोड़ें',
    'act_edit': 'गतिविधि संपादित करें',
    'act_note': 'टिप्पणी (वैकल्पिक)',
    'cancel': 'रद्द करें',
    'delete': 'हटाएं',
    'delete_q': 'गतिविधि हटानी है?',
    'delete_msg': 'यह प्रविष्टि हटा दी जाएगी।',
    'activities': 'गतिविधियां',
    'none_yet': 'कोई गतिविधि दर्ज नहीं है। जोड़ने के लिए + दबाएं।',
    'act_irrigation': 'सिंचाई',
    'act_fertilizer': 'खाद',
    'act_sowing': 'बुवाई',
    'act_spraying': 'छिड़काव',
    'act_harvesting': 'कटाई',
    'act_other': 'अन्य',
  },
};