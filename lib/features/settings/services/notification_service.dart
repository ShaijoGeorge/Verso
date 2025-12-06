import 'package:flutter/services.dart'; // Required for MethodChannel
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // Add Firebase Messaging Instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Channel to communicate with Native Code (Android/iOS)
  static const MethodChannel _platform = MethodChannel('com.example.biblia/timezone');

  Future<void> init() async {
    tz.initializeTimeZones();

    // 1. GET DEVICE TIMEZONE (Native Call)
    try {
      final String timeZoneName = await _platform.invokeMethod('getLocalTimezone');
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to UTC if native call fails
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 2. Android Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS Settings
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false, 
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // 4. Initialize Local Plugin
    await _notificationsPlugin.initialize(
      InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // --- NEW: FIREBASE CLOUD MESSAGING SETUP ---
    
    // A. Request Push Notification Permission (Required for iOS & Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 1. Get the Token
      final fcmToken = await _firebaseMessaging.getToken();
      print("FCM Token: $fcmToken");

      // 2. SAVE TOKEN TO SUPABASE (New Code)
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null && fcmToken != null) {
        try {
          await Supabase.instance.client.from('profiles').upsert({
            'id': userId,
            'fcm_token': fcmToken,
            'updated_at': DateTime.now().toIso8601String(),
          });
          print("FCM Token saved to database!");
        } catch (e) {
          print("Error saving token: $e");
        }
      }
      
      // 3. Listen for Token Refreshes (Important!)
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        if (userId != null) {
           await Supabase.instance.client.from('profiles').upsert({
            'id': userId,
            'fcm_token': newToken,
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      });
    }

    // B. Get the Device Token 
    // (You will copy this token from the Debug Console to send test messages)
    final fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fcmToken"); 

    // C. Handle Foreground Messages
    // This listens for messages while the app is OPEN and shows a notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showForegroundNotification(message);
    });
  }

  // --- NEW: Helper to show Push Notifications when app is open ---
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    // If the message has a notification payload, show it locally
    if (notification != null && android != null) {
      await _notificationsPlugin.show(
        notification.hashCode, // Use hashcode as ID
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // Channel ID
            'High Importance Notifications', // Channel Name
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    await cancelReminders();

    await _notificationsPlugin.zonedSchedule(
      0, 
      'Bible Reading Time', 
      'Time to read your daily chapters! 📖', 
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder', 
          'Daily Reminder', 
          channelDescription: 'Daily Bible reading reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminders() async {
    await _notificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}