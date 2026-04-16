import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'signals_channel', 'Signal Alerts',
    channelDescription: 'Notifications for new trading signals',
    importance: Importance.max, priority: Priority.high,
  );
  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
  await _localNotifications.show(
    0,
    message.notification?.title ?? 'New Signal',
    message.notification?.body ?? 'Check the app for details',
    platformDetails,
  );
}