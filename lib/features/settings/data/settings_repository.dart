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
  // Profile Setup keys (collected before login)
  static const _kProfileSetupKey = 'has_completed_profile_setup';
  static const _kUserGenderKey = 'user_gender';
  static const _kUserBirthdayKey = 'user_birthday';
  static const _kThemeProfileKey = 'theme_profile_id';
  static const _kFontScaleFactorKey = 'in_app_font_scale_factor';
  static const _kCanonTypeKey = 'canon_type';
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
      fontScaleFactor: prefs.getDouble(_kFontScaleFactorKey) ?? 1.0,
      canonType: prefs.getString(_kCanonTypeKey) ?? 'catholic',
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

  // ── Profile Setup ────────────────────────────────────────────────────────

  String _getUserKey(String baseKey, String userId) {
    return '${baseKey}_$userId';
  }

  /// Returns true once the user has submitted the profile-setup screen.
  Future<bool> hasCompletedProfileSetup(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getUserKey(_kProfileSetupKey, userId)) ?? false;
  }

  /// Persists gender ('male' | 'female') and birthday (ISO-8601 date string).
  Future<void> saveUserProfile({
    required String userId,
    required String gender,
    required DateTime birthday,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getUserKey(_kUserGenderKey, userId), gender);
    // Store as a plain date string so it survives encoding/decoding
    await prefs.setString(
      _getUserKey(_kUserBirthdayKey, userId),
      '${birthday.year.toString().padLeft(4, '0')}-'
      '${birthday.month.toString().padLeft(2, '0')}-'
      '${birthday.day.toString().padLeft(2, '0')}',
    );
    await prefs.setBool(_getUserKey(_kProfileSetupKey, userId), true);
  }

  /// Returns the saved gender, or null if not yet set.
  Future<String?> getUserGender(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_getUserKey(_kUserGenderKey, userId));
  }

  /// Returns the saved birthday as a DateTime, or null if not yet set.
  Future<DateTime?> getUserBirthday(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_getUserKey(_kUserBirthdayKey, userId));
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  // ── Theme ─────────────────────────────────────────────────────────────────

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

  Future<void> setFontScaleFactor(double factor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontScaleFactorKey, factor);
  }

  Future<void> setCanonType(String canonType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCanonTypeKey, canonType);
  }

  Future<void> updateCanonSetting(String canonString) =>
      setCanonType(canonString);

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
