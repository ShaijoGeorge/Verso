import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/transitions/animated_branch_container.dart';
import 'package:verso/core/transitions/app_page_transitions.dart';
import 'package:verso/core/widgets/main_wrapper.dart';
import 'package:verso/core/widgets/not_found_screen.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/features/auth/screens/forgot_password_screen.dart';
import 'package:verso/features/auth/screens/login_screen.dart';
import 'package:verso/features/auth/screens/profile_screen.dart';
import 'package:verso/features/auth/screens/update_password_screen.dart';
import 'package:verso/features/home/screens/home_screen.dart';
import 'package:verso/features/intro/screens/onboarding_screen.dart';
import 'package:verso/features/intro/screens/splash_screen.dart';
import 'package:verso/features/reading/screens/bible_screen.dart';
import 'package:verso/features/reading/screens/chapters_screen.dart';
import 'package:verso/features/settings/screens/settings_screen.dart';
import 'package:verso/features/stats/screens/activity_log_screen.dart';
import 'package:verso/features/stats/screens/stats_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to the Supabase Auth Stream directly
  final authStream = Supabase.instance.client.auth.onAuthStateChange;

  // FIX 1 (Continued): Create the key INSIDE the provider.
  // This ensures a fresh key is generated whenever the Router is rebuilt.
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',

    // Refresh the router whenever Auth State changes (Login, Logout, Recovery)
    refreshListenable: GoRouterRefreshStream(authStream),

    // Debug Log to help us see errors
    errorBuilder: (context, state) {
      return NotFoundScreen(error: state.error);
    },

    redirect: (context, state) {
      // --- CRITICAL FIX START ---
      // Intercept the raw deep link from Android and convert it to a valid path
      if (state.uri.scheme == 'io.supabase.flutter' &&
          state.uri.host == 'reset-callback') {
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

      final isSplash = path == '/';
      final isLoginRoute = cleanPath == '/login';
      final isForgotRoute = cleanPath == '/forgot-password';
      final isUpdatePasswordRoute = cleanPath == '/update-password';
      final isResetCallback = cleanPath == '/reset-callback';

      final isOnboardingRoute = cleanPath == '/onboarding';

      // Allow Splash Screen to stay
      if (isSplash) {
        return null;
      }

      // IF NOT LOGGED IN
      if (!isLoggedIn) {
        // Allow access to /onboarding alongside the auth pages
        if (!isLoginRoute &&
            !isForgotRoute &&
            !isUpdatePasswordRoute &&
            !isResetCallback &&
            !isOnboardingRoute) {
          return '/login';
        }
      }

      // IF LOGGED IN
      if (isLoggedIn) {
        // If they somehow navigate to /onboarding while logged in, send them Home
        if (isLoginRoute ||
            isForgotRoute ||
            isResetCallback ||
            isOnboardingRoute) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      // NEW: The screen for setting a new password
      GoRoute(
        path: '/update-password',
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          key: state.pageKey,
          child: const UpdatePasswordScreen(),
        ),
      ),

      // The Callback Route (Loading Spinner)
      GoRoute(
        path: '/reset-callback',
        pageBuilder: (context, state) {
          // SAFETY NET:
          // If we are here, but Supabase already has a session, go Home immediately.
          // This handles cases where the auth state changed faster than the router could react.
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            // Capture the navigator before the async gap to avoid BuildContext misuse.
            final go = context.go;
            Future.microtask(() => go('/home'));
          }

          return AppPageTransitions.fade(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),

      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        // Replaces the default IndexedStack with a cross-fading Stack while
        // keeping every branch mounted (preserves per-tab state).
        navigatorContainerBuilder: (context, navigationShell, children) {
          return AnimatedBranchContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          );
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          // Branch 1: Bible (The new combined screen)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bible',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const BibleScreen(),
                ),
              ),
            ],
          ),
          // Branch 2: Stats (Tabbed Stats Screen)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                pageBuilder: (context, state) {
                  final tab = state.uri.queryParameters['tab'];
                  var initialIndex = 0;
                  if (tab == 'weekly') {
                    initialIndex = 1;
                  } else if (tab == 'monthly') {
                    initialIndex = 2;
                  } else if (tab == 'yearly') {
                    initialIndex = 3;
                  }
                  return AppPageTransitions.fadeThrough(
                    key: state.pageKey,
                    child: StatsScreen(initialIndex: initialIndex),
                  );
                },
              ),
            ],
          ),
          // Branch 3: Journal (Activity Log)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const ActivityLogScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      // Use the local 'rootNavigatorKey' for these routes to cover the tabs
      GoRoute(
        path: '/book/:bookId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final bookId = int.parse(state.pathParameters['bookId']!);
          final book = kBibleBooks.firstWhere((b) => b.id == bookId);
          return AppPageTransitions.slideFromRight(
            key: state.pageKey,
            child: ChaptersScreen(book: book),
          );
        },
      ),

      // Profile Route
      GoRoute(
        path: '/profile',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideFromBottom(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),

      // Settings Route
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideFromBottom(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),

      // Old detailed-stats and detailed-activity routes removed
      // Stats are now consolidated into the tabbed StatsScreen on Home
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
