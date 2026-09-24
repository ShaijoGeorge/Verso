import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification plugin
  Future<void> init() async {
    if (_isInitialized) return;

    await _initializeTimezone();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    _isInitialized =
        await _notificationsPlugin.initialize(settings: settings) ?? false;
  }

  /// Timezone setup
  Future<void> _initializeTimezone() async {
    tz.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
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

  /// Dedicated notification IDs to prevent collisions between features
  static const int readingReminderNotificationId = 100;
  static const int dailyVerseNotificationId = 200;

  /// Dedicated Android notification channels
  static const String dailyReminderChannelId = 'daily_reminder';
  static const String dailyVerseChannelId = 'daily_verse_channel';

  /// Schedule daily reading reminder
  Future<void> scheduleDailyReminder(int hour, int minute) async {
    if (!_isInitialized) await init();

    // Cancel ONLY the reading reminder to avoid wiping out the daily verse!
    await cancelDailyReminder();

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Notification permission denied');
    }

    final scheduled = _nextInstance(hour, minute);

    // Friendly notification messages (rotates based on day)
    final messages = [
      "✨ Ready for today's spiritual journey?",
      '🌟 Your daily dose of wisdom awaits!',
      "📖 Let's dive into God's Word together!",
      '💫 Time to nourish your soul!',
      '🙏 A few moments with Scripture today?',
      '⭐ Your reading streak is waiting!',
      '🌈 Start your day with inspiration!',
    ];

    final dayOfWeek = DateTime.now().weekday;
    final message = messages[dayOfWeek % messages.length];

    await _notificationsPlugin.zonedSchedule(
      id: readingReminderNotificationId,
      title: 'Bible Reading Time 📖',
      body: message,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          dailyReminderChannelId,
          'Daily Reading Reminder',
          channelDescription: 'Daily Bible reading streak and plan reminder',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'reading_reminder',
    );
  }

  /// Schedule daily verse notification (default at 6:00 AM)
  Future<void> scheduleDailyVerseNotification({
    int hour = 6,
    int minute = 0,
  }) async {
    if (!_isInitialized) await init();

    // Cancel previous daily verse schedule before setting new one
    await cancelDailyVerseNotification();

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Notification permission denied');
    }

    final scheduled = _nextInstance(hour, minute);

    // Morning inspirational messages encouraging users to start their day with Scripture
    final morningMessages = [
      'Begin your morning with God’s Word. Tap to read today’s verse 🌅',
      'Start your day grounded in grace and truth 📖',
      'Good morning! Your daily verse is ready to inspire you ✨',
      'A fresh day, a fresh word from Scripture 🙏',
      'Fuel your spirit before starting your day 💫',
      'Step into today with peace and divine wisdom ☀️',
      'The morning is here! Discover today’s verse of the day 🌟',
    ];

    final dayOfWeek = DateTime.now().weekday;
    final message = morningMessages[dayOfWeek % morningMessages.length];

    await _notificationsPlugin.zonedSchedule(
      id: dailyVerseNotificationId,
      title: 'Verse of the Day 🌅',
      body: message,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          dailyVerseChannelId,
          'Daily Verse',
          channelDescription: 'Daily morning Scripture verse at 6:00 AM',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_verse',
    );
  }

  /// Cancel only daily verse notification
  Future<void> cancelDailyVerseNotification() async {
    if (!_isInitialized) await init();
    await _notificationsPlugin.cancel(id: dailyVerseNotificationId);
  }

  /// Cancel only the daily reading reminder
  Future<void> cancelDailyReminder() async {
    if (!_isInitialized) await init();
    await _notificationsPlugin.cancel(id: readingReminderNotificationId);
  }

  /// Deprecated alias kept for backwards compatibility with existing UI callers
  Future<void> cancelReminders() => cancelDailyReminder();

  /// Cancel all notifications across all features (e.g., on sign out or full reset)
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await init();
    await _notificationsPlugin.cancelAll();
  }

  /// Helper: Find next instance of time
  tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var date =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (date.isBefore(now)) {
      date = date.add(const Duration(days: 1));
    }

    return date;
  }
}
