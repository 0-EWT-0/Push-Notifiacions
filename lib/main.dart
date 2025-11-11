import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'core/notifications/notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final svc = NotificationService();

  final data = message.data;
  final title = data['title'] ?? message.notification?.title ?? 'Notificación';
  final body = data['body'] ?? message.notification?.body ?? '';
  final imageUrl = data['imageUrl'] as String?;

  await svc.showLocal(
    title: title,
    body: body,
    payload: data['payload'],
    imageUrl: imageUrl,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Handler para mensajes en background
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await _setupFirebaseMessaging();

  runApp(const ProviderScope(child: TurismoApp()));
}

Future<void> _setupFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(alert: true, badge: true, sound: true);

  final token = await messaging.getToken();
  debugPrint('FCM Token: $token');

  FirebaseMessaging.onMessage.listen((message) async {
    final svc = NotificationService();

    final data = message.data;
    final title =
        data['title'] ?? message.notification?.title ?? 'Notificación';
    final body = data['body'] ?? message.notification?.body ?? '';
    final imageUrl = data['imageUrl'] as String?;

    await svc.showLocal(
      title: title,
      body: body,
      payload: data['payload'],
      imageUrl: imageUrl,
    );
  });


  FirebaseMessaging.onMessageOpenedApp.listen((message) {
  });
}
