import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/providers/package_info_provider.dart';
import 'package:verso/features/settings/data/settings_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  Future<void> _startTimer() async {
    // Define our tasks - run all three in parallel for speed
    final minimumDelay = Future<void>.delayed(const Duration(milliseconds: 1500));
    final repo = SettingsRepository();
    final checkOnboarding = repo.hasSeenOnboarding();
    final checkProfileSetup = repo.hasCompletedProfileSetup();

    // Await all three concurrently
    final results = await Future.wait([checkOnboarding, checkProfileSetup]);
    await minimumDelay;

    final hasSeenOnboarding = results[0];
    final hasCompletedProfileSetup = results[1];

    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // ── Already logged in → go straight to the app ───────────────────────
      context.go('/home');
    } else if (!hasSeenOnboarding) {
      // ── Brand new user → start from the beginning ─────────────────────────
      context.go('/onboarding');
    } else if (!hasCompletedProfileSetup) {
      // ── Completed onboarding but quit before finishing profile setup ───────
      // This handles the "killed app mid profile-setup" case for new users.
      // Existing users before this feature shipped always have
      // has_completed_profile_setup = false (key doesn't exist), BUT they
      // also have an active session, so they hit the branch above first.
      // The only way to reach here without a session is a new user mid-flow.
      context.go('/profile-setup');
    } else {
      // ── Fully onboarded, no session → login screen ────────────────────────
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF38B6FF),
      body: Stack(
        children: [
          // 1. Centered Logo
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Using your app logo
                Image.asset(
                  'assets/app_logo.png',
                  width: 150,
                  height: 150,
                ),
              ],
            ),
          ),

          // 2. Bottom Info (Credits + Version)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'by SHAIJO GEORGE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontFamily: 'Metropolis',
                    letterSpacing: 1.2,
                  ),
                ),
                const Gap(4),
                Text(
                  'v${ref.watch(packageInfoProvider).version}',
                  style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 10,
                    fontFamily: 'Metropolis',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
