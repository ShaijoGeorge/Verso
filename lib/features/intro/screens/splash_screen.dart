import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final minimumDelay =
        Future<void>.delayed(const Duration(milliseconds: 1500));
    final repo = SettingsRepository();
    final hasSeenOnboarding = await repo.hasSeenOnboarding();
    await minimumDelay;

    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // ── Already logged in → go straight to the app ───────────────────────
      context
          .go('/home'); // Router gate will intercept if profile is incomplete
    } else if (!hasSeenOnboarding) {
      // ── Brand new user → start from the beginning ─────────────────────────
      context.go('/onboarding');
    } else {
      // ── Fully onboarded, no session → login screen ────────────────────────
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0E1D38),
              Color(0xFF173254),
              Color(0xFF0A1426),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Ambient radial halo behind logo
            Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC59434).withValues(alpha: 0.16),
                      const Color(0xFF7CB8F7).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 1. Centered Logo
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    // Using your app logo
                    child: Image.asset(
                      'assets/app_logo.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                  const Gap(20),
                  Text(
                    'Verso',
                    style: GoogleFonts.dmSerifDisplay(
                      color: Colors.white,
                      fontSize: 34,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    'SACRED SCRIPTURE TRACKER',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFE2B45A),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Bottom Info (Credits + Version)
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + 24,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'CRAFTED BY SHAIJO GEORGE',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontFamily: 'Metropolis',
                      letterSpacing: 1.6,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'v${ref.watch(packageInfoProvider).version}',
                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 10,
                      fontFamily: 'Metropolis',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
