import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:verso/core/design/design.dart';
import 'package:verso/core/providers/package_info_provider.dart';
import 'package:verso/core/utils/app_error_handler.dart';
import 'package:verso/core/widgets/error_state_widget.dart';
import 'package:verso/data/local/entities/user_settings.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/settings/screens/debug_cache_screen.dart';
import 'package:verso/features/settings/services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _formatTime(int hour, int minute) {
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  Future<TimeOfDay?> _pickTimeDialog(int currentHour, int currentMinute) {
    return showGeneralDialog<TimeOfDay>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, _, __) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: TimePickerDialog(
            initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _pickReminderTime(int currentHour, int currentMinute) async {
    final picked = await _pickTimeDialog(currentHour, currentMinute);
    if (picked != null) {
      try {
        await ref.read(currentSettingsProvider.notifier).updateReminder(
              true,
              picked.hour,
              picked.minute,
            );
        await NotificationService().scheduleDailyReminder(
          picked.hour,
          picked.minute,
        );
        if (mounted) {
          VersoSnackbar.success(
            context,
            message:
                'Reminder set for ${_formatTime(picked.hour, picked.minute)}',
          );
        }
      } catch (e) {
        if (mounted) {
          VersoSnackbar.error(context, message: AppErrorHandler.getMessage(e));
        }
      }
    }
  }

  Future<void> _pickScheduleTime(
    UserSettings settings, {
    required bool isDay,
  }) async {
    final picked = await _pickTimeDialog(
      isDay ? settings.dayStartHour : settings.nightStartHour,
      isDay ? settings.dayStartMinute : settings.nightStartMinute,
    );
    if (picked != null) {
      await ref.read(currentSettingsProvider.notifier).setSchedule(
            enabled: settings.scheduleEnabled,
            dayStyle: settings.dayStyle,
            nightStyle: settings.nightStyle,
            dayStartHour: isDay ? picked.hour : settings.dayStartHour,
            dayStartMinute: isDay ? picked.minute : settings.dayStartMinute,
            nightStartHour: isDay ? settings.nightStartHour : picked.hour,
            nightStartMinute: isDay ? settings.nightStartMinute : picked.minute,
          );
    }
  }

  Future<AppearanceStyle?> _pickStyle(
    AppearanceStyle current,
    String title,
  ) async {
    return showModalBottomSheet<AppearanceStyle>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final style in AppearanceStyle.values)
              ListTile(
                leading: Icon(_styleIcon(style)),
                title: Text(_styleLabel(style)),
                trailing: current == style
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.pop(context, style),
              ),
            const Gap(8),
          ],
        ),
      ),
    );
  }

  String _styleLabel(AppearanceStyle style) => switch (style) {
        AppearanceStyle.light => 'Light',
        AppearanceStyle.dark => 'Dark',
        AppearanceStyle.amoled => 'AMOLED (pure black)',
      };

  IconData _styleIcon(AppearanceStyle style) => switch (style) {
        AppearanceStyle.light => Icons.light_mode_outlined,
        AppearanceStyle.dark => Icons.dark_mode_outlined,
        AppearanceStyle.amoled => Icons.brightness_1_outlined,
      };

  @override
  Widget build(BuildContext context) {
    // Watch the settings provider to get the current theme preference
    final settingsAsync = ref.watch(currentSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateWidget(
          error: err,
          onRetry: () => ref.invalidate(currentSettingsProvider),
        ),
        data: (settings) {
          return ListView(
            children: [
              const Gap(16),

              // --- APPEARANCE SECTION ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Appearance',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Theme mode: System / Light / Dark
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SegmentedButton<AppThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) => ref
                      .read(currentSettingsProvider.notifier)
                      .setThemeMode(s.first),
                ),
              ),

              // AMOLED toggle
              SwitchListTile(
                secondary: const Icon(Icons.brightness_1_outlined),
                title: const Text('Pure black (AMOLED)'),
                subtitle: const Text('Applies when dark theme is active'),
                value: settings.useAmoledForDark,
                onChanged: (v) => ref
                    .read(currentSettingsProvider.notifier)
                    .setUseAmoledForDark(v),
              ),

              const Divider(),
              const Gap(4),

              // Schedule header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Scheduled Theme',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SwitchListTile(
                secondary: const Icon(Icons.schedule_outlined),
                title: const Text('Schedule theme'),
                subtitle: const Text(
                  'Auto-switch between day and night modes',
                ),
                value: settings.scheduleEnabled,
                onChanged: (v) =>
                    ref.read(currentSettingsProvider.notifier).setSchedule(
                          enabled: v,
                          dayStyle: settings.dayStyle,
                          nightStyle: settings.nightStyle,
                          dayStartHour: settings.dayStartHour,
                          dayStartMinute: settings.dayStartMinute,
                          nightStartHour: settings.nightStartHour,
                          nightStartMinute: settings.nightStartMinute,
                        ),
              ),

              if (settings.scheduleEnabled) ...[
                // Day mode row
                ListTile(
                  leading: const Icon(Icons.wb_sunny_outlined),
                  title: const Text('Day mode'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _styleLabel(settings.dayStyle),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(8),
                      _TimeChip(
                        label: _formatTime(
                          settings.dayStartHour,
                          settings.dayStartMinute,
                        ),
                        onTap: () => _pickScheduleTime(settings, isDay: true),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final picked = await _pickStyle(
                      settings.dayStyle,
                      'Day mode',
                    );
                    if (picked != null) {
                      await ref
                          .read(currentSettingsProvider.notifier)
                          .setSchedule(
                            enabled: settings.scheduleEnabled,
                            dayStyle: picked,
                            nightStyle: settings.nightStyle,
                            dayStartHour: settings.dayStartHour,
                            dayStartMinute: settings.dayStartMinute,
                            nightStartHour: settings.nightStartHour,
                            nightStartMinute: settings.nightStartMinute,
                          );
                    }
                  },
                ),

                // Night mode row
                ListTile(
                  leading: const Icon(Icons.nightlight_outlined),
                  title: const Text('Night mode'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _styleLabel(settings.nightStyle),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(8),
                      _TimeChip(
                        label: _formatTime(
                          settings.nightStartHour,
                          settings.nightStartMinute,
                        ),
                        onTap: () => _pickScheduleTime(settings, isDay: false),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final picked = await _pickStyle(
                      settings.nightStyle,
                      'Night mode',
                    );
                    if (picked != null) {
                      await ref
                          .read(currentSettingsProvider.notifier)
                          .setSchedule(
                            enabled: settings.scheduleEnabled,
                            dayStyle: settings.dayStyle,
                            nightStyle: picked,
                            dayStartHour: settings.dayStartHour,
                            dayStartMinute: settings.dayStartMinute,
                            nightStartHour: settings.nightStartHour,
                            nightStartMinute: settings.nightStartMinute,
                          );
                    }
                  },
                ),
              ],

              const Divider(),
              const Gap(8),

              // --- NOTIFICATIONS SECTION ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Reminders',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SwitchListTile(
                title: const Text('Daily Reminder'),
                subtitle: Text(
                  settings.isReminderEnabled
                      ? 'Scheduled for ${_formatTime(settings.reminderHour, settings.reminderMinute)}'
                      : 'Get a daily nudge to read',
                ),
                secondary: const Icon(Icons.notifications_active_outlined),
                value: settings.isReminderEnabled,
                onChanged: (value) async {
                  try {
                    await ref
                        .read(currentSettingsProvider.notifier)
                        .updateReminder(
                          value,
                          settings.reminderHour,
                          settings.reminderMinute,
                        );
                    if (value) {
                      await NotificationService().scheduleDailyReminder(
                        settings.reminderHour,
                        settings.reminderMinute,
                      );
                      if (mounted) {
                        VersoSnackbar.success(
                          context,
                          message: 'Daily reminder enabled',
                        );
                      }
                    } else {
                      await NotificationService().cancelReminders();
                    }
                  } catch (e) {
                    if (mounted) {
                      VersoSnackbar.error(
                        context,
                        message: AppErrorHandler.getMessage(e),
                      );
                    }
                  }
                },
              ),

              if (settings.isReminderEnabled)
                ListTile(
                  title: const Text('Reminder Time'),
                  leading: const Icon(Icons.access_time),
                  trailing: _TimeChip(
                    label: _formatTime(
                      settings.reminderHour,
                      settings.reminderMinute,
                    ),
                    onTap: () => _pickReminderTime(
                      settings.reminderHour,
                      settings.reminderMinute,
                    ),
                  ),
                  onTap: () => _pickReminderTime(
                    settings.reminderHour,
                    settings.reminderMinute,
                  ),
                ),

              const Divider(),
              const Gap(8),

              // --- ABOUT SECTION ---
              Center(
                child: GestureDetector(
                  onLongPress: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DebugCacheScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: Spacing.allLG,
                    child: Text(
                      'Verso v${ref.watch(packageInfoProvider).version}\nMade by Shaijo George',
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: context.colors.onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
