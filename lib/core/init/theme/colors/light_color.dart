import 'package:flutter/material.dart';

import 'color_theme.dart';

class LightColors implements IColors {
  LightColors() {
    brightness = Brightness.light;
    colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: colors.pinkColor,
      onPrimary: colors.textColor, // app-wide text color
      secondary: colors.lightPinkColor,
      onSecondary: colors.grayColor,
      error: colors.errorColor,
      onError: colors.white,
      surface: colors.successColor,
      onSurface: colors.greyIconColor,
      tertiary: colors.inputBgColor,
      onTertiary: colors.inputBorderColor,
      tertiaryContainer: colors.inputTextColor,
      scrim: colors.butonColor, // used as button background in app
      inversePrimary: colors.black,
      inverseSurface: colors.white,
    );
  }

  @override
  AppColors get colors => AppColors();

  @override
  Color? appBarColor;

  @override
  Color? backgroundColor;

  @override
  Brightness? brightness;

  @override
  Color? buttonColor;

  @override
  ColorScheme? colorScheme;

  @override
  Color? hintTextColor;

  @override
  Color? inputBackgroundColor;

  @override
  Color? inputBorderColor;

  @override
  Color? inputTextColor;

  @override
  Color? tabBarColor;

  @override
  Color? textColor;

  @override
  Color? textFieldBorderColor;
}
