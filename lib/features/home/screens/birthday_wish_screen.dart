import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';

/// Birthday Wish Screen inspired by Verso's Onboarding aesthetic.
///
/// Features:
/// - Dynamic localization ONLY for scripture verse and reference (Malayalam / English).
/// - Clean editorial typography, rounded card aesthetic, and capsule CTA button.
class BirthdayWishScreen extends ConsumerStatefulWidget {
  const BirthdayWishScreen({super.key});

  @override
  ConsumerState<BirthdayWishScreen> createState() => _BirthdayWishScreenState();
}

class _BirthdayWishScreenState extends ConsumerState<BirthdayWishScreen>
    with TickerProviderStateMixin {
  late final AnimationController _illustrationController;
  late final AnimationController _entryController;

  static const _illustrationElements = [
    _IllustrationElement(
      icon: Icons.auto_awesome_rounded,
      x: 0.14,
      y: 0.18,
      size: 24,
      color: Color(0xFFFFB703), // Vibrant Solar Gold
      delay: 0,
    ),
    _IllustrationElement(
      icon: Icons.star_rounded,
      x: 0.86,
      y: 0.16,
      size: 22,
      color: Color(0xFFFDE047), // Radiant Star Yellow
      delay: 0.35,
    ),
    _IllustrationElement(
      icon: Icons.favorite_rounded,
      x: 0.88,
      y: 0.74,
      size: 24,
      color: Color(0xFFFB7185), // Vibrant Coral Rose
      delay: 0.65,
    ),
    _IllustrationElement(
      icon: Icons.menu_book_rounded,
      x: 0.12,
      y: 0.76,
      size: 24,
      color: Color(0xFF2DD4BF), // Electric Mint Teal
      delay: 0.20,
    ),
    _IllustrationElement(
      icon: Icons.local_fire_department_rounded,
      x: 0.50,
      y: 0.06,
      size: 22,
      color: Color(0xFFFB923C), // Energetic Flame Orange
      delay: 0.50,
    ),
  ];

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();

    // Floating sine wave animation for illustration elements
    _illustrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Staggered entrance animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _illustrationController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  String _resolveUserName() {
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata;
    final rawName = meta?['full_name'] as String? ??
        meta?['name'] as String? ??
        user?.email?.split('@').first ??
        'Friend';
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) return 'Friend';
    final first = trimmed.split(' ').first;
    return first[0].toUpperCase() + first.substring(1);
  }

  /// Returns Numbers 6:24-26 in the user's selected Bible language ('ml' or 'en').
  /// Only the verse text and reference are dynamically localized.
  String _getVerseText(String langCode) {
    if (langCode == 'ml') {
      return '“കർത്താവ് നിന്നെ അനുഗ്രഹിക്കുകയും സംരക്ഷിക്കുകയും ചെയ്യട്ടെ. കർത്താവ് തന്റെ മുഖം നിന്റെമേൽ പ്രകാശിപ്പിക്കുകയും നിന്നോട് കൃപ കാണിക്കുകയും ചെയ്യട്ടെ. കർത്താവ് തന്റെ മുഖം നിന്റെ നേരെ തിരിക്കുകയും നിനക്ക് സമാധാനം നൽകുകയും ചെയ്യട്ടെ.”';
    }
    return '“The Lord bless you and keep you; the Lord make his face shine on you and be gracious to you; the Lord turn his face toward you and give you peace.”';
  }

  String _getVerseReference(String langCode) {
    if (langCode == 'ml') {
      return 'സംഖ്യ 6:24-26';
    }
    return 'Numbers 6:24-26';
  }

  Widget _buildStaggered({
    required double start,
    required double end,
    required Widget child,
  }) {
    final curve = CurvedAnimation(
      parent: _entryController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = _BirthdayPalette.of(context);
    final bibleLanguage = ref.watch(activeBibleLanguageProvider);
    final isMalayalam = bibleLanguage == 'ml';
    final verseText = _getVerseText(bibleLanguage);
    final verseRef = _getVerseReference(bibleLanguage);
    final firstName = _resolveUserName();

    return Scaffold(
      backgroundColor: palette.gradientColors.first,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-bleed energetic gradient background (Onboarding style)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: palette.gradientColors,
                stops: const [0.0, 0.50, 1.0],
              ),
            ),
          ),

          // 2. Viewport-fitted Responsive Scroll View
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 720;
                final illustrationHeight = isCompact ? 220.0 : 265.0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    Spacing.xl,
                    Spacing.xs,
                    Spacing.xl,
                    isCompact ? Spacing.md : Spacing.xl,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight -
                          (isCompact ? Spacing.md : Spacing.xl),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top Action Bar (Share & Dismiss)
                          _buildStaggered(
                            start: 0,
                            end: 0.4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _TopActionButton(
                                  icon: Icons.ios_share_rounded,
                                  accentColor: palette.accentColor,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    SharePlus.instance.share(
                                      ShareParams(
                                        text:
                                            '$verseText\n— $verseRef\n\nCelebrating another year of grace with Verso! ✨',
                                      ),
                                    );
                                  },
                                ),
                                _TopActionButton(
                                  icon: Icons.close_rounded,
                                  accentColor: palette.accentColor,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    context.canPop()
                                        ? context.pop()
                                        : context.go('/home');
                                  },
                                ),
                              ],
                            ),
                          ),

                          const Gap(Spacing.xs),

                          // Hero Section: Expansive, Uncropped Floating Illustration
                          _buildStaggered(
                            start: 0.1,
                            end: 0.6,
                            child: SizedBox(
                              height: illustrationHeight,
                              child: _IllustrationArea(
                                accentColor: palette.accentColor,
                                animationController: _illustrationController,
                                elements: _illustrationElements,
                                isCompact: isCompact,
                              ),
                            ),
                          ),

                          const Gap(Spacing.xs),

                          // Text Section: Badge, Title & Subtitle (All in English)
                          _buildStaggered(
                            start: 0.2,
                            end: 0.7,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.accentColor
                                        .withValues(alpha: 0.14),
                                    borderRadius: AppRadii.borderRadiusFull,
                                    border: Border.all(
                                      color: palette.accentColor
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 13,
                                        color: palette.accentColor,
                                      ),
                                      const Gap(6),
                                      Text(
                                        'A SACRED BLESSING',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.4,
                                          color: palette.accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Gap(isCompact ? Spacing.xs : Spacing.sm),
                                Text(
                                  'Happy Birthday,\n$firstName',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: isCompact ? 30.0 : 36.0,
                                    fontWeight: FontWeight.w400,
                                    color: palette.textPrimary,
                                    height: 1.15,
                                  ),
                                ),
                                Gap(isCompact ? Spacing.xs : Spacing.sm),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 320),
                                  child: Text(
                                    'Celebrating the gift of your life and another year of walking faithfully in His Word.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: isCompact ? 13.0 : 14.5,
                                      fontWeight: FontWeight.w400,
                                      color: palette.textSecondary,
                                      height: 1.5,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Gap(isCompact ? Spacing.sm : Spacing.md),

                          // Scripture Card: Dynamic Localization ONLY for Verse & Reference
                          _buildStaggered(
                            start: 0.35,
                            end: 0.85,
                            child: _ScriptureBlessingCard(
                              verse: verseText,
                              reference: verseRef,
                              isMalayalam: isMalayalam,
                              palette: palette,
                              isCompact: isCompact,
                            ),
                          ),

                          Gap(isCompact ? Spacing.md : Spacing.lg),

                          // Bottom Controls: Animated Pill CTA Button
                          _buildStaggered(
                            start: 0.5,
                            end: 1,
                            child: _AnimatedCTAButton(
                              label: 'Continue in the Word',
                              icon: Icons.arrow_forward_rounded,
                              accentColor: palette.accentColor,
                              foregroundColor: palette.ctaForeground,
                              shadowColor: palette.ctaShadowColor,
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                context.canPop()
                                    ? context.pop()
                                    : context.go('/home');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Energetic Vibrant Color Palette (Dark & Light Mode aware, No Theme Profile)
// ---------------------------------------------------------------------------

class _BirthdayPalette {
  const _BirthdayPalette({
    required this.gradientColors,
    required this.accentColor,
    required this.cardBackground,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.ctaForeground,
    required this.ctaShadowColor,
  });

  factory _BirthdayPalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return _BirthdayPalette(
        // Vibrant Royal Amethyst & Electric Midnight Violet (Zero dull brown/coffee)
        gradientColors: const [
          Color(0xFF2E1065), // Vibrant Royal Violet 950
          Color(0xFF1E0842), // Deep Electric Amethyst
          Color(0xFF0F0324), // Midnight Obsidian Violet
        ],
        accentColor: const Color(0xFFFFB703), // Luminous Electric Solar Gold
        cardBackground: const Color(0xFF261147).withValues(alpha: 0.82),
        cardBorder: const Color(0xFFFFB703).withValues(alpha: 0.32),
        textPrimary: Colors.white, // Pure crisp white
        textSecondary: const Color(0xFFE9D8FD), // Radiant lavender-white
        textMuted: const Color(0xFFC4B5FD), // Vibrant periwinkle
        ctaForeground:
            const Color(0xFF1F0838), // High-contrast deep purple on gold
        ctaShadowColor: const Color(0xFFFFB703).withValues(alpha: 0.45),
      );
    } else {
      return const _BirthdayPalette(
        // Radiant Celebration Lilac & Amethyst Champagne
        gradientColors: [
          Color(0xFFFAF5FF), // Luminous soft lilac-white
          Color(0xFFF3E8FF), // Vibrant light amethyst
          Color(0xFFE9D5FF), // Radiant celebration purple 200
        ],
        accentColor: Color(0xFF7C3AED), // Electric Royal Violet 600
        cardBackground: Color(0xF4FFFFFF), // Translucent crisp white
        cardBorder: Color(0x477C3AED), // 28% Electric Violet
        textPrimary: Color(0xFF1E0A3C), // Deep rich royal indigo
        textSecondary: Color(0xFF5B3B8C), // Vibrant violet slate
        textMuted: Color(0xFF8B6CB5), // Soft purple stone
        ctaForeground: Colors.white, // Crisp white on royal violet
        ctaShadowColor: Color(0x617C3AED), // Soft electric violet glow
      );
    }
  }

  final List<Color> gradientColors;
  final Color accentColor;
  final Color cardBackground;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color ctaForeground;
  final Color ctaShadowColor;
}

// ---------------------------------------------------------------------------
// Expansive Hero Illustration Area (Completely Uncropped)
// ---------------------------------------------------------------------------

class _IllustrationElement {
  const _IllustrationElement({
    required this.icon,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.delay,
  });

  final IconData icon;
  final double x;
  final double y;
  final double size;
  final Color color;
  final double delay;
}

class _IllustrationArea extends StatelessWidget {
  const _IllustrationArea({
    required this.accentColor,
    required this.animationController,
    required this.elements,
    required this.isCompact,
  });

  final Color accentColor;
  final AnimationController animationController;
  final List<_IllustrationElement> elements;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ample dimensions so the centerpiece is bold and proud
        final centerSize = isCompact ? 102.0 : 118.0;

        return Stack(
          clipBehavior:
              Clip.none, // Crucial: Never crop elements or glowing rings
          alignment: Alignment.center,
          children: [
            // Inner scale glowing ring behind center icon
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final scale = 1.0 + animationController.value * 0.08;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: centerSize + 44,
                    height: centerSize + 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.22),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Outer counter-scale ring
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final scale = 1.0 + (1 - animationController.value) * 0.06;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: centerSize + 90,
                    height: centerSize + 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.10),
                        width: 1.2,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Center icon container (celebration cake)
            Container(
              width: centerSize,
              height: centerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.28),
                    accentColor.withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.45),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.30),
                    blurRadius: 34,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                Icons.cake_rounded,
                size: centerSize * 0.48,
                color: accentColor,
              ),
            ),

            // Floating orbital elements (using Clip.none so they never crop)
            ...elements.map((element) {
              final boxSize = element.size + 20;
              return Positioned(
                left: constraints.maxWidth * element.x - boxSize / 2,
                top: constraints.maxHeight * element.y - boxSize / 2,
                child: _FloatingIcon(
                  element: element,
                  animationController: animationController,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({
    required this.element,
    required this.animationController,
  });

  final _IllustrationElement element;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final phase = element.delay * math.pi * 2;
        final yOffset =
            math.sin(animationController.value * math.pi + phase) * 7;
        final opacity =
            0.65 + math.sin(animationController.value * math.pi + phase) * 0.30;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Container(
            width: element.size + 20,
            height: element.size + 20,
            decoration: BoxDecoration(
              color: element.color.withValues(alpha: 0.16),
              borderRadius: AppRadii.borderRadiusMD,
              border: Border.all(
                color: element.color.withValues(alpha: 0.38),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: element.color.withValues(alpha: 0.22),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              element.icon,
              size: element.size,
              color: element.color.withValues(alpha: opacity.clamp(0.5, 1.0)),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Scripture Blessing Card (Dynamic Localization ONLY for Verse & Reference)
// ---------------------------------------------------------------------------

class _ScriptureBlessingCard extends StatelessWidget {
  const _ScriptureBlessingCard({
    required this.verse,
    required this.reference,
    required this.isMalayalam,
    required this.palette,
    required this.isCompact,
  });

  final String verse;
  final String reference;
  final bool isMalayalam;
  final _BirthdayPalette palette;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final verseTextStyle = isMalayalam
        ? GoogleFonts.notoSerifMalayalam(
            fontSize: isCompact ? 14.5 : 16.0,
            height: 1.72,
            fontWeight: FontWeight.w500,
            color: palette.textPrimary,
          )
        : GoogleFonts.dmSerifDisplay(
            fontSize: isCompact ? 17.0 : 19.0,
            height: 1.45,
            fontStyle: FontStyle.italic,
            color: palette.textPrimary,
          );

    final referenceTextStyle = isMalayalam
        ? GoogleFonts.notoSansMalayalam(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: palette.accentColor,
          )
        : GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: palette.accentColor,
          );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: AppRadii.borderRadiusXL,
        border: Border.all(
          color: palette.cardBorder,
          width: 1.2,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: palette.accentColor.withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle watermark quote mark
          Positioned(
            right: 8,
            top: 2,
            child: Icon(
              Icons.format_quote_rounded,
              size: 72,
              color: palette.accentColor.withValues(alpha: 0.08),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: isCompact ? Spacing.md : Spacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Quote Icon
                Icon(
                  Icons.format_quote_rounded,
                  size: 26,
                  color: palette.accentColor.withValues(alpha: 0.85),
                ),
                Gap(isCompact ? Spacing.xs : Spacing.sm),

                // Verse Text (Malayalam when 'ml', English when 'en')
                Text(
                  verse,
                  textAlign: TextAlign.center,
                  style: verseTextStyle,
                ),
                Gap(isCompact ? Spacing.sm : Spacing.md),

                // Reference Pill (Malayalam when 'ml', English when 'en')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: palette.accentColor.withValues(alpha: 0.14),
                    borderRadius: AppRadii.borderRadiusFull,
                    border: Border.all(
                      color: palette.accentColor.withValues(alpha: 0.32),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        size: 13,
                        color: palette.accentColor,
                      ),
                      const Gap(6),
                      Text(
                        reference,
                        style: referenceTextStyle,
                      ),
                    ],
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

// ---------------------------------------------------------------------------
// Action Buttons & CTA (Derived from Onboarding CTA Button)
// ---------------------------------------------------------------------------

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.14),
          shape: BoxShape.circle,
          border: Border.all(
            color: accentColor.withValues(alpha: 0.30),
          ),
        ),
        child: Icon(
          icon,
          size: 19,
          color: accentColor,
        ),
      ),
    );
  }
}

class _AnimatedCTAButton extends StatelessWidget {
  const _AnimatedCTAButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.foregroundColor,
    required this.shadowColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final Color foregroundColor;
  final Color shadowColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: AppRadii.borderRadiusFull,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: foregroundColor,
                letterSpacing: 0.3,
              ),
            ),
            const Gap(8),
            Icon(
              icon,
              color: foregroundColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
