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
import 'package:verso/features/auth/providers/auth_providers.dart';
import 'package:verso/features/auth/services/saved_accounts_service.dart';
import 'package:verso/features/reading/services/reading_service.dart';
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
    publishableKey: AppConstants.supabaseAnonKey,
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
      child: const VersoApp(),
    ),
  );
}

// Converted to ConsumerStatefulWidget to listen for Auth Events
class VersoApp extends ConsumerStatefulWidget {
  const VersoApp({super.key});

  @override
  ConsumerState<VersoApp> createState() => _VersoAppState();
}

class _VersoAppState extends ConsumerState<VersoApp>
    with WidgetsBindingObserver {
  Brightness _systemBrightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen for Auth Events
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // If we detect a recovery link was clicked, force navigation to Update Password
        ref.read(routerProvider).go('/update-password');
      } else if (event == AuthChangeEvent.userUpdated ||
          event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        // Check if an email change was confirmed
        final pending =
            await ref.read(authRepositoryProvider).getPendingEmailChange();
        final currentEmail = data.session?.user.email;
        if (pending != null &&
            currentEmail != null &&
            currentEmail.toLowerCase() == pending.toLowerCase()) {
          await ref.read(authRepositoryProvider).clearPendingEmailChange();
          ref.read(routerProvider).go(
                '/email-change-success?email=${Uri.encodeComponent(currentEmail)}',
              );
        }
      }

      // Keep saved accounts list synchronized with latest tokens and profiles
      final session = data.session;
      if (session != null) {
        ref.read(savedAccountsServiceProvider).syncCurrentSession(session);
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
      // Reconcile cross-device reading progress on resume.
      ref.read(readingServiceProvider).syncOnResume();
      // Ensure daily reminders and verse notifications remain fresh and registered
      _initializeReminders();
      // Check if an email update was confirmed while app was in background
      _checkPendingEmailChange();
    }
  }

  Future<void> _checkPendingEmailChange() async {
    try {
      final pending =
          await ref.read(authRepositoryProvider).getPendingEmailChange();
      if (pending == null) return;

      final res = await Supabase.instance.client.auth.getUser();
      final currentEmail = res.user?.email;
      if (currentEmail != null &&
          currentEmail.toLowerCase() == pending.toLowerCase()) {
        await ref.read(authRepositoryProvider).clearPendingEmailChange();
        ref.read(routerProvider).go(
              '/email-change-success?email=${Uri.encodeComponent(currentEmail)}',
            );
      }
    } catch (_) {}
  }

  Future<void> _initializeReminders() async {
    try {
      final settings = await ref.read(currentSettingsProvider.future);

      if (settings.isReminderEnabled) {
        await NotificationService().scheduleDailyReminder(
          settings.reminderHour,
          settings.reminderMinute,
        );
      }
      if (settings.isDailyVerseEnabled) {
        await NotificationService().scheduleDailyVerseNotification();
      }
    } catch (e) {
      // Silently ignore if settings fail to load
    }
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
