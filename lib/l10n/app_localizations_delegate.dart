import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'sr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'sr':
        return AppLocalizationsSr();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
  
  /// Static method to get supported locales
  static List<Locale> get supportedLocales => const [
    Locale('en', ''), // English
    Locale('sr', ''), // Serbian
  ];
  
  /// Static method to get language names
  static Map<String, String> get languageNames => {
    'en': 'English',
    'sr': 'Српски', // Serbian in Cyrillic
  };
}
