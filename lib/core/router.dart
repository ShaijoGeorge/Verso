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
import 'package:verso/features/about/screens/our_mission_screen.dart';
import 'package:verso/features/auth/providers/auth_providers.dart';
import 'package:verso/features/auth/screens/email_change_success_screen.dart';
import 'package:verso/features/auth/screens/forgot_password_screen.dart';
import 'package:verso/features/auth/screens/login_screen.dart';
import 'package:verso/features/auth/screens/profile_screen.dart';
import 'package:verso/features/auth/screens/update_password_screen.dart';
import 'package:verso/features/home/screens/home_screen.dart';
import 'package:verso/features/intro/screens/onboarding_screen.dart';
import 'package:verso/features/intro/screens/profile_setup_screen.dart';
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

  final refreshStream = GoRouterRefreshStream(authStream);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',

    // Refresh the router whenever Auth State changes (Login, Logout, Recovery)
    refreshListenable: refreshStream,

    // Debug Log to help us see errors
    errorBuilder: (context, state) {
      return NotFoundScreen(error: state.error);
    },

    redirect: (context, state) {
      // --- CRITICAL DEEP LINK INTERCEPTION ---
      if (state.uri.scheme == 'io.supabase.flutter') {
        final host = state.uri.host;
        final fragment = state.uri.fragment;
        final queryParams = state.uri.queryParameters;

        final isEmailChange = host == 'email-callback' ||
            fragment.contains('type=email_change') ||
            queryParams['type'] == 'email_change' ||
            fragment.contains('type%3Demail_change');

        final isEmailStepOne = fragment
                .contains('message=Confirmation+link+accepted') ||
            (queryParams['message']?.contains('Confirmation link accepted') ??
                false);

        if (isEmailChange) {
          final pending = ref.read(authRepositoryProvider).pendingEmail;
          final userEmail =
              Supabase.instance.client.auth.currentUser?.email ?? pending;
          return '/email-change-success${userEmail != null ? '?email=${Uri.encodeComponent(userEmail)}' : ''}';
        }

        if (isEmailStepOne) {
          return '/email-change-success?step=1';
        }

        if (host == 'reset-callback') {
          // If this was an email change flow where pending email is stored and it's not a password recovery
          final isRecovery = fragment.contains('type=recovery') ||
              queryParams['type'] == 'recovery';
          final pending = ref.read(authRepositoryProvider).pendingEmail;
          if (!isRecovery && pending != null) {
            return '/email-change-success?email=${Uri.encodeComponent(pending)}';
          }
          return '/reset-callback';
        }
      }

      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      final path = state.uri.path;

      // Normalize path to handle potential trailing slashes
      final cleanPath = path.endsWith('/') && path.length > 1
          ? path.substring(0, path.length - 1)
          : path;

      final isSplash = path == '/';
      final isLoginRoute = cleanPath == '/login';
      final isAddAccountLogin =
          isLoginRoute && state.uri.queryParameters['addAccount'] == 'true';
      final isForgotRoute = cleanPath == '/forgot-password';
      final isUpdatePasswordRoute = cleanPath == '/update-password';
      final isResetCallback = cleanPath == '/reset-callback';
      final isEmailSuccessRoute = cleanPath == '/email-change-success';

      final isOnboardingRoute = cleanPath == '/onboarding';
      final isProfileSetupRoute = cleanPath == '/profile-setup';

      // Allow Splash Screen to stay and do its own routing
      if (isSplash) {
        return null;
      }

      // IF NOT LOGGED IN
      if (!isLoggedIn) {
        // Allow access to /onboarding alongside the auth pages. Profile setup is now POST-login.
        if (!isLoginRoute &&
            !isForgotRoute &&
            !isUpdatePasswordRoute &&
            !isResetCallback &&
            !isEmailSuccessRoute &&
            !isOnboardingRoute) {
          return '/login';
        }
      }

      // IF LOGGED IN
      if (isLoggedIn) {
        // Check Supabase user_metadata for profile completeness.
        // currentUser is already in memory - this is synchronous, zero cost.
        final metadata =
            Supabase.instance.client.auth.currentUser?.userMetadata;
        final hasProfileData =
            metadata?['gender'] != null && metadata?['birthday'] != null;

        // Profile gate: if data is missing, intercept every route and send
        // the user to profile setup - EXCEPT if they're already there.
        if (!hasProfileData && !isProfileSetupRoute) {
          return '/profile-setup';
        }

        // Once profile is complete, bounce away from pre-auth screens.
        // Note: isForgotRoute and isEmailSuccessRoute are allowed while logged in.
        if ((isLoginRoute && !isAddAccountLogin) ||
            isOnboardingRoute ||
            (hasProfileData && isProfileSetupRoute)) {
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
        path: '/profile-setup',
        pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
          key: state.pageKey,
          child: const ProfileSetupScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) {
          final extra = state.extra;
          return AppPageTransitions.fadeThrough(
            key: state.pageKey,
            child: LoginScreen(
              initialEmail: extra is String ? extra : null,
              isAddingAccount:
                  state.uri.queryParameters['addAccount'] == 'true',
            ),
          );
        },
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
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            // Capture the navigator before the async gap to avoid BuildContext misuse.
            final go = context.go;
            Future.microtask(() async {
              final pending = await ref
                  .read(authRepositoryProvider)
                  .getPendingEmailChange();
              if (pending != null &&
                  session.user.email?.toLowerCase() == pending.toLowerCase()) {
                await ref
                    .read(authRepositoryProvider)
                    .clearPendingEmailChange();
                go('/email-change-success?email=${Uri.encodeComponent(pending)}');
              } else {
                go('/home');
              }
            });
          }

          return AppPageTransitions.fade(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),

      // Email Change Success Screen
      GoRoute(
        path: '/email-change-success',
        pageBuilder: (context, state) {
          final emailQuery = state.uri.queryParameters['email'];
          final isStepOne = state.uri.queryParameters['step'] == '1';
          final extra = state.extra;
          final emailExtra = extra is String ? extra : null;
          final email = emailQuery ??
              emailExtra ??
              Supabase.instance.client.auth.currentUser?.email;

          return AppPageTransitions.fadeThrough(
            key: state.pageKey,
            child: EmailChangeSuccessScreen(
              email: email,
              isStepOne: isStepOne,
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
          // Branch 0: Bible (The new combined screen)
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
          // Branch 1: Stats (Tabbed Stats Screen)
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
          // Branch 2: Home
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
          // Branch 3: History (Activity Log)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const ActivityLogScreen(),
                ),
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => AppPageTransitions.fadeThrough(
                  key: state.pageKey,
                  child: const ProfileScreen(),
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
          final bookIdStr = state.pathParameters['bookId'];
          final bookId =
              bookIdStr != null ? (int.tryParse(bookIdStr) ?? -1) : -1;
          final book =
              BibleData.findBookById(bookId) ?? BibleData.catholicCanon.first;
          return AppPageTransitions.slideFromRight(
            key: state.pageKey,
            child: ChaptersScreen(book: book),
          );
        },
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

      // Our Mission Route
      GoRoute(
        path: '/our-mission',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => AppPageTransitions.slideFromBottom(
          key: state.pageKey,
          child: const OurMissionScreen(),
        ),
      ),

      // Old detailed-stats and detailed-activity routes removed
      // Stats are now consolidated into the tabbed StatsScreen on Home
    ],
  );

  ref.onDispose(() {
    refreshStream.dispose();
    router.dispose();
  });

  return router;
});

// Helper class to make Stream listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.listen((authState) {
      if (authState.event == AuthChangeEvent.userUpdated) {
        return; // Ignore user updates to prevent unexpected redirects (e.g. during profile setup)
      }
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
