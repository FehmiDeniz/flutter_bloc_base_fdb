import 'package:flutter/material.dart';

import '../colors/color_theme.dart';
import 'text_theme_interface.dart';

class TextThemeLight implements ITextTheme {
  @override
  late final TextTheme data;

  @override
  late final String? fontFamily;
  @override
  TextStyle? displayLarge = const TextStyle(fontSize: 26, fontWeight: FontWeight.w700);
  @override
  TextStyle? displayMedium = const TextStyle(fontSize: 20, fontWeight: FontWeight.normal);
  @override
  TextStyle? displaySmall = const TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  @override
  TextStyle? headlineLarge = const TextStyle(fontSize: 26, fontWeight: FontWeight.w700);
  @override
  TextStyle? headlineMedium = const TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  @override
  TextStyle? headlineSmall = const TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  @override
  TextStyle? titleLarge = const TextStyle(fontSize: 26, fontWeight: FontWeight.w700);
  @override
  TextStyle? titleMedium = const TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  @override
  TextStyle? titleSmall = const TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  @override
  TextStyle? labelLarge = const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  @override
  TextStyle? labelMedium = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  @override
  TextStyle? labelSmall = const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  @override
  TextStyle? bodyLarge = const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  @override
  TextStyle? bodyMedium = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  @override
  TextStyle? bodySmall = const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

  @override
  final Color? primaryColor;

  TextThemeLight({this.primaryColor, IColors? colorTheme}) {
    fontFamily = "Satoshi";

    data = TextTheme(
            headlineLarge: headlineLarge,
            headlineMedium: headlineMedium,
            headlineSmall: headlineSmall,
            displaySmall: displaySmall,
            displayMedium: displayMedium,
            displayLarge: displayLarge,
            titleSmall: titleSmall,
            titleMedium: titleMedium,
            titleLarge: titleLarge,
            bodySmall: bodySmall,
            bodyMedium: bodyMedium,
            bodyLarge: bodyLarge,
            labelLarge: labelLarge,
            labelMedium: labelMedium,
            labelSmall: labelSmall)
        .apply(displayColor: primaryColor, fontFamily: fontFamily);
  }
}
