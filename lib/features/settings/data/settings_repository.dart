import 'package:shared_preferences/shared_preferences.dart';
import 'package:verso/data/local/entities/user_settings.dart';

class SettingsRepository {
  // Key constants
  static const _kThemeModeKey = 'theme_mode';
  static const _kUseAmoledKey = 'use_amoled_for_dark';
  static const _kScheduleEnabledKey = 'schedule_enabled';
  static const _kDayStyleKey = 'day_style';
  static const _kNightStyleKey = 'night_style';
  static const _kDayStartHourKey = 'day_start_hour';
  static const _kDayStartMinuteKey = 'day_start_minute';
  static const _kNightStartHourKey = 'night_start_hour';
  static const _kNightStartMinuteKey = 'night_start_minute';
  static const _kReminderEnabledKey = 'is_reminder_enabled';
  static const _kReminderHourKey = 'reminder_hour';
  static const _kReminderMinuteKey = 'reminder_minute';
  static const _kOnboardingKey = 'has_seen_onboarding';
  static const _kThemeProfileKey = 'theme_profile_id';
  // Legacy key - migrated on first read
  static const _kLegacyThemeKey = 'is_dark_mode';

  Future<UserSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // One-time migration from v1 boolean to v2 string
    if (!prefs.containsKey(_kThemeModeKey) &&
        prefs.containsKey(_kLegacyThemeKey)) {
      final wasDark = prefs.getBool(_kLegacyThemeKey) ?? false;
      await prefs.setString(_kThemeModeKey, wasDark ? 'dark' : 'light');
      await prefs.remove(_kLegacyThemeKey);
    }

    return UserSettings(
      themeMode: _parseThemeMode(prefs.getString(_kThemeModeKey)),
      useAmoledForDark: prefs.getBool(_kUseAmoledKey) ?? false,
      scheduleEnabled: prefs.getBool(_kScheduleEnabledKey) ?? false,
      dayStyle:
          _parseStyle(prefs.getString(_kDayStyleKey)) ?? AppearanceStyle.light,
      nightStyle:
          _parseStyle(prefs.getString(_kNightStyleKey)) ?? AppearanceStyle.dark,
      dayStartHour: prefs.getInt(_kDayStartHourKey) ?? 6,
      dayStartMinute: prefs.getInt(_kDayStartMinuteKey) ?? 30,
      nightStartHour: prefs.getInt(_kNightStartHourKey) ?? 22,
      nightStartMinute: prefs.getInt(_kNightStartMinuteKey) ?? 0,
      isReminderEnabled: prefs.getBool(_kReminderEnabledKey) ?? false,
      reminderHour: prefs.getInt(_kReminderHourKey) ?? 7,
      reminderMinute: prefs.getInt(_kReminderMinuteKey) ?? 0,
      themeProfileId: prefs.getString(_kThemeProfileKey) ?? 'current',
    );
  }

  // Check if onboarding is complete
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingKey) ?? false;
  }

  // Mark onboarding as complete
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingKey, true);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.name);
  }

  Future<void> setUseAmoledForDark(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUseAmoledKey, value);
  }

  Future<void> setSchedule({
    required bool enabled,
    required AppearanceStyle dayStyle,
    required AppearanceStyle nightStyle,
    required int dayStartHour,
    required int dayStartMinute,
    required int nightStartHour,
    required int nightStartMinute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kScheduleEnabledKey, enabled);
    await prefs.setString(_kDayStyleKey, dayStyle.name);
    await prefs.setString(_kNightStyleKey, nightStyle.name);
    await prefs.setInt(_kDayStartHourKey, dayStartHour);
    await prefs.setInt(_kDayStartMinuteKey, dayStartMinute);
    await prefs.setInt(_kNightStartHourKey, nightStartHour);
    await prefs.setInt(_kNightStartMinuteKey, nightStartMinute);
  }

  Future<void> setThemeProfileId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeProfileKey, id);
  }

  Future<void> updateReminder(bool isEnabled, int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminderEnabledKey, isEnabled);
    await prefs.setInt(_kReminderHourKey, hour);
    await prefs.setInt(_kReminderMinuteKey, minute);
  }

  static AppThemeMode _parseThemeMode(String? value) {
    return switch (value) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };
  }

  static AppearanceStyle? _parseStyle(String? value) {
    return switch (value) {
      'light' => AppearanceStyle.light,
      'dark' => AppearanceStyle.dark,
      'amoled' => AppearanceStyle.amoled,
      _ => null,
    };
  }
}
