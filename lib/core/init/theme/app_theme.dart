import 'package:flutter/material.dart';

import 'colors/color_theme.dart';
import 'colors/light_color.dart';
import 'text/text_theme_interface.dart';
import 'text/text_theme_light.dart';

abstract class ITheme {
  ITextTheme get textTheme;
  IColors get colors;
}

class AppThemeLight extends ITheme {
  @override
  ITextTheme get textTheme => TextThemeLight(primaryColor: AppColors().textColor);

  @override
  IColors get colors => LightColors();
}

abstract class ThemeManager {
  static ThemeData craeteTheme(ITheme theme) => ThemeData(
        fontFamily: theme.textTheme.fontFamily,
        textTheme: theme.textTheme.data,
        appBarTheme: AppBarTheme(
          centerTitle: false,
          iconTheme: IconThemeData(color: theme.colors.colors.textColor),
          backgroundColor: AppColors().backgroundColor,
          titleTextStyle: theme.textTheme.data.titleMedium?.copyWith(
            color: theme.colors.colors.textColor,
          ),
        ),
        scaffoldBackgroundColor: AppColors().backgroundColor,
        colorScheme: theme.colors.colorScheme,
      );
}
