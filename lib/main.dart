import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'features/settings/services/notification_service.dart';


void main() async {

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

    return MaterialApp.router(
      title: 'Biblia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Connect GoRouter
      routerConfig: router,
    );
  }
}