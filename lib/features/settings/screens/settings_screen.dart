import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/components/verso_card.dart';
import 'package:verso/core/design/components/verso_snackbar.dart';
import 'package:verso/core/design/design.dart';
import 'package:verso/core/design/tokens/radii.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final scheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              for (final style in AppearanceStyle.values)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: Icon(_styleIcon(style), color: scheme.onSurfaceVariant),
                  title: Text(
                    _styleLabel(style),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                  trailing: current == style
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: scheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, style),
                ),
              const Gap(16),
            ],
          ),
        );
      },
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
    final settingsAsync = ref.watch(currentSettingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateWidget(
          error: err,
          onRetry: () => ref.invalidate(currentSettingsProvider),
        ),
        data: (settings) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      // --- COLOR THEME SECTION ---
                      _SettingsSectionCard(
                        title: 'Color Theme',
                        children: [
                          for (final profile in ThemeProfiles.all)
                            _ThemeProfileTile(
                              profile: profile,
                              isSelected: settings.themeProfileId == profile.id,
                              onTap: () => ref
                                  .read(currentSettingsProvider.notifier)
                                  .setThemeProfileId(profile.id),
                            ),
                        ],
                      ),
                      const Gap(24),

                      // --- APPEARANCE SECTION ---
                      _SettingsSectionCard(
                        title: 'Appearance',
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Theme Mode',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const Gap(12),
                                SegmentedButton<AppThemeMode>(
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
                                  style: ButtonStyle(
                                    textStyle: WidgetStatePropertyAll(
                                      GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _SettingsSwitchTile(
                            title: 'Pure Black (AMOLED)',
                            subtitle: 'Applies when dark theme is active',
                            icon: Icons.brightness_1_outlined,
                            iconColor: const Color(0xFF8B5CF6),
                            value: settings.useAmoledForDark,
                            onChanged: (v) => ref
                                .read(currentSettingsProvider.notifier)
                                .setUseAmoledForDark(v),
                          ),
                        ],
                      ),
                      const Gap(24),

                      // --- SCHEDULED THEME SECTION ---
                      _SettingsSectionCard(
                        title: 'Scheduled Theme',
                        children: [
                          _SettingsSwitchTile(
                            title: 'Schedule Theme',
                            subtitle: 'Auto-switch between day and night modes',
                            icon: Icons.schedule_outlined,
                            iconColor: const Color(0xFFF59E0B),
                            value: settings.scheduleEnabled,
                            onChanged: (v) => ref
                                .read(currentSettingsProvider.notifier)
                                .setSchedule(
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
                            _SettingsActionTile(
                              title: 'Day Mode',
                              icon: Icons.wb_sunny_outlined,
                              iconColor: const Color(0xFFF59E0B),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _styleLabel(settings.dayStyle),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: scheme.onSurfaceVariant,
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
                            _SettingsActionTile(
                              title: 'Night Mode',
                              icon: Icons.nightlight_outlined,
                              iconColor: const Color(0xFF6366F1),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _styleLabel(settings.nightStyle),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: scheme.onSurfaceVariant,
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
                        ],
                      ),
                      const Gap(24),

                      // --- NOTIFICATIONS SECTION ---
                      _SettingsSectionCard(
                        title: 'Reminders',
                        children: [
                          _SettingsSwitchTile(
                            title: 'Daily Reminder',
                            subtitle: settings.isReminderEnabled
                                ? 'Scheduled for ${_formatTime(settings.reminderHour, settings.reminderMinute)}'
                                : 'Get a daily nudge to read',
                            icon: Icons.notifications_active_outlined,
                            iconColor: const Color(0xFF10B981),
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
                            _SettingsActionTile(
                              title: 'Reminder Time',
                              icon: Icons.access_time,
                              iconColor: const Color(0xFF3B82F6),
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
                        ],
                      ),
                      const Gap(32),

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
                          child: Column(
                            children: [
                              Text(
                                'Verso v${ref.watch(packageInfoProvider).version}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'Made by Shaijo George',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(48),
                    ],
                  ),
                ),
              );
        },
      ),
    );
  }
}

// -- Components --

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
        ),
        VersoCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: scheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.5),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: scheme.onSurfaceVariant,
        ),
      ),
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.trailing,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Gap(14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeProfileTile extends StatelessWidget {
  const _ThemeProfileTile({
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  final ThemeProfile profile;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final previewPalette = switch (context.palette.style) {
      AppearanceStyle.light => profile.light,
      AppearanceStyle.amoled => profile.amoled,
      _ => profile.dark,
    };

    return Material(
      color: isSelected ? scheme.primary.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Swatches
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _Swatch(color: previewPalette.bg, size: 28),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _Swatch(color: previewPalette.primary, size: 22),
                    ),
                    Positioned(
                      top: 4,
                      right: 0,
                      child: _Swatch(color: previewPalette.accent, size: 14),
                    ),
                  ],
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      profile.tagline,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: scheme.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
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
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
