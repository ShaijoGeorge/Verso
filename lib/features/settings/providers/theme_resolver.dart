import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verso/core/design/theme.dart';
import 'package:verso/data/local/entities/user_settings.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';

part 'theme_resolver.g.dart';

class ResolvedTheme {
  const ResolvedTheme({required this.darkTheme, required this.themeMode});
  final ThemeData darkTheme;
  final ThemeMode themeMode;
}

/// Emits a tick every 60 s so schedule-based theme switching stays current.
@riverpod
Stream<int> scheduleTickStream(Ref ref) async* {
  var tick = 0;
  while (true) {
    final completer = Completer<void>();
    final timer = Timer(const Duration(seconds: 60), completer.complete);
    ref.onDispose(timer.cancel);
    await completer.future;
    yield ++tick;
  }
}

/// Returns whether [now] falls in the "night" window defined by
/// [nightH]:[nightM]-[dayH]:[dayM].
bool _isNight(
  DateTime now,
  int dayH,
  int dayM,
  int nightH,
  int nightM,
) {
  final nowMins = now.hour * 60 + now.minute;
  final dayMins = dayH * 60 + dayM;
  final nightMins = nightH * 60 + nightM;

  if (nightMins > dayMins) {
    // Night spans midnight: e.g. 22:00 → 06:30
    return nowMins >= nightMins || nowMins < dayMins;
  } else {
    return nowMins >= nightMins && nowMins < dayMins;
  }
}

AppearanceStyle _resolveStyle(
  UserSettings settings,
  Brightness systemBrightness,
) {
  if (settings.scheduleEnabled) {
    final night = _isNight(
      DateTime.now(),
      settings.dayStartHour,
      settings.dayStartMinute,
      settings.nightStartHour,
      settings.nightStartMinute,
    );
    return night ? settings.nightStyle : settings.dayStyle;
  }

  switch (settings.themeMode) {
    case AppThemeMode.light:
      return AppearanceStyle.light;
    case AppThemeMode.dark:
      return settings.useAmoledForDark
          ? AppearanceStyle.amoled
          : AppearanceStyle.dark;
    case AppThemeMode.system:
      if (systemBrightness == Brightness.dark) {
        return settings.useAmoledForDark
            ? AppearanceStyle.amoled
            : AppearanceStyle.dark;
      }
      return AppearanceStyle.light;
  }
}

/// Provides the [ResolvedTheme] to wire into [MaterialApp].
@riverpod
ResolvedTheme resolvedTheme(Ref ref, Brightness systemBrightness) {
  ref.watch(scheduleTickStreamProvider);

  final settingsAsync = ref.watch(currentSettingsProvider);
  final settings = switch (settingsAsync) {
    AsyncData(:final value) => value,
    _ => null,
  };

  if (settings == null) {
    return ResolvedTheme(
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }

  final style = _resolveStyle(settings, systemBrightness);

  return switch (style) {
    AppearanceStyle.light => ResolvedTheme(
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
      ),
    AppearanceStyle.dark => ResolvedTheme(
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
      ),
    AppearanceStyle.amoled => ResolvedTheme(
        darkTheme: AppTheme.amoledTheme,
        themeMode: ThemeMode.dark,
      ),
  };
}

/// Convenience: returns the resolved [AppearanceStyle] for use in UI.
@riverpod
AppearanceStyle? effectiveStyle(Ref ref) {
  final settingsAsync = ref.watch(currentSettingsProvider);
  final settings = switch (settingsAsync) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (settings == null) return null;
  final brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;
  return _resolveStyle(settings, brightness);
}
