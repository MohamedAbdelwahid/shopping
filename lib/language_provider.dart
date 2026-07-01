import 'package:flutter/material.dart';
import 'localization.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'ar'; // Default language

  // Supported languages list with labels
  final List<Map<String, String>> supportedLanguages = [
    {'code': 'ar', 'name': 'العربية', 'flag': '🇪🇬'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
  ];

  String get currentLanguage => _currentLanguage;

  bool get isArabic => _currentLanguage == 'ar';

  void changeLanguage(String langCode) {
    if (_currentLanguage != langCode) {
      _currentLanguage = langCode;
      notifyListeners();
    }
  }

  String translate(String key) {
    return S.get(key, _currentLanguage);
  }

  String translateProduct(String nameAr, String nameEn) {
    return S.translateProduct(nameAr, nameEn, _currentLanguage);
  }

  String translateCategory(String categoryEn) {
    return S.translateCategory(categoryEn, _currentLanguage);
  }
}
