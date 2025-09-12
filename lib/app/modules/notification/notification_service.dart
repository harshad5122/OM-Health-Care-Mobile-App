import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';



class NotificationService extends GetxService {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;

  Future<NotificationService> init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // app icon

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        _handleNotificationTap(response.payload);
      },
    );
    return this;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? imageUrl, // This can be used for images
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'chat_channel', // channel ID
      'Chat Messages', // channel name
      channelDescription: 'Channel for chat message notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: imageUrl != null
          ? BigPictureStyleInformation(
        FilePathAndroidBitmap(imageUrl),
        contentTitle: title,
        summaryText: body,
      )
          : null,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    // Add to notifications list
    notifications.insert(0, {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': DateTime.now(),
      'payload': payload,
    });
  }
  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      // Example: Navigate to proposal screen when notification is tapped
      Get.toNamed('/proposal/$payload');
    }
  }
}


