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

  void Function(String? payload)? _onNotificationTap;

  /// Initialize the notification plugin
  Future<void> init({void Function(String? payload)? onNotificationTap}) async {
    if (onNotificationTap != null) {
      _onNotificationTap = onNotificationTap;
    }
    if (_isInitialized) {
      if (onNotificationTap != null) {
        final launchDetails =
            await _notificationsPlugin.getNotificationAppLaunchDetails();
        if (launchDetails?.didNotificationLaunchApp ?? false) {
          final payload = launchDetails!.notificationResponse?.payload;
          if (payload != null) {
            Future.delayed(const Duration(milliseconds: 600), () {
              _onNotificationTap?.call(payload);
            });
          }
        }
      }
      return;
    }

    await _initializeTimezone();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    _isInitialized = await _notificationsPlugin.initialize(
          settings: settings,
          onDidReceiveNotificationResponse: (response) {
            _onNotificationTap?.call(response.payload);
          },
        ) ??
        false;

    // Handle cold-start launch if the user tapped a notification while app was terminated
    final launchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails!.notificationResponse?.payload;
      if (payload != null) {
        Future.delayed(const Duration(milliseconds: 600), () {
          _onNotificationTap?.call(payload);
        });
      }
    }
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

    return (ios ?? true) && (android ?? true);
  }

  /// Dedicated notification IDs to prevent collisions between features
  static const int readingReminderNotificationId = 100;
  static const int dailyVerseNotificationId = 200;

  /// Dedicated IDs for the 6-stage streak countdown (300..305)
  static const List<int> streakEscalationIds = [300, 301, 302, 303, 304, 305];

  /// Dedicated Android notification channels
  static const String dailyReminderChannelId = 'daily_reminder';
  static const String dailyVerseChannelId = 'daily_verse_channel';

  /// Dedicated notification ID and channel for Birthday Wishes
  static const int birthdayNotificationId = 400;
  static const String birthdayChannelId = 'birthday_wish_channel';

  /// Dedicated high-urgency Android channel for streak countdowns
  static const String streakEscalationChannelId = 'streak_escalation_channel';

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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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

  /// Automatically schedules the evening countdown series:
  /// 8:00 PM, 11:00 PM (1h), 11:30 PM (30m), 11:50 PM (10m), 11:55 PM (5m), and 12:00 AM.
  ///
  /// - If [readToday] is `true`, today's alerts are cancelled and the sequence is
  ///   scheduled for **tomorrow night** (in case the user doesn't open the app tomorrow).
  /// - If [readToday] is `false`, any future slots remaining **tonight** are scheduled.
  Future<void> syncStreakEscalationAlerts({
    required int streak,
    required int availableFreezes,
    required bool isStreakFrozen,
    required bool readToday,
  }) async {
    if (!_isInitialized) await init();

    // Always clear previous escalation alarms first
    await cancelStreakEscalationAlerts();

    // Only pester users who actually have an active streak to lose
    if (streak <= 0) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    final now = tz.TZDateTime.now(tz.local);

    // Target date: Today if they haven't read yet; Tomorrow if they already read today
    final baseDate = readToday
        ? tz.TZDateTime(tz.local, now.year, now.month, now.day)
            .add(const Duration(days: 1))
        : tz.TZDateTime(tz.local, now.year, now.month, now.day);

    // If scheduling for tomorrow (because they read today), tomorrow they won't be "frozen"
    // going into the evening—they'll have an active flame of `streak`.
    final effectiveFrozen = !readToday && isStreakFrozen;

    final stages = <_StreakStage>[
      // 1. 8:00 PM — Friendly / Ice Warning
      _StreakStage(
        id: 300,
        scheduledTime: tz.TZDateTime(
          tz.local,
          baseDate.year,
          baseDate.month,
          baseDate.day,
          20,
        ),
        title: effectiveFrozen
            ? 'Your $streak-day streak is on thin ice!❄️'
            : 'Keep your $streak-day streak alive!🔥',
        body: effectiveFrozen
            ? 'A Streak Freeze saved you yesterday. Read 1 chapter tonight to relight your flame!'
            : 'Take 2 minutes with Scripture tonight so your $streak-day habit stays strong.',
      ),

      // 2. 11:00 PM — 1 Hour Left
      _StreakStage(
        id: 301,
        scheduledTime: tz.TZDateTime(
          tz.local,
          baseDate.year,
          baseDate.month,
          baseDate.day,
          23,
        ),
        title: '1 hour left to save your $streak-day streak!⏳',
        body: effectiveFrozen
            ? 'Your streak is already frozen! Read a chapter before midnight or risk losing it.'
            : "Don't let today slip by—read 1 chapter before midnight to hit ${streak + 1} days!",
      ),

      // 3. 11:30 PM — 30 Minutes Left
      _StreakStage(
        id: 302,
        scheduledTime: tz.TZDateTime(
          tz.local,
          baseDate.year,
          baseDate.month,
          baseDate.day,
          23,
          30,
        ),
        title: '30 minutes left! Streak in danger!🚨',
        body:
            'Only 30 minutes until midnight. Open Verso and log a chapter to protect your $streak-day streak!',
      ),

      // 4. 11:50 PM — 10 Minutes Left
      _StreakStage(
        id: 303,
        scheduledTime: tz.TZDateTime(
          tz.local,
          baseDate.year,
          baseDate.month,
          baseDate.day,
          23,
          50,
        ),
        title: '10 minutes left! Save your $streak-day streak!😱',
        body: availableFreezes > 0
            ? '10 minutes until midnight! Read now so you don’t burn a Streak Freeze!'
            : 'You have 0 Streak Freezes left! Read 1 chapter in the next 10 minutes or reset to 0!',
      ),

      // 5. 11:55 PM — 5 Minutes Left
      _StreakStage(
        id: 304,
        scheduledTime: tz.TZDateTime(
          tz.local,
          baseDate.year,
          baseDate.month,
          baseDate.day,
          23,
          55,
        ),
        title: '5 MINUTES LEFT! Final call for your $streak-day streak!🔥',
        body:
            'Midnight is 5 minutes away! Tap now to log a chapter and save your $streak-day streak!',
      ),

      // 6. 12:00 AM Midnight — Freeze Consumed OR Streak Broken Verdict
      _StreakStage(
        id: 305,
        scheduledTime: tz.TZDateTime(
          tz.local,
          baseDate.year,
          baseDate.month,
          baseDate.day,
        ).add(const Duration(days: 1)), // 00:00:00 Midnight
        title: availableFreezes > 0
            ? 'Phew! Streak Freeze Equipped!🧊'
            : 'Your $streak-day streak was lost...💔',
        body: availableFreezes > 0
            ? 'You missed reading today, so 1 Streak Freeze was automatically used to save your $streak-day streak! (${availableFreezes - 1} left)'
            : 'Midnight passed with no Streak Freezes left. Open Verso today to start a brand new streak!',
      ),
    ];

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        streakEscalationChannelId,
        'Streak Saver Alerts',
        channelDescription:
            'Urgent evening countdowns to protect your reading streak',
        importance: Importance.max,
        priority: Priority.max,
        styleInformation: BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    for (final stage in stages) {
      // Only schedule alerts that are still in the future
      if (stage.scheduledTime.isAfter(now)) {
        await _notificationsPlugin.zonedSchedule(
          id: stage.id,
          title: stage.title,
          body: stage.body,
          scheduledDate: stage.scheduledTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'streak_escalation_${stage.id}',
        );
      }
    }
  }

  /// Cancels all 6 countdown notifications.
  Future<void> cancelStreakEscalationAlerts() async {
    if (!_isInitialized) await init();
    for (final id in streakEscalationIds) {
      await _notificationsPlugin.cancel(id: id);
    }
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

  /// Schedules an annual birthday notification at 8:00 AM local time.
  Future<void> scheduleBirthdayNotification({
    required DateTime birthday,
    String? userName,
    int hour = 8,
    int minute = 0,
  }) async {
    if (!_isInitialized) await init();

    await cancelBirthdayNotification();

    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    final scheduledDate = _nextBirthdayInstance(
      birthday.month,
      birthday.day,
      hour,
      minute,
    );

    final cleanName = userName?.trim();
    final title = (cleanName != null && cleanName.isNotEmpty)
        ? 'Happy Birthday, $cleanName! 🎂'
        : 'Happy Birthday! 🎂';

    const body =
        'May the Lord bless you and keep you in this new year of your life! Tap for your birthday blessing ✨';

    await _notificationsPlugin.zonedSchedule(
      id: birthdayNotificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          birthdayChannelId,
          'Birthday Wishes',
          channelDescription: 'Annual birthday blessing and Scripture verse',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: 'birthday_wish',
    );
  }

  /// Cancel only the birthday notification
  Future<void> cancelBirthdayNotification() async {
    if (!_isInitialized) await init();
    await _notificationsPlugin.cancel(id: birthdayNotificationId);
  }

  /// Helper: Find next occurrence of [month]/[day] at [hour]:[minute]
  /// Safely handles Feb 29 on non-leap years by celebrating on Feb 28.
  tz.TZDateTime _nextBirthdayInstance(
    int month,
    int day,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime buildForYear(int year) {
      final isLeapYear =
          (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
      final safeDay = (month == 2 && day == 29 && !isLeapYear) ? 28 : day;
      return tz.TZDateTime(tz.local, year, month, safeDay, hour, minute);
    }

    var scheduled = buildForYear(now.year);
    if (scheduled.isBefore(now)) {
      scheduled = buildForYear(now.year + 1);
    }
    return scheduled;
  }
}

class _StreakStage {
  const _StreakStage({
    required this.id,
    required this.scheduledTime,
    required this.title,
    required this.body,
  });

  final int id;
  final tz.TZDateTime scheduledTime;
  final String title;
  final String body;
}
