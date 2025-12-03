import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/local/entities/user_settings.dart';

class SettingsRepository {
  // Key constants
  static const _kThemeKey = 'is_dark_mode';
  static const _kReminderEnabledKey = 'is_reminder_enabled';
  static const _kReminderHourKey = 'reminder_hour';
  static const _kReminderMinuteKey = 'reminder_minute';

  Future<UserSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return UserSettings(
      isDarkMode: prefs.getBool(_kThemeKey) ?? false,
      isReminderEnabled: prefs.getBool(_kReminderEnabledKey) ?? false,
      reminderHour: prefs.getInt(_kReminderHourKey) ?? 7,
      reminderMinute: prefs.getInt(_kReminderMinuteKey) ?? 0,
    );
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kThemeKey, isDark);
  }

  Future<void> updateReminder(bool isEnabled, int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminderEnabledKey, isEnabled);
    await prefs.setInt(_kReminderHourKey, hour);
    await prefs.setInt(_kReminderMinuteKey, minute);
  }
}