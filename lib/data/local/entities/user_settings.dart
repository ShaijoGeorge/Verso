import 'package:drift/drift.dart';
import 'package:verso/data/bible_data.dart';

enum AppThemeMode { system, light, dark }

enum AppearanceStyle { light, dark, amoled }

extension AppearanceStyleX on AppearanceStyle {
  bool get isLight => this == AppearanceStyle.light;
}

enum AppFontSize {
  small(0.85, 'Small', '85%'),
  standard(1, 'Standard', '100%'),
  large(1.15, 'Large', '115%'),
  extraLarge(1.30, 'Extra Large', '130%');

  const AppFontSize(this.scale, this.label, this.percentage);
  final double scale;
  final String label;
  final String percentage;

  static AppFontSize fromScale(double scale) {
    return AppFontSize.values.firstWhere(
      (e) => (e.scale - scale).abs() < 0.01,
      orElse: () => AppFontSize.standard,
    );
  }
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
    this.fontScaleFactor = 1,
    this.canonType = 'catholic',
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
  final double fontScaleFactor;

  /// The active Bible canon type ('catholic', 'protestant', 'orthodox').
  /// Defaults to 'catholic' for legacy users.
  final String canonType;

  CanonType get canon => switch (canonType) {
        'protestant' => CanonType.protestant,
        'orthodox' => CanonType.orthodox,
        _ => CanonType.catholic,
      };

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
    double? fontScaleFactor,
    String? canonType,
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
        fontScaleFactor: fontScaleFactor ?? this.fontScaleFactor,
        canonType: canonType ?? this.canonType,
      );
}

// ---------------------------------------------------------------------------
// Drift Table Definition
// ---------------------------------------------------------------------------
@DataClassName('UserSetting')
class UserSettingsTable extends Table {
  @override
  String get tableName => 'user_settings';

  IntColumn get id => integer().autoIncrement()();

  // Add the canon type string, defaulting to catholic for legacy users
  TextColumn get canonType => text().withDefault(const Constant('catholic'))();
}
