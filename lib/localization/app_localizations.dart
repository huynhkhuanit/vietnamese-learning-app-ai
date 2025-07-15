import 'package:flutter/material.dart';
import 'translations.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  // Helper method to get current locale
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Static delegates for the localization
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    // Add other delegates if needed
  ];

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('vi', ''), // Vietnamese
    Locale('en', ''), // English
    Locale('zh', ''), // Chinese
    Locale('ja', ''), // Japanese
    Locale('ko', ''), // Korean
  ];

  // Get the translation map based on locale
  Map<String, String> get _translations {
    switch (locale.languageCode) {
      case 'en':
        return englishTranslations;
      case 'zh':
        return chineseTranslations;
      case 'ja':
        return japaneseTranslations;
      case 'ko':
        return koreanTranslations;
      case 'vi':
      default:
        return vietnameseTranslations;
    }
  }

  // Lookup a translation
  String translate(String key) {
    return _translations[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en', 'zh', 'ja', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
