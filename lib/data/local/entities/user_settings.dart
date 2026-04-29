enum AppThemeMode { system, light, dark }

enum AppearanceStyle { light, dark, amoled }

extension AppearanceStyleX on AppearanceStyle {
  bool get isLight => this == AppearanceStyle.light;
}

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
    this.reminderHour = 7,
    this.reminderMinute = 0,
    this.themeProfileId = 'current',
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
  final int reminderHour;
  final int reminderMinute;
  final String themeProfileId;

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
    String? themeProfileId,
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
        themeProfileId: themeProfileId ?? this.themeProfileId,
      );
}
