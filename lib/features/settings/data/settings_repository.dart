import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  static const _kDailyVerseEnabledKey = 'is_daily_verse_enabled';
  static const _kOnboardingKey = 'has_seen_onboarding';
  // Profile Setup keys (collected before login)
  static const _kProfileSetupKey = 'has_completed_profile_setup';
  static const _kUserGenderKey = 'user_gender';
  static const _kUserBirthdayKey = 'user_birthday';
  static const _kThemeProfileKey = 'theme_profile_id';
  static const _kFontScaleFactorKey = 'in_app_font_scale_factor';
  static const _kCanonTypeKey = 'canon_type';
  static const _kBibleLanguageKey = 'bible_language';
  // Legacy key - migrated on first read
  static const _kLegacyThemeKey = 'is_dark_mode';

  // Key for tracking the last active user so the login screen can show
  // a sensible theme instead of jarring defaults.
  static const _kLastActiveUserIdKey = 'last_active_user_id';
  // Tracks the last local calendar date (YYYY-MM-DD) a daily read was celebrated
  static const _kLastCelebratedReadDateKey = 'last_celebrated_read_date';

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns a user-scoped SharedPreferences key.
  /// e.g. 'theme_mode' + 'abc-123' → 'theme_mode_abc-123'
  String _userKey(String baseKey, String userId) => '${baseKey}_$userId';

  /// Returns the userId to scope settings with.
  /// Priority: explicit userId → current Supabase user → null (global fallback).
  String? _resolveUserId(String? explicitUserId) {
    if (explicitUserId != null && explicitUserId.isNotEmpty) {
      return explicitUserId;
    }
    // Try current session
    final currentId = Supabase.instance.client.auth.currentUser?.id;
    if (currentId != null && currentId.isNotEmpty) return currentId;
    return null;
  }

  /// Reads from user-scoped key first; falls back to global key.
  /// This provides seamless migration: old global settings are picked up
  /// until the first write creates a user-scoped copy.
  T? _readScoped<T>(
    SharedPreferences prefs,
    String baseKey,
    String? userId,
    T? Function(String key) reader,
  ) {
    if (userId != null) {
      final scoped = reader(_userKey(baseKey, userId));
      if (scoped != null) return scoped;
    }
    // Fallback to global key (legacy or login-screen scenario)
    return reader(baseKey);
  }

  /// Writes to user-scoped key. Also writes to the global key so the
  /// login screen (no user context) always reflects the last-used value.
  Future<void> _writeScoped(
    SharedPreferences prefs,
    String baseKey,
    String? userId,
    Future<void> Function(String key) writer,
  ) async {
    if (userId != null) {
      await writer(_userKey(baseKey, userId));
    }
    // Always keep the global key updated as a fallback
    await writer(baseKey);
  }

  // ── Core Read ────────────────────────────────────────────────────────────

  /// Loads settings, scoped to [userId] when available.
  ///
  /// On first call for a given user, the global (legacy) values act as
  /// defaults because [_readScoped] falls through to the global key.
  /// Once any setting is saved, the user-scoped key takes precedence.
  Future<UserSettings> getSettings({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _resolveUserId(userId);

    // Record this user as the last active user
    if (uid != null) {
      await prefs.setString(_kLastActiveUserIdKey, uid);
    }

    // One-time migration from v1 boolean to v2 string (global only)
    if (!prefs.containsKey(_kThemeModeKey) &&
        prefs.containsKey(_kLegacyThemeKey)) {
      final wasDark = prefs.getBool(_kLegacyThemeKey) ?? false;
      await prefs.setString(_kThemeModeKey, wasDark ? 'dark' : 'light');
      await prefs.remove(_kLegacyThemeKey);
    }

    return UserSettings(
      themeMode: _parseThemeMode(
        _readScoped(prefs, _kThemeModeKey, uid, prefs.getString),
      ),
      useAmoledForDark:
          _readScoped(prefs, _kUseAmoledKey, uid, prefs.getBool) ?? false,
      scheduleEnabled:
          _readScoped(prefs, _kScheduleEnabledKey, uid, prefs.getBool) ?? false,
      dayStyle: _parseStyle(
            _readScoped(prefs, _kDayStyleKey, uid, prefs.getString),
          ) ??
          AppearanceStyle.light,
      nightStyle: _parseStyle(
            _readScoped(prefs, _kNightStyleKey, uid, prefs.getString),
          ) ??
          AppearanceStyle.dark,
      dayStartHour:
          _readScoped(prefs, _kDayStartHourKey, uid, prefs.getInt) ?? 6,
      dayStartMinute:
          _readScoped(prefs, _kDayStartMinuteKey, uid, prefs.getInt) ?? 30,
      nightStartHour:
          _readScoped(prefs, _kNightStartHourKey, uid, prefs.getInt) ?? 22,
      nightStartMinute:
          _readScoped(prefs, _kNightStartMinuteKey, uid, prefs.getInt) ?? 0,
      isReminderEnabled:
          _readScoped(prefs, _kReminderEnabledKey, uid, prefs.getBool) ?? false,
      reminderHour:
          _readScoped(prefs, _kReminderHourKey, uid, prefs.getInt) ?? 7,
      reminderMinute:
          _readScoped(prefs, _kReminderMinuteKey, uid, prefs.getInt) ?? 0,
      isDailyVerseEnabled:
          _readScoped(prefs, _kDailyVerseEnabledKey, uid, prefs.getBool) ?? true,
      themeProfileId:
          _readScoped(prefs, _kThemeProfileKey, uid, prefs.getString) ??
              'current',
      fontScaleFactor:
          _readScoped(prefs, _kFontScaleFactorKey, uid, prefs.getDouble) ?? 1.0,
      canonType: _readScoped(prefs, _kCanonTypeKey, uid, prefs.getString) ??
          'catholic',
      bibleLanguage:
          _readScoped(prefs, _kBibleLanguageKey, uid, prefs.getString) ?? 'en',
    );
  }

  // ── Onboarding (device-level, not user-scoped) ───────────────────────────

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingKey, true);
  }

  // ── Profile Setup ────────────────────────────────────────────────────────

  /// Returns true once the user has submitted the profile-setup screen.
  Future<bool> hasCompletedProfileSetup(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userKey(_kProfileSetupKey, userId)) ?? false;
  }

  /// Persists gender ('male' | 'female') and birthday (ISO-8601 date string).
  Future<void> saveUserProfile({
    required String userId,
    required String gender,
    required DateTime birthday,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey(_kUserGenderKey, userId), gender);
    // Store as a plain date string so it survives encoding/decoding
    await prefs.setString(
      _userKey(_kUserBirthdayKey, userId),
      '${birthday.year.toString().padLeft(4, '0')}-'
      '${birthday.month.toString().padLeft(2, '0')}-'
      '${birthday.day.toString().padLeft(2, '0')}',
    );
    await prefs.setBool(_userKey(_kProfileSetupKey, userId), true);
  }

  /// Returns the saved gender, or null if not yet set.
  Future<String?> getUserGender(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey(_kUserGenderKey, userId));
  }

  /// Returns the saved birthday as a DateTime, or null if not yet set.
  Future<DateTime?> getUserBirthday(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey(_kUserBirthdayKey, userId));
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  // ── Daily First-Read Celebration ─────────────────────────────────────────

  /// Returns the last local date string (YYYY-MM-DD) on which the user received
  /// a first-read celebration.
  Future<String?> getLastCelebratedReadDate(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey(_kLastCelebratedReadDateKey, userId));
  }

  /// Sets the last local date string (YYYY-MM-DD) on which the user celebrated.
  Future<void> setLastCelebratedReadDate(
    String userId,
    String dateString,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _userKey(_kLastCelebratedReadDateKey, userId),
      dateString,
    );
  }

  // ── Theme ─────────────────────────────────────────────────────────────────

  Future<void> setThemeMode(AppThemeMode mode, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _resolveUserId(userId);
    await _writeScoped(
      prefs,
      _kThemeModeKey,
      uid,
      (key) => prefs.setString(key, mode.name),
    );
  }

  Future<void> setUseAmoledForDark(bool value, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _resolveUserId(userId);
    await _writeScoped(
      prefs,
      _kUseAmoledKey,
      uid,
      (key) => prefs.setBool(key, value),
    );
  }

  Future<void> setSchedule({
    required bool enabled,
    required AppearanceStyle dayStyle,
    required AppearanceStyle nightStyle,
    required int dayStartHour,
    required int dayStartMinute,
    required int nightStartHour,
    required int nightStartMinute,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _resolveUserId(userId);
    await _writeScoped(
      prefs,
      _kScheduleEnabledKey,
      uid,
      (k) => prefs.setBool(k, enabled),
    );
    await _writeScoped(
      prefs,
      _kDayStyleKey,
      uid,
      (k) => prefs.setString(k, dayStyle.name),
    );
    await _writeScoped(
      prefs,
      _kNightStyleKey,
      uid,
      (k) => prefs.setString(k, nightStyle.name),
    );
    await _writeScoped(
      prefs,
      _kDayStartHourKey,
      uid,
      (k) => prefs.setInt(k, dayStartHour),
    );
    await _writeScoped(
      prefs,
      _kDayStartMinuteKey,
      uid,
      (k) => prefs.setInt(k, dayStartMinute),
    );
    await _writeScoped(
      prefs,
      _kNightStartHourKey,
      uid,
      (k) => prefs.setInt(k, nightStartHour),
    );
    await _writeScoped(
      prefs,
      _kNightStartMinuteKey,
      uid,
      (k) => prefs.setInt(k, nightStartMinute),
    );
  }

  Future<void> setThemeProfileId(String id, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _resolveUserId(userId);
    await _writeScoped(
      prefs,
      _kThemeProfileKey,
      uid,
      (key) => prefs.setString(key, id),
    );
  }

  Future<void> updateReminder(
    bool isEnabled,
    int hour,
    int minute, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _resolveUserId(userId);
    await _writeScoped(
      prefs,
      _kReminderEnabledKey,
      uid,
      (k) => prefs.setBool(k, isEnabled),
    );
    await _writeScoped(
      prefs,
      _kReminderHourKey,
      uid,
      (k) => prefs.setInt(k, hour),
    );
    await _writeScoped(
      prefs,
      _kReminderMinuteKey,
      uid,
      (k) => prefs.setInt(k, minute),
    );
  }

  Future<void> updateDailyVerse(
    bool isEnabled, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _resolveUserId(userId);
    await _writeScoped(
      prefs,
      _kDailyVerseEnabledKey,
      uid,
      (k) => prefs.setBool(k, isEnabled),
    );
  }

  Future<void> setFontScaleFactor(double factor, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _resolveUserId(userId);
    await _writeScoped(
      prefs,
      _kFontScaleFactorKey,
      uid,
      (key) => prefs.setDouble(key, factor),
    );
  }

  Future<void> setCanonType(String canonType, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _resolveUserId(userId);
    await _writeScoped(
      prefs,
      _kCanonTypeKey,
      uid,
      (key) => prefs.setString(key, canonType),
    );
  }

  Future<void> updateCanonSetting(String canonString) =>
      setCanonType(canonString);

  Future<void> setBibleLanguage(String langCode, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _resolveUserId(userId);
    await _writeScoped(
      prefs,
      _kBibleLanguageKey,
      uid,
      (key) => prefs.setString(key, langCode),
    );
  }

  /// Syncs the user's selected Bible canon to Supabase cloud.
  /// Updates user_metadata (default for Verso) and attempts updating
  /// 'profiles' table if configured in Supabase.
  Future<void> syncCanonToCloud(String canonType) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    // 1. Sync to Supabase Auth user_metadata
    try {
      await client.auth.updateUser(
        UserAttributes(data: {'canon_type': canonType}),
      );
    } catch (_) {}

    // 2. Also attempt updating 'profiles' table if it exists in Supabase
    try {
      await client
          .from('profiles')
          .update({'canon_type': canonType}).eq('id', user.id);
    } catch (_) {}
  }

  /// Syncs the user's selected Bible language to Supabase cloud.
  Future<void> syncBibleLanguageToCloud(String langCode) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      await client.auth.updateUser(
        UserAttributes(data: {'bible_language': langCode}),
      );
    } catch (_) {}

    try {
      await client
          .from('profiles')
          .update({'bible_language': langCode}).eq('id', user.id);
    } catch (_) {}
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
