import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_providers.dart';
import '../services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = '${info.version} (${info.buildNumber})';
      });
    }
  }

  // Helper to format time (e.g., "07:05 PM")
  String _formatTime(int hour, int minute) {
    // Convert 24h to 12h
    final int h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final String m = minute.toString().padLeft(2, '0');
    final String period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  Future<void> _pickTime(int currentHour, int currentMinute) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      // Force the picker to show 12-hour format (AM/PM)
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // 1. Update Database
      await ref.read(currentSettingsProvider.notifier).updateReminder(
            true, // Enable it automatically if they picked a time
            picked.hour,
            picked.minute,
          );

      // 2. Schedule Notification
      await NotificationService().scheduleDailyReminder(
        picked.hour,
        picked.minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the settings from the database
    final settingsAsync = ref.watch(currentSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (settings) {
          return ListView(
            children: [
              const Gap(16),
              
              // --- APPEARANCE SECTION ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Appearance',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Animated Dark Mode Toggle
              SwitchListTile(
                title: const Text('Dark Mode'),
                // We use AnimatedSwitcher to animate the icon change
                secondary: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    // Combine Rotation and Scale for a "spinning" effect
                    return RotationTransition(
                      turns: child.key == const ValueKey('dark_icon')
                          ? Tween<double>(begin: 0.75, end: 1).animate(animation)
                          : Tween<double>(begin: 0.75, end: 1).animate(animation),
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: settings.isDarkMode
                      ? const Icon(Icons.dark_mode, key: ValueKey('dark_icon')) // Moon
                      : const Icon(Icons.light_mode, key: ValueKey('light_icon')), // Sun
                ),
                value: settings.isDarkMode,
                onChanged: (bool value) {
                  ref.read(currentSettingsProvider.notifier).toggleTheme(value);
                },
              ),
              
              const Divider(),
              const Gap(8),

              // --- NOTIFICATIONS SECTION ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                subtitle: Text(settings.isReminderEnabled
                    ? 'Scheduled for ${_formatTime(settings.reminderHour, settings.reminderMinute)}'
                    : 'Get a daily nudge to read'),
                secondary: const Icon(Icons.notifications_active_outlined),
                value: settings.isReminderEnabled,
                onChanged: (bool value) async {
                  // Update DB
                  await ref
                      .read(currentSettingsProvider.notifier)
                      .updateReminder(
                        value,
                        settings.reminderHour,
                        settings.reminderMinute,
                      );

                  // Update System Notification
                  if (value) {
                    await NotificationService().scheduleDailyReminder(
                      settings.reminderHour,
                      settings.reminderMinute,
                    );
                  } else {
                    await NotificationService().cancelReminders();
                  }
                },
              ),
              
              // Time Picker (Only visible if enabled)
              if (settings.isReminderEnabled)
                ListTile(
                  title: const Text('Reminder Time'),
                  leading: const Icon(Icons.access_time),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatTime(settings.reminderHour, settings.reminderMinute),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () => _pickTime(settings.reminderHour, settings.reminderMinute),
                ),

              const Divider(),
              const Gap(8),

              // --- ABOUT SECTION ---
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Biblia'),
                subtitle: Text('Version $_version'),
              ),
            ],
          );
        },
      ),
    );
  }
}