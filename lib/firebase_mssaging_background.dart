import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'main.dart'; // Import the global plugin instance

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Ensure Firebase is initialized in background
  _showLocalNotification(message.notification?.title ?? 'New Signal', message.notification?.body ?? 'Check the app for details');
}