import 'package:flutter/material.dart';

// Language options with their locales
class AppLanguage {
  final String name;
  final String code;
  final String flag;

  const AppLanguage({
    required this.name,
    required this.code,
    required this.flag,
  });
}

// Available languages
final List<AppLanguage> availableLanguages = [
  const AppLanguage(name: 'Tiếng Việt', code: 'vi', flag: '🇻🇳'),
  const AppLanguage(name: 'English', code: 'en', flag: '🇺🇸'),
  const AppLanguage(name: '中文', code: 'zh', flag: '🇨🇳'),
  const AppLanguage(name: '日本語', code: 'ja', flag: '🇯🇵'),
  const AppLanguage(name: '한국어', code: 'ko', flag: '🇰🇷'),
];

// Global language notifier to switch languages
final ValueNotifier<AppLanguage> languageNotifier = ValueNotifier(
  availableLanguages[0],
);
