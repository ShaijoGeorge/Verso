import 'dart:developer' as log;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification plugin
  Future<void> init() async {
    if (_isInitialized) return;

    await _initializeTimezone();

    final settings = _initSettings();
    final didInit = await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = didInit ?? false;
    log.log('Notifications initialized: $_isInitialized',
        name: 'NotificationService');
  }

  /// Timezone setup with better fallback
  Future<void> _initializeTimezone() async {
    tz.initializeTimeZones();

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      log.log('Device timezone: $timeZoneName', name: 'NotificationService');
      
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      
      // Verify timezone is correct
      final now = tz.TZDateTime.now(tz.local);
      log.log('Current time in device timezone: $now', name: 'NotificationService');
      
    } catch (e) {
      log.log('Error getting timezone: $e', name: 'NotificationService');
      
      // Better fallback: Try to use Asia/Kolkata for Indian users
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
        log.log('Fallback to Asia/Kolkata timezone', name: 'NotificationService');
      } catch (fallbackError) {
        // Last resort: UTC
        tz.setLocalLocation(tz.UTC);
        log.log('Final fallback to UTC', name: 'NotificationService');
      }
    }
  }

  InitializationSettings _initSettings() {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    return const InitializationSettings(android: android, iOS: ios);
  }

  void _onNotificationTap(NotificationResponse response) {
    log.log('Notification tapped: ${response.payload}',
        name: 'NotificationService');
  }

  /// Ask for permissions with exact alarm permission for Android 12+
  Future<bool> requestPermissions() async {
    // iOS permissions
    final ios = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android notification permission (Android 13+)
    final android = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request exact alarm permission (Android 12+)
    final exactAlarm = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    final granted = (ios ?? true) && (android ?? true);

    log.log('Notification permissions: $granted, Exact Alarms: $exactAlarm',
        name: 'NotificationService');

    return granted;
  }

  /// Check if app can schedule exact alarms
  Future<bool> canScheduleExactNotifications() async {
    if (!_isInitialized) await init();

    final canSchedule = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.canScheduleExactNotifications();

    return canSchedule ?? true;
  }

  /// Check if app is allowed to show notifications
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) await init();

    final android = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    return android ?? true;
  }

  /// Daily reminder scheduler with better error handling
  Future<void> scheduleDailyReminder(int hour, int minute) async {
    if (!_isInitialized) await init();

    await cancelReminders();

    // Check permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      log.log('No permission, cannot schedule reminder',
          name: 'NotificationService');
      throw Exception('Notification permission denied');
    }

    // Check exact alarm permission
    final canSchedule = await canScheduleExactNotifications();
    if (!canSchedule) {
      log.log('Cannot schedule exact alarms', name: 'NotificationService');
      throw Exception('Exact alarm permission denied. Please enable it in Settings.');
    }

    final scheduled = _nextInstance(hour, minute);

    log.log('Scheduling reminder for: $scheduled (${scheduled.timeZoneName})',
        name: 'NotificationService');
    
    // Log what time it will show in user's perspective
    final localTime = scheduled.toLocal();
    log.log('Will show at: ${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}',
        name: 'NotificationService');

    try {
      await _notificationsPlugin.zonedSchedule(
        0,
        'Bible Reading Time 📖',
        'Time to read your daily chapters!',
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily Reminder',
            channelDescription: 'Daily Bible reading reminder',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            // Additional flags for reliability
            ongoing: false,
            autoCancel: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      log.log('Daily reminder scheduled successfully!',
          name: 'NotificationService');
    } catch (e, st) {
      log.log('Failed to schedule reminder: $e',
          name: 'NotificationService', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelReminders() async {
    if (!_isInitialized) await init();
    await _notificationsPlugin.cancelAll();
    log.log('All reminders cancelled', name: 'NotificationService');
  }

  /// Helper: Find next instance of [hour:minute]
  tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var date = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);

    if (date.isBefore(now)) {
      date = date.add(const Duration(days: 1));
    }

    return date;
  }

  /// Get list of pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) await init();
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Debug test notification
  Future<void> showTestNotification() async {
    if (!_isInitialized) await init();

    final now = DateTime.now();
    final timeString = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    
    await _notificationsPlugin.show(
      999,
      'Test Notification ✅',
      'Sent at $timeString. Notifications are working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Test notifications to verify setup',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    log.log('Test notification shown at $timeString', name: 'NotificationService');
  }
}