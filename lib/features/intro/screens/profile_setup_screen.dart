import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/core/widgets/verso_avatar.dart';
import 'package:verso/features/settings/data/settings_repository.dart';

/// Shown after successful login/registration if the user's profile is incomplete.
/// Collects gender and birthday, persists them to Supabase and locally,
/// then routes to /home.
///
/// The router gate automatically sends users here if they are logged in
/// but their Supabase user_metadata is missing gender or birthday.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  String? _selectedGender; // 'male' or 'female'
  DateTime? _selectedBirthday;
  bool _isSaving = false;

  // ── Animation Controllers ──────────────────────────────────────────────────
  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  // Floating particles controller (like onboarding)
  late final AnimationController _floatController;

  // Gender card scale-in controller
  late final AnimationController _cardRevealController;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
      ),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _cardRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _entryController.forward();

    // Stagger the card reveal slightly after the entry animation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _cardRevealController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    _cardRevealController.dispose();
    super.dispose();
  }

  // ── Gradient colors matched to avatar selections ───────────────────────────
  List<Color> get _backgroundGradient {
    if (_selectedGender == 'female') {
      // Pink/purple gradient matching the female avatar
      return const [
        Color(0xFF3D1F5C), // Deep Purple
        Color(0xFF8B3A6B), // Mauve
        Color(0xFF5C2D4F), // Dark Rose
      ];
    } else if (_selectedGender == 'male') {
      // Blue/celestial gradient matching the male avatar
      return const [
        Color(0xFF0F2A4A), // Deep Navy
        Color(0xFF1A4A7A), // Ocean Blue
        Color(0xFF0D3B5C), // Twilight
      ];
    }
    // Default: neutral dark gradient before any selection
    return const [
      Color(0xFF1A1A2E), // Dark Indigo
      Color(0xFF16213E), // Navy
      Color(0xFF0F3460), // Deep Blue
    ];
  }

  Color get _accentColor {
    if (_selectedGender == 'female') return const Color(0xFFD4A0C8);
    if (_selectedGender == 'male') return const Color(0xFF7EB8E0);
    return const Color(0xFF7EB8E0);
  }

  // ── Date Picker ────────────────────────────────────────────────────────────
  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthday ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'Select your birthday',
      fieldHintText: 'MM/DD/YYYY',
    );
    if (picked != null) {
      setState(() => _selectedBirthday = picked);
    }
  }

  // ── Save & Navigate ────────────────────────────────────────────────────────
  Future<void> _continue() async {
    if (_selectedGender == null || _selectedBirthday == null) return;

    setState(() => _isSaving = true);

    try {
      // 1. Sync to Supabase (User is guaranteed to be logged in here)
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'gender': _selectedGender,
            'birthday': '${_selectedBirthday!.year.toString().padLeft(4, '0')}-'
                '${_selectedBirthday!.month.toString().padLeft(2, '0')}-'
                '${_selectedBirthday!.day.toString().padLeft(2, '0')}',
          },
        ),
      );

      // 2. Save locally for instant offline access
      await SettingsRepository().saveUserProfile(
        gender: _selectedGender!,
        birthday: _selectedBirthday!,
      );

      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _formatBirthday(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  bool get _canContinue => _selectedGender != null && _selectedBirthday != null;

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _backgroundGradient,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Floating particles (background) ──────────────────────────
            ..._buildFloatingParticles(),

            // ── Main content ─────────────────────────────────────────────
            SafeArea(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xl,
                    ),
                    child: Column(
                      children: [
                        Gap(MediaQuery.of(context).size.height * 0.04),

                        // Header
                        _buildHeader(),
                        Gap(MediaQuery.of(context).size.height * 0.04),

                        // Gender Selection
                        _buildSectionLabel('Who are you?'),
                        const Gap(Spacing.lg),
                        _buildGenderCards(),
                        Gap(MediaQuery.of(context).size.height * 0.035),

                        // Birthday
                        _buildSectionLabel('When is your birthday?'),
                        const Gap(Spacing.md),
                        _buildBirthdayCard(),
                        Gap(MediaQuery.of(context).size.height * 0.05),

                        // Continue Button
                        _buildContinueButton(),
                        const Gap(Spacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating Particles
  List<Widget> _buildFloatingParticles() {
    // Decorative floating icons - same technique as onboarding
    const elements = [
      _ParticleData(Icons.favorite_rounded, 0.12, 0.08, 18, 0),
      _ParticleData(Icons.star_rounded, 0.85, 0.12, 16, 0.3),
      _ParticleData(Icons.auto_awesome_rounded, 0.08, 0.45, 14, 0.5),
      _ParticleData(Icons.light_mode_rounded, 0.88, 0.38, 16, 0.2),
      _ParticleData(Icons.cake_rounded, 0.15, 0.75, 14, 0.7),
      _ParticleData(Icons.emoji_emotions_rounded, 0.82, 0.7, 16, 0.4),
    ];

    return elements.map((e) {
      return Positioned(
        left: MediaQuery.of(context).size.width * e.x,
        top: MediaQuery.of(context).size.height * e.y,
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final phase = e.delay * math.pi * 2;
            final yOffset =
                math.sin(_floatController.value * math.pi + phase) * 8;
            final opacity =
                0.15 + math.sin(_floatController.value * math.pi + phase) * 0.1;

            return Transform.translate(
              offset: Offset(0, yOffset),
              child: Icon(
                e.icon,
                size: e.size,
                color:
                    _accentColor.withValues(alpha: opacity.clamp(0.08, 0.25)),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // Step pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: _accentColor.withValues(alpha: 0.15),
            borderRadius: AppRadii.borderRadiusFull,
            border: Border.all(
              color: _accentColor.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            'Almost there',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _accentColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Gap(Spacing.lg),
        Text(
          'Tell us about\nyourself',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 38,
            height: 1.15,
            color: Colors.white,
          ),
        ),
        const Gap(Spacing.sm),
        Text(
          'This helps us personalise your experience',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.55),
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ── Section Label ──────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.5),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Gender Cards ───────────────────────────────────────────────────────────
  Widget _buildGenderCards() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _cardRevealController,
        curve: Curves.easeOutBack,
      ),
      child: FadeTransition(
        opacity: _cardRevealController,
        child: Row(
          children: [
            Expanded(
              child: _PremiumGenderCard(
                label: 'Boy',
                gender: 'male',
                isSelected: _selectedGender == 'male',
                accentColor: const Color(0xFF7EB8E0),
                gradientColors: const [Color(0xFF1A4A7A), Color(0xFF0F2A4A)],
                floatController: _floatController,
                onTap: () => setState(() => _selectedGender = 'male'),
              ),
            ),
            const Gap(Spacing.md),
            Expanded(
              child: _PremiumGenderCard(
                label: 'Girl',
                gender: 'female',
                isSelected: _selectedGender == 'female',
                accentColor: const Color(0xFFD4A0C8),
                gradientColors: const [Color(0xFF8B3A6B), Color(0xFF3D1F5C)],
                floatController: _floatController,
                onTap: () => setState(() => _selectedGender = 'female'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Birthday Card ──────────────────────────────────────────────────────────
  Widget _buildBirthdayCard() {
    final hasBirthday = _selectedBirthday != null;

    return GestureDetector(
      onTap: _pickBirthday,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: hasBirthday
              ? _accentColor.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasBirthday
                ? _accentColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.12),
            width: hasBirthday ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon with animated accent
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasBirthday
                    ? _accentColor.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.cake_rounded,
                size: 24,
                color: hasBirthday
                    ? _accentColor
                    : Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const Gap(Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birthday',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  const Gap(2),
                  Text(
                    hasBirthday
                        ? _formatBirthday(_selectedBirthday!)
                        : 'Tap to select your birthday',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight:
                          hasBirthday ? FontWeight.w600 : FontWeight.w400,
                      color: hasBirthday
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ── Continue Button ────────────────────────────────────────────────────────
  Widget _buildContinueButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      opacity: _canContinue ? 1.0 : 0.35,
      child: GestureDetector(
        onTap: _canContinue && !_isSaving ? _continue : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: _canContinue
                ? LinearGradient(
                    colors: [
                      _accentColor,
                      _accentColor.withValues(alpha: 0.7),
                    ],
                  )
                : null,
            color: _canContinue ? null : Colors.white.withValues(alpha: 0.1),
            borderRadius: AppRadii.borderRadiusFull,
            boxShadow: _canContinue
                ? [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _canContinue
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Gap(8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: _canContinue
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Particle data model (like _FloatingElement in onboarding)
// =============================================================================
class _ParticleData {
  const _ParticleData(this.icon, this.x, this.y, this.size, this.delay);
  final IconData icon;
  final double x;
  final double y;
  final double size;
  final double delay;
}

// =============================================================================
// Premium Gender Card - rich, animated selection card with avatar
// =============================================================================
class _PremiumGenderCard extends StatelessWidget {
  const _PremiumGenderCard({
    required this.label,
    required this.gender,
    required this.isSelected,
    required this.accentColor,
    required this.gradientColors,
    required this.floatController,
    required this.onTap,
  });

  final String label;
  final String gender;
  final bool isSelected;
  final Color accentColor;
  final List<Color> gradientColors;
  final AnimationController floatController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding:
            const EdgeInsets.symmetric(vertical: Spacing.lg, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradientColors[0].withValues(alpha: 0.8),
                    gradientColors[1].withValues(alpha: 0.6),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar image with animated glow ring
            AnimatedBuilder(
              animation: floatController,
              builder: (context, child) {
                final glowOpacity =
                    isSelected ? 0.2 + floatController.value * 0.15 : 0.0;

                return Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: glowOpacity),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ]
                        : [],
                  ),
                  child: VersoAvatar.fromGender(
                    gender,
                    size: 108,
                    borderWidth: isSelected ? 3 : 1.5,
                    borderColor: isSelected
                        ? accentColor
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                );
              },
            ),
            const Gap(Spacing.md),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? accentColor
                    : Colors.white.withValues(alpha: 0.5),
              ),
              child: Text(label),
            ),
            const Gap(Spacing.xs),

            // Check indicator
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 250),
                scale: isSelected ? 1.0 : 0.5,
                curve: Curves.easeOutBack,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
