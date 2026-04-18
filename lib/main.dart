import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/constants.dart';
import 'package:verso/core/design/theme.dart';
import 'package:verso/core/providers/package_info_provider.dart';
import 'package:verso/core/router.dart';
import 'package:verso/core/utils/verso_error_observer.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/settings/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load the .env file
  await dotenv.load();

  // 2. Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize Notifications
  await NotificationService().init();

  // Request Permissions (Important for Android 13+)
  await NotificationService().requestPermissions();

  // Load Package Info synchronously before runApp
  final packageInfo = await PackageInfo.fromPlatform();

  runApp(
    ProviderScope(
      overrides: [
        packageInfoProvider.overrideWithValue(packageInfo),
      ],
      observers: [VersoErrorObserver()],
      child: const BibliaApp(),
    ),
  );
}

// Converted to ConsumerStatefulWidget to listen for Auth Events
class BibliaApp extends ConsumerStatefulWidget {
  const BibliaApp({super.key});

  @override
  ConsumerState<BibliaApp> createState() => _BibliaAppState();
}

class _BibliaAppState extends ConsumerState<BibliaApp> {
  @override
  void initState() {
    super.initState();
    // Listen for the "Password Recovery" event
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // If we detect a recovery link was clicked, force navigation to Update Password
        ref.read(routerProvider).go('/update-password');
      }
    });

    // Re-schedule reminders on app start
    _initializeReminders();
  }

  Future<void> _initializeReminders() async {
    // Wait for settings to load
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final settingsAsync = ref.read(currentSettingsProvider);
    settingsAsync.whenData((settings) async {
      if (settings.isReminderEnabled) {
        await NotificationService().scheduleDailyReminder(
          settings.reminderHour,
          settings.reminderMinute,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    // Watch the settings provider to get the current theme preference
    final settingsAsync = ref.watch(currentSettingsProvider);

    return MaterialApp.router(
      title: 'Verso',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // A duration of 500ms - 800ms is usually good for a "luxurious" feel.
      themeAnimationDuration: const Duration(milliseconds: 600),
      themeAnimationCurve:
          Curves.easeInOutCubic, // Starts slow, speeds up, ends slow

      // Determine the ThemeMode based on the loaded settings
      themeMode: settingsAsync.when(
        data: (settings) =>
            settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        loading: () => ThemeMode.system, // Default while loading
        error: (_, __) => ThemeMode.system, // Default on error
      ),

      // Connect GoRouter
      routerConfig: router,
    );
  }
}
