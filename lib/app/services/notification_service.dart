import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    
    // Request permission immediately on init (or can be called later)
    await requestPermissions();
  }

  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
      
      // Also needed for exact alarms if scheduling is used
      // if (await Permission.scheduleExactAlarm.isDenied) {
      //   await Permission.scheduleExactAlarm.request();
      // }
    } else if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  static Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      // For iOS, we assume permission is granted if user hasn't explicitly denied
      // We could enhance this with more specific checks if needed
      return true;
    }
    return false;
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      // Check permissions before showing notification
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        print('Notification permission not granted. Requesting...');
        await requestPermissions();

        // Check again after requesting
        final hasPermissionAfterRequest = await checkPermissions();
        if (!hasPermissionAfterRequest) {
          print('Notification permission denied by user.');
          return;
        }
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'koala_daily_alerts',
        'Daily Alerts',
        channelDescription: 'Daily budget and summary alerts',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails();

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(
              android: androidPlatformChannelSpecifics,
              iOS: iosNotificationDetails);

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
      );
    } catch (e) {
      print('Error showing notification: $e');
      // Don't throw - gracefully handle notification failures
    }
  }

  static Future<void> showWelcomeNotification() async {
    await showNotification(
      id: 100, // A unique ID for the welcome notification
      title: 'Bienvenue sur Koala !',
      body: 'Commencez à gérer vos finances dès aujourd\'hui. Enregistrez votre première transaction !',
    );
  }
}
