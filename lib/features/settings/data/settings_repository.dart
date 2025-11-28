import '../../../core/database_service.dart';
import '../../../data/local/entities/user_settings.dart';

class SettingsRepository {
  final DatabaseService _dbService;

  SettingsRepository(this._dbService);

  // Get settings (or create default if not exists)
  Future<UserSettings> getSettings() async {
    final isar = await _dbService.db;
    final settings = await isar.userSettings.get(0);
    if (settings == null) {
      final defaultSettings = UserSettings();
      await isar.writeTxn(() async {
        await isar.userSettings.put(defaultSettings);
      });
      return defaultSettings;
    }
    return settings;
  }

  // Save Settings
  Future<void> saveSettings(UserSettings settings) async {
    final isar = await _dbService.db;
    await isar.writeTxn(() async {
      await isar.userSettings.put(settings);
    });
  }
  
  // Toggle Dark Mode
  Future<void> toggleTheme(bool isDark) async {
    final settings = await getSettings();
    settings.isDarkMode = isDark;
    await saveSettings(settings);
  }

  // Update Reminder
  Future<void> updateReminder(bool isEnabled, int hour, int minute) async {
    final settings = await getSettings();
    settings.isReminderEnabled = isEnabled;
    settings.reminderHour = hour;
    settings.reminderMinute = minute;
    await saveSettings(settings);
  }
}