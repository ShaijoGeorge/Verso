import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gap/gap.dart';
import '../../settings/data/settings_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _startTimer();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = "v${info.version}";
      });
    }
  }

  void _startTimer() {
    // Show splash for 1.5 seconds, then decide where to go
    Timer(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        context.go('/home');
      } else {
        // Logged out -> Check if they've seen onboarding
        final repo = SettingsRepository();
        final hasSeenOnboarding = await repo.hasSeenOnboarding();

        if (!mounted) return;

        if (hasSeenOnboarding) {
          context.go('/login');
        } else {
          context.go('/onboarding');
        }
      }
    });
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
                  "by SHAIJO GEORGE",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontFamily: 'Metropolis', 
                    letterSpacing: 1.2,
                  ),
                ),
                const Gap(4), 
                Text(
                  _version,
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