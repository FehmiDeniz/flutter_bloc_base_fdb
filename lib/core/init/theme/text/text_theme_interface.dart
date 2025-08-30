import 'package:flutter/material.dart';

abstract class ITextTheme {
  final Color? primaryColor;
  late final TextTheme data;
  TextStyle? displaySmall;
  TextStyle? displayMedium;
  TextStyle? displayLarge;
  TextStyle? headlineLarge;
  TextStyle? headlineMedium;
  TextStyle? headlineSmall;
  TextStyle? titleLarge;
  TextStyle? titleMedium;
  TextStyle? titleSmall;
  TextStyle? bodyLarge;
  TextStyle? bodyMedium;
  TextStyle? bodySmall;
  TextStyle? labelLarge;
  TextStyle? labelMedium;
  TextStyle? labelSmall;
  String? fontFamily;

  ITextTheme(this.primaryColor);
}
