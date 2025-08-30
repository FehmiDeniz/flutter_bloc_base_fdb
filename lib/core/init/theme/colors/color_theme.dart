import 'package:flutter/material.dart';

@immutable
class AppColors {
  final white = Colors.white;
  final black = Colors.black;
  // Base neutral/brand‑free palette
  final pinkColor = const Color(0xFF2563EB); // primary (blue 600)
  final lightPinkColor = const Color(0xFFF3F4F6); // secondary background (gray 100)
  final errorColor = const Color(0xFFDC2626); // red 600
  final textColor = const Color(0xFF111827); // gray 900
  final grayColor = const Color(0xFF6B7280); // gray 500
  final successColor = const Color(0xFFF8FAFC); // surface (slate 50)
  final greyIconColor = const Color(0xFF9CA3AF); // gray 400
  final inputBgColor = const Color(0xFFFFFFFF);
  final inputBorderColor = const Color(0xFFE5E7EB); // gray 200
  final inputTextColor = const Color(0xFF111827); // gray 900
  final textFieldBorderColor = const Color(0xFFE5E7EB);
  final hintTextColor = const Color(0xFF9CA3AF); // gray 400
  final backgroundColor = const Color(0xFFFAFAFA); // gray 50
  final butonColor = const Color(0xFF111827); // gray 900
}

abstract class IColors {
  AppColors get colors;
  Color? backgroundColor;
  Color? buttonColor;
  //tum yazilar
  Color? textColor;
  Color? inputBackgroundColor;
  Color? inputBorderColor;
  Color? inputTextColor;
  Color? textFieldBorderColor;
  Color? hintTextColor;
  Color? appBarColor;
  Color? tabBarColor;

  ColorScheme? colorScheme;

  Brightness? brightness;
}
