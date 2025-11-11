import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart'
    as http; 

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
      },
    );

    _initialized = true;
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<String> _assetToFile(String assetPath, String fileName) async {
    final bytes = await rootBundle.load(assetPath);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    return file.path;
  }

  Future<void> showLocal({
    required String title,
    required String body,
    String? payload,
    String? imageUrl, 
    String? assetImage, 
  }) async {
    await init();

    AndroidNotificationDetails androidDetails;

    if (assetImage != null && assetImage.isNotEmpty) {
      // Usar imagen que ya viene como asset
      final bigPicturePath = await _assetToFile(
        assetImage,
        'bigPicture_asset.jpg',
      );

      final styleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        contentTitle: title,
        summaryText: body,
      );

      androidDetails = AndroidNotificationDetails(
        'turismo_channel',
        'Turismo Notificaciones',
        channelDescription: 'Novedades turísticas',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: styleInformation,
      );
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      final bigPicturePath = await _downloadAndSaveFile(
        imageUrl,
        'bigPicture_url.jpg',
      );

      final styleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        contentTitle: title,
        summaryText: body,
      );

      androidDetails = AndroidNotificationDetails(
        'turismo_channel',
        'Turismo Notificaciones',
        channelDescription: 'Novedades turísticas',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: styleInformation,
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        'turismo_channel',
        'Turismo Notificaciones',
        channelDescription: 'Novedades turísticas',
        importance: Importance.max,
        priority: Priority.high,
      );
    }

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
