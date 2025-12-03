class UserSettings {
  final bool isDarkMode;
  final bool isReminderEnabled;
  final int reminderHour;   // 0-23
  final int reminderMinute; // 0-59

  UserSettings({
    this.isDarkMode = false,
    this.isReminderEnabled = false,
    this.reminderHour = 7,
    this.reminderMinute = 0,
  });
}