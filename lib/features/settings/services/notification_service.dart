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

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    _isInitialized = await _notificationsPlugin.initialize(settings) ?? false;
  }

  /// Timezone setup
  Future<void> _initializeTimezone() async {
    tz.initializeTimeZones();

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to Asia/Kolkata for Indian users
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }
  }

  /// Request permissions
  Future<bool> requestPermissions() async {
    final ios = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    final android = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    return (ios ?? true) && (android ?? true);
  }

  /// Schedule daily reminder
  Future<void> scheduleDailyReminder(int hour, int minute) async {
    if (!_isInitialized) await init();

    await cancelReminders();

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Notification permission denied');
    }

    final scheduled = _nextInstance(hour, minute);

    // Friendly notification messages (rotates based on day)
    final messages = [
      '✨ Ready for today\'s spiritual journey?',
      '🌟 Your daily dose of wisdom awaits!',
      '📖 Let\'s dive into God\'s Word together!',
      '💫 Time to nourish your soul!',
      '🙏 A few moments with Scripture today?',
      '⭐ Your reading streak is waiting!',
      '🌈 Start your day with inspiration!',
    ];
    
    final dayOfWeek = DateTime.now().weekday;
    final message = messages[dayOfWeek % messages.length];

    await _notificationsPlugin.zonedSchedule(
      0,
      'Bible Reading Time 📖',
      message,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily Bible reading reminder',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
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
  }

  /// Cancel all reminders
  Future<void> cancelReminders() async {
    if (!_isInitialized) await init();
    await _notificationsPlugin.cancelAll();
  }

  /// Helper: Find next instance of time
  tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var date = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (date.isBefore(now)) {
      date = date.add(const Duration(days: 1));
    }

    return date;
  }
}