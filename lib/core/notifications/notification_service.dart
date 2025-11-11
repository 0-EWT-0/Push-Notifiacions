import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Future<void>? _initFuture;

  Future<void> init() async {
    if (_initialized) return;
    if (_initFuture != null) return _initFuture;

    _initFuture = _doInit();
    await _initFuture;
    _initialized = true;
  }

  Future<void> _doInit() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _local.initialize(settings);

    if (Platform.isAndroid) {
      final android = _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
    }

    final ios = _local
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    const channel = AndroidNotificationChannel(
      'default_channel',
      'General',
      description: 'Canal de notificaciones generales',
      importance: Importance.high,
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> showLocal({
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'General',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }
}
