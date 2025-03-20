import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    try {
      await _localNotificationsPlugin.initialize(initializationSettings);
      print('Local notifications initialized successfully');
    } catch (e) {
      print('Error initializing local notifications: $e');
      rethrow; // Optionally rethrow if critical
    }
  }

  Future<void> showNotification({
    required String? title,
    required String? body,
    String? imageUrl,
  }) async {
    BigPictureStyleInformation? bigPictureStyleInformation;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final ByteArrayAndroidBitmap largeIcon = await _downloadAndSaveImage(imageUrl, 'largeIcon');
        final ByteArrayAndroidBitmap bigPicture = await _downloadAndSaveImage(imageUrl, 'bigPicture');
        bigPictureStyleInformation = BigPictureStyleInformation(
          bigPicture,
          largeIcon: largeIcon,
          contentTitle: title,
          summaryText: body,
        );
      } catch (e) {
        print('Error downloading notification image: $e');
        // Proceed without image if download fails
      }
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics = DarwinNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    try {
      await _localNotificationsPlugin.show(
        0,
        title ?? 'Notification',
        body ?? 'No content',
        platformChannelSpecifics,
      );
      print('Notification shown successfully');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<ByteArrayAndroidBitmap> _downloadAndSaveImage(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      await File(filePath).writeAsBytes(response.bodyBytes);
      final Uint8List imageBytes = await File(filePath).readAsBytes();
      return ByteArrayAndroidBitmap(imageBytes);
    } else {
      throw Exception('Error downloading image: ${response.statusCode}');
    }
  }
}