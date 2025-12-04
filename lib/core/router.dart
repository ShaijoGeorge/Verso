import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/main_wrapper.dart';
import 'widgets/not_found_screen.dart';
import '../data/bible_data.dart';
import '../features/home/screens/home_screen.dart';
import '../features/reading/screens/old_testament_screen.dart';
import '../features/reading/screens/new_testament_screen.dart';
import '../features/reading/screens/chapters_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/update_password_screen.dart';
import '../features/auth/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/stats/screens/detailed_stats_screen.dart';
import '../features/stats/screens/activity_analytics_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to the Supabase Auth Stream directly
  final authStream = Supabase.instance.client.auth.onAuthStateChange;

  // FIX 1 (Continued): Create the key INSIDE the provider.
  // This ensures a fresh key is generated whenever the Router is rebuilt.
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    
    // Refresh the router whenever Auth State changes (Login, Logout, Recovery)
    refreshListenable: GoRouterRefreshStream(authStream),
    
    // Debug Log to help us see errors
    errorBuilder: (context, state) {
      debugPrint("⚠️ ROUTER ERROR: ${state.error}");
      return NotFoundScreen(error: state.error);
    },

    redirect: (context, state) {
      // --- CRITICAL FIX START ---
      // Intercept the raw deep link from Android and convert it to a valid path
      if (state.uri.scheme == 'io.supabase.flutter' && state.uri.host == 'reset-callback') {
        debugPrint("GoRouter: Deep link detected, normalizing to /reset-callback");
        return '/reset-callback';
      }
      // --- CRITICAL FIX END ---

      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      
      final path = state.uri.path;
      
      // Normalize path to handle potential trailing slashes
      final cleanPath = path.endsWith('/') && path.length > 1 
          ? path.substring(0, path.length - 1) 
          : path;

      final isLoginRoute = cleanPath == '/login';
      final isForgotRoute = cleanPath == '/forgot-password';
      final isUpdatePasswordRoute = cleanPath == '/update-password';
      final isResetCallback = cleanPath == '/reset-callback';

      // IF NOT LOGGED IN
      if (!isLoggedIn) {
        // Allow access to auth pages AND the reset callback
        if (!isLoginRoute && !isForgotRoute && !isUpdatePasswordRoute && !isResetCallback) {
          return '/login';
        }
      }

      // IF LOGGED IN
      if (isLoggedIn) {
        // If user is on an Auth page or the Callback page, send them Home
        if (isLoginRoute || isForgotRoute || isResetCallback) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // NEW: The screen for setting a new password
      GoRoute(
        path: '/update-password',
        builder: (context, state) => const UpdatePasswordScreen(),
      ),
      
      // The Callback Route (Loading Spinner)
      GoRoute(
        path: '/reset-callback',
        builder: (context, state) {

          // SAFETY NET:
          // If we are here, but Supabase already has a session, go Home immediately.
          // This handles cases where the auth state changed faster than the router could react.
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            // We use Future.microtask to navigate after the build frame finishes
            Future.microtask(() => context.go('/home'));
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/old-testament',
                builder: (context, state) => const OldTestamentScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/new-testament',
                builder: (context, state) => const NewTestamentScreen(),
              ),
            ],
          ),
        ],
      ),
      // Use the local 'rootNavigatorKey' for these routes to cover the tabs
      GoRoute(
        path: '/book/:bookId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final bookId = int.parse(state.pathParameters['bookId']!);
          final book = kBibleBooks.firstWhere((b) => b.id == bookId);
          return ChaptersScreen(book: book);
        },
      ),

      // Profile Route
      GoRoute(
        path: '/profile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Settings Route
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Detailed Stats Route
      GoRoute(
        path: '/detailed-stats',
        parentNavigatorKey: rootNavigatorKey, // Covers the bottom nav bar
        builder: (context, state) => const DetailedStatsScreen(),
      ),

      GoRoute(
        path: '/detailed-activity',
        parentNavigatorKey: rootNavigatorKey, // Covers the bottom bar
        builder: (context, state) => const ActivityAnalyticsScreen(),
      ),
    ],
  );
});

// Helper class to make Stream listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((dynamic _) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}