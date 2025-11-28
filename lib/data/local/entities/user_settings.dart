import 'package:isar_community/isar.dart';

part 'user_settings.g.dart';

@collection
class UserSettings {
  Id id = 0; // We always use ID 0 so there is only one settings object

  bool isDarkMode;
  
  bool isReminderEnabled;
  int reminderHour;   // 0-23
  int reminderMinute; // 0-59

  UserSettings({
    this.isDarkMode = false, // Default to Light
    this.isReminderEnabled = false,
    this.reminderHour = 7,   // Default 7:00 AM
    this.reminderMinute = 0,
  });
}