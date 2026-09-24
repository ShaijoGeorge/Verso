import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/design.dart';
import 'package:verso/core/utils/app_error_handler.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/settings/services/notification_service.dart';

class NotificationsBottomSheet extends ConsumerStatefulWidget {
  const NotificationsBottomSheet({super.key});

  @override
  ConsumerState<NotificationsBottomSheet> createState() =>
      _NotificationsBottomSheetState();
}

class _NotificationsBottomSheetState
    extends ConsumerState<NotificationsBottomSheet> {
  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  Future<void> _pickReminderTime(int currentHour, int currentMinute) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (time != null && mounted) {
      try {
        final settings = ref.read(currentSettingsProvider).value;
        if (settings == null) return;

        await ref.read(currentSettingsProvider.notifier).updateReminder(
              settings.isReminderEnabled,
              time.hour,
              time.minute,
            );

        if (settings.isReminderEnabled) {
          await NotificationService().scheduleDailyReminder(
            time.hour,
            time.minute,
          );
          if (mounted) {
            VersoSnackbar.success(
              context,
              message: 'Reminder updated to ${_formatTime(time.hour, time.minute)}',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          VersoSnackbar.error(
            context,
            message: AppErrorHandler.getMessage(e),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(currentSettingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return settingsAsync.when(
      data: (settings) {
        return Container(
          padding: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(8),
              Text(
                'Notifications',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const Gap(16),
              // Daily Verse
              SwitchListTile(
                title: Text(
                  'Daily Verse (6:00 AM)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  settings.isDailyVerseEnabled
                      ? 'Morning Scripture alert at 6:00 AM'
                      : 'Start your day with God’s Word',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                secondary: const Icon(
                  Icons.wb_sunny_outlined,
                  color: Color(0xFFF59E0B),
                ),
                value: settings.isDailyVerseEnabled,
                onChanged: (value) async {
                  try {
                    await ref
                        .read(currentSettingsProvider.notifier)
                        .updateDailyVerse(value);
                    if (value) {
                      await NotificationService()
                          .scheduleDailyVerseNotification();
                      if (mounted) {
                        VersoSnackbar.success(
                          context,
                          message: 'Daily verse alert enabled for 6:00 AM',
                        );
                      }
                    } else {
                      await NotificationService()
                          .cancelDailyVerseNotification();
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
              const Divider(height: 1),
              // Daily Reminder
              SwitchListTile(
                title: Text(
                  'Daily Reminder',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  settings.isReminderEnabled
                      ? 'Scheduled for ${_formatTime(settings.reminderHour, settings.reminderMinute)}'
                      : 'Get a daily nudge to read',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                secondary: const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFF10B981),
                ),
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
                      await NotificationService().cancelDailyReminder();
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
                  leading: const SizedBox(width: 24), // alignment
                  title: Text(
                    'Reminder Time',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: scheme.onSurface,
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () => _pickReminderTime(
                      settings.reminderHour,
                      settings.reminderMinute,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _formatTime(
                          settings.reminderHour,
                          settings.reminderMinute,
                        ),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                  onTap: () => _pickReminderTime(
                    settings.reminderHour,
                    settings.reminderMinute,
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }
}
