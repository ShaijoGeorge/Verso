import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'features/settings/services/notification_service.dart';
import 'features/settings/providers/settings_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Use this to handle data updates in the background if needed
  print("Handling a background message: ${message.messageId}");
}
void main() async {

  // Initialize Firebase
  await Firebase.initializeApp();

  // Register Background Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load the .env file
  await dotenv.load(fileName: ".env");

  // 2. Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize Notifications
  await NotificationService().init();

  runApp(const ProviderScope(child: BibliaApp()));
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
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    // Watch the settings provider to get the current theme preference
    final settingsAsync = ref.watch(currentSettingsProvider);

    return MaterialApp.router(
      title: 'Biblia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // A duration of 500ms - 800ms is usually good for a "luxurious" feel.
      themeAnimationDuration: const Duration(milliseconds: 600), 
      themeAnimationCurve: Curves.easeInOutCubic, // Starts slow, speeds up, ends slow

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
