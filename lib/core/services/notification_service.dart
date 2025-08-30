import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../router/app_router.dart';
import '../router/app_router.gr.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance {
    _instance ??= NotificationService._init();
    return _instance!;
  }

  NotificationService._init();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Yüksek Öncelikli Bildirimler',
    description: 'Bu kanal önemli bildirimleri gösterir',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    debugPrint('\n=== Bildirim Servisi Başlatılıyor ===');

    if (kDebugMode) {
      debugPrint('Debug modda bildirim servisi başlatıldı');
    }

    // Firebase Messaging izinleri
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('Bildirim izin durumu: ${settings.authorizationStatus}');

    // FCM Token al ve API'ye gönder
    final token = await _messaging.getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
      await sendFCMTokenToServer(token);
    }

    // Android bildirim kanalı oluştur
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Local Notifications ayarları
    await _setupLocalNotifications();

    // Foreground mesajları
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/Terminated mesajları
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Token yenilendiğinde
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token yenilendi: $newToken');
      sendFCMTokenToServer(newToken);
    });

    debugPrint('=== Bildirim Servisi Başlatıldı ===\n');
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground mesajı alındı:');
    debugPrint('Başlık: ${message.notification?.title}');
    debugPrint('İçerik: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    await _showLocalNotification(message);
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Background mesajı tıklandı:');
    debugPrint('Route: ${message.data['route']}');
    _navigateToRoute(message.data['route']);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            androidChannel.id,
            androidChannel.name,
            channelDescription: androidChannel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_notification',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['route'],
      );
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      debugPrint('Bildirim tıklandı. Route: ${response.payload}');
      _navigateToRoute(response.payload);
    }
  }

  void _navigateToRoute(String? route) {
    if (route == null) return;

    switch (route) {
      case 'home':
        router.push(const HomeRoute());
        break;
      case 'search':
        router.push(const SearchRoute());
        break;
      case 'favorites':
        router.push(const FavoritesRoute());
        break;
      case 'profile':
        router.push(const ProfileRoute());
        break;
      default:
        debugPrint('Bilinmeyen route: $route');
    }
  }

  Future<void> sendFCMTokenToServer(String token) async {
    try {
      // TODO: Token'ı API'ye gönder
      debugPrint('Token API\'ye gönderiliyor: $token');
    } catch (e) {
      debugPrint('Token gönderilirken hata: $e');
    }
  }
}
