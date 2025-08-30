import 'package:flutter/material.dart';

class LanguageManager {
  static LanguageManager? _instance;
  static LanguageManager get instance {
    _instance ??= LanguageManager._init();
    return _instance!;
  }

  LanguageManager._init();

  final enLocale = const Locale('en', 'US');
  final trLocale = const Locale('tr', 'TR');
  final trLocaleCalendar = const Locale('tr', '');
  final enLocaleCalendar = const Locale('en', '');

  List<Locale> get supportedLocales => [enLocale, trLocale, trLocaleCalendar, enLocaleCalendar];
}
