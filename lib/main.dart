import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/constants.dart';
import 'package:verso/core/providers/package_info_provider.dart';
import 'package:verso/core/router.dart';
import 'package:verso/core/utils/firebase_crash_reporter.dart';
import 'package:verso/core/utils/verso_error_observer.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/settings/providers/theme_resolver.dart';
import 'package:verso/features/settings/services/notification_service.dart';
import 'package:verso/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase & Crashlytics
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final crashReporter = FirebaseCrashReporter();
  await crashReporter.init();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics.
  PlatformDispatcher.instance.onError = (error, stack) {
    final isNetworkError = error.toString().contains('SocketException') ||
        error.toString().contains('AuthRetryableFetchException');

    crashReporter.recordError(
      error,
      stack,
      fatal: !isNetworkError,
      reason: isNetworkError
          ? 'Network connectivity issue'
          : 'Unhandled fatal exception',
    );
    return true;
  };

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
      observers: [VersoErrorObserver(crashReporter)],
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

class _BibliaAppState extends ConsumerState<BibliaApp>
    with WidgetsBindingObserver {
  Brightness _systemBrightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    if (brightness != _systemBrightness) {
      setState(() => _systemBrightness = brightness);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-evaluate schedule boundaries when returning from background.
      ref.invalidate(scheduleTickStreamProvider);
    }
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
    final resolved = ref.watch(resolvedThemeProvider(_systemBrightness));
    final settingsAsync = ref.watch(currentSettingsProvider);
    final fontScaleFactor = settingsAsync.value?.fontScaleFactor ?? 1.0;

    return MaterialApp.router(
      title: 'Verso',
      debugShowCheckedModeBanner: false,
      theme: resolved.lightTheme,
      darkTheme: resolved.darkTheme,
      themeMode: resolved.themeMode,

      // Connect GoRouter
      routerConfig: router,

      // Apply in-app font size and completely ignore device/OS font scaling
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(fontScaleFactor),
          ),
          child: child!,
        );
      },
    );
  }
}
