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
  String _debugInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadDebugInfo();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = '${info.version} (${info.buildNumber})';
      });
    }
  }

  Future<void> _loadDebugInfo() async {
    try {
      final notifEnabled = await NotificationService().areNotificationsEnabled();
      final canSchedule = await NotificationService().canScheduleExactNotifications();
      final pending = await NotificationService().getPendingNotifications();
      
      if (mounted) {
        setState(() {
          _debugInfo = '''
Notifications Enabled: $notifEnabled
Can Schedule Exact: $canSchedule
Pending Notifications: ${pending.length}
${pending.isNotEmpty ? '\nScheduled:\n${pending.map((p) => '  ID ${p.id}: ${p.title}').join('\n')}' : ''}
''';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _debugInfo = 'Error loading debug info: $e';
        });
      }
    }
  }

  String _formatTime(int hour, int minute) {
    final int h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final String m = minute.toString().padLeft(2, '0');
    final String period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  Future<void> _pickTime(int currentHour, int currentMinute) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _debugInfo = 'Scheduling...');
      
      try {
        // 1. Update Database
        await ref.read(currentSettingsProvider.notifier).updateReminder(
              true,
              picked.hour,
              picked.minute,
            );

        // 2. Schedule Notification
        await NotificationService().scheduleDailyReminder(
          picked.hour,
          picked.minute,
        );
        
        // 3. Reload debug info
        await _loadDebugInfo();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Reminder set for ${_formatTime(picked.hour, picked.minute)}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _testNotification() async {
    try {
      await NotificationService().showTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Test notification sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDebugDialog() async {
    await _loadDebugInfo();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: SelectableText(_debugInfo),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _loadDebugInfo();
            },
            child: const Text('Refresh'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(currentSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _showDebugDialog,
            tooltip: 'Debug Info',
          ),
        ],
      ),
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
              SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: child.key == const ValueKey('dark_icon')
                          ? Tween<double>(begin: 0.75, end: 1).animate(animation)
                          : Tween<double>(begin: 0.75, end: 1).animate(animation),
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: settings.isDarkMode
                      ? const Icon(Icons.dark_mode, key: ValueKey('dark_icon'))
                      : const Icon(Icons.light_mode, key: ValueKey('light_icon')),
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
                  setState(() => _debugInfo = 'Updating...');
                  
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Daily reminder enabled')),
                        );
                      }
                    } else {
                      await NotificationService().cancelReminders();
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reminder disabled')),
                        );
                      }
                    }
                    
                    await _loadDebugInfo();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Error: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  }
                },
              ),
              
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

              if (settings.isReminderEnabled)
                ListTile(
                  title: const Text('Test Notification'),
                  subtitle: const Text('Send a test notification now'),
                  leading: const Icon(Icons.bug_report),
                  trailing: const Icon(Icons.send),
                  onTap: _testNotification,
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