import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

Future<String> getDeviceId() async {
  if (kIsWeb) {
    return const Uuid().v4();
  }

  final deviceInfo = DeviceInfoPlugin();

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    case TargetPlatform.iOS:
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? const Uuid().v4();
    default:
      return const Uuid().v4();
  }
}
