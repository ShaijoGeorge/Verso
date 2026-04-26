enum AppThemeMode { system, light, dark }

enum AppearanceStyle { light, dark, amoled }

class UserSettings {
  UserSettings({
    this.themeMode = AppThemeMode.system,
    this.useAmoledForDark = false,
    this.scheduleEnabled = false,
    this.dayStyle = AppearanceStyle.light,
    this.nightStyle = AppearanceStyle.dark,
    this.dayStartHour = 6,
    this.dayStartMinute = 30,
    this.nightStartHour = 22,
    this.nightStartMinute = 0,
    this.isReminderEnabled = false,
    this.reminderHour = 7, // 0-23
    this.reminderMinute = 0, // 0-59
  });

  final AppThemeMode themeMode;
  final bool useAmoledForDark;
  final bool scheduleEnabled;
  final AppearanceStyle dayStyle;
  final AppearanceStyle nightStyle;
  final int dayStartHour;
  final int dayStartMinute;
  final int nightStartHour;
  final int nightStartMinute;
  final bool isReminderEnabled;
  final int reminderHour; // 0-23
  final int reminderMinute; // 0-59

  UserSettings copyWith({
    AppThemeMode? themeMode,
    bool? useAmoledForDark,
    bool? scheduleEnabled,
    AppearanceStyle? dayStyle,
    AppearanceStyle? nightStyle,
    int? dayStartHour,
    int? dayStartMinute,
    int? nightStartHour,
    int? nightStartMinute,
    bool? isReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) =>
      UserSettings(
        themeMode: themeMode ?? this.themeMode,
        useAmoledForDark: useAmoledForDark ?? this.useAmoledForDark,
        scheduleEnabled: scheduleEnabled ?? this.scheduleEnabled,
        dayStyle: dayStyle ?? this.dayStyle,
        nightStyle: nightStyle ?? this.nightStyle,
        dayStartHour: dayStartHour ?? this.dayStartHour,
        dayStartMinute: dayStartMinute ?? this.dayStartMinute,
        nightStartHour: nightStartHour ?? this.nightStartHour,
        nightStartMinute: nightStartMinute ?? this.nightStartMinute,
        isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
        reminderHour: reminderHour ?? this.reminderHour,
        reminderMinute: reminderMinute ?? this.reminderMinute,
      );
}
