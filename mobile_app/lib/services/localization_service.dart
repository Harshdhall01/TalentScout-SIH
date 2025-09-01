// services/localization_service.dart
import 'package:flutter/material.dart';

class LocalizationService extends ChangeNotifier {
  Locale _currentLocale = Locale('en', 'US');

  Locale get currentLocale => _currentLocale;

  void setLocale(String languageCode) {
    switch (languageCode) {
      case 'hi':
        _currentLocale = Locale('hi', 'IN');
        break;
      case 'en':
      default:
        _currentLocale = Locale('en', 'US');
        break;
    }
    notifyListeners();
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'TalentScout',
      'login_title': 'Register to Start',
      'name': 'Full Name',
      'age': 'Age',
      'phone': 'Phone Number',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',
      'register': 'Register & Start Tests',
      'select_test': 'Select Fitness Test',
      'situps': 'Sit-ups',
      'vertical_jump': 'Vertical Jump',
      'shuttle_run': 'Shuttle Run',
      'start_test': 'Start Test',
      'stop_test': 'Stop Test',
      'view_results': 'View Results',
    },
    'hi': {
      'app_title': 'टैलेंटस्काउट',
      'login_title': 'शुरू करने के लिए पंजीकरण करें',
      'name': 'पूरा नाम',
      'age': 'आयु',
      'phone': 'फोन नंबर',
      'gender': 'लिंग',
      'male': 'पुरुष',
      'female': 'महिला',
      'other': 'अन्य',
      'register': 'पंजीकरण और परीक्षा शुरू करें',
      'select_test': 'फिटनेस परीक्षा चुनें',
      'situps': 'सिट-अप्स',
      'vertical_jump': 'ऊर्ध्वाधर जंप',
      'shuttle_run': 'शटल रन',
      'start_test': 'परीक्षा शुरू करें',
      'stop_test': 'परीक्षा रोकें',
      'view_results': 'परिणाम देखें',
    },
  };

  String translate(String key) {
    return _localizedValues[_currentLocale.languageCode]?[key] ?? key;
  }
}
