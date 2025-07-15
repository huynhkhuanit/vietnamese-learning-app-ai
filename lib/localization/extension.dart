import '../language_notifier.dart';
import 'translations.dart';

// Extension on String to make translations easy to use
extension StringTranslationExtension on String {
  String get tr {
    final currentLang = languageNotifier.value.code;

    Map<String, String> translations;
    switch (currentLang) {
      case 'en':
        translations = englishTranslations;
        break;
      case 'zh':
        translations = chineseTranslations;
        break;
      case 'ja':
        translations = japaneseTranslations;
        break;
      case 'ko':
        translations = koreanTranslations;
        break;
      case 'vi':
      default:
        translations = vietnameseTranslations;
    }

    return translations[this] ?? this;
  }
}
