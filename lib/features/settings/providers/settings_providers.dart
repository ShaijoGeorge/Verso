import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/data/local/entities/user_settings.dart';
import 'package:verso/features/settings/data/settings_repository.dart';

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

  UserSettings? get _current => switch (state) {
        AsyncData(:final value) => value,
        _ => null,
      };

  Future<void> setThemeMode(AppThemeMode mode) async {
    final current = _current;
    if (current == null) return;
    state = AsyncData(current.copyWith(themeMode: mode));
    await ref.read(settingsRepositoryProvider).setThemeMode(mode);
    ref.invalidateSelf(); // Refresh UI
  }

  Future<void> setUseAmoledForDark(bool value) async {
    final current = _current;
    if (current == null) return;
    state = AsyncData(current.copyWith(useAmoledForDark: value));
    await ref.read(settingsRepositoryProvider).setUseAmoledForDark(value);
    ref.invalidateSelf(); // Refresh UI
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
    final current = _current;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        scheduleEnabled: enabled,
        dayStyle: dayStyle,
        nightStyle: nightStyle,
        dayStartHour: dayStartHour,
        dayStartMinute: dayStartMinute,
        nightStartHour: nightStartHour,
        nightStartMinute: nightStartMinute,
      ),
    );
    await ref.read(settingsRepositoryProvider).setSchedule(
          enabled: enabled,
          dayStyle: dayStyle,
          nightStyle: nightStyle,
          dayStartHour: dayStartHour,
          dayStartMinute: dayStartMinute,
          nightStartHour: nightStartHour,
          nightStartMinute: nightStartMinute,
        );
    ref.invalidateSelf(); // Refresh UI
  }

  Future<void> setThemeProfileId(String id) async {
    final current = _current;
    if (current == null) return;
    state = AsyncData(current.copyWith(themeProfileId: id));
    await ref.read(settingsRepositoryProvider).setThemeProfileId(id);
    ref.invalidateSelf(); // Refresh UI
  }

  Future<void> updateReminder(bool isEnabled, int hour, int minute) async {
    final current = _current;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        isReminderEnabled: isEnabled,
        reminderHour: hour,
        reminderMinute: minute,
      ),
    );
    await ref.read(settingsRepositoryProvider).updateReminder(
          isEnabled,
          hour,
          minute,
        );
    ref.invalidateSelf(); // Refresh UI
  }

  Future<void> setFontScaleFactor(double factor) async {
    final current = _current;
    if (current == null) return;
    state = AsyncData(current.copyWith(fontScaleFactor: factor));
    await ref.read(settingsRepositoryProvider).setFontScaleFactor(factor);
    ref.invalidateSelf(); // Refresh UI
  }

  Future<void> setCanonType(String canonType) async {
    final current = _current;
    if (current == null) return;
    state = AsyncData(current.copyWith(canonType: canonType));
    await ref.read(settingsRepositoryProvider).setCanonType(canonType);
    ref.invalidateSelf(); // Refresh UI
  }

  Future<void> updateCanonType(CanonType canon) async {
    await setCanonType(canon.name);
  }
}

/// Alias for compatibility
final CurrentSettingsProvider userSettingsProvider = currentSettingsProvider;
