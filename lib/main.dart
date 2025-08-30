import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/init/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/di/injection.dart';
import 'core/init/logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await Injection.init();
  
  // Initialize localization
  await EasyLocalization.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  logger.info('🚀 Application started successfully');
  
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      path: 'assets/lang',
      fallbackLocale: const Locale('tr', 'TR'),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Flutter Bloc Template',
            debugShowCheckedModeBanner: false,
            theme: ThemeManager.craeteTheme(AppThemeLight()),
            // ignore: deprecated_member_use
            useInheritedMediaQuery: true,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerDelegate: router.delegate(),
            routeInformationParser: router.defaultRouteParser(),
            builder: (context, child) {
              final mediaWrapped = MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
              return DevicePreview.appBuilder(context, mediaWrapped);
            },
          );
        },
      ),
    );
  }
}
