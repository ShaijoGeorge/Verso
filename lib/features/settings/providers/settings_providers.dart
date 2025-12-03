import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/local/entities/user_settings.dart';
import '../data/settings_repository.dart';

part 'settings_providers.g.dart';

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  // Return the repository without any database dependencies
  return SettingsRepository();
}

@riverpod
class CurrentSettings extends _$CurrentSettings {
  @override
  Future<UserSettings> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    return repo.getSettings();
  }

  Future<void> toggleTheme(bool isDark) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.toggleTheme(isDark);
    ref.invalidateSelf(); // Refresh UI
  }

  Future<void> updateReminder(bool isEnabled, int hour, int minute) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateReminder(isEnabled, hour, minute);
    ref.invalidateSelf();
  }
}