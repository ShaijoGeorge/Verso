import 'package:flutter/material.dart';
import 'package:verso/core/design/profiles/theme_profile.dart';
import 'package:verso/core/design/profiles/verso_palette.dart';
import 'package:verso/data/local/entities/user_settings.dart';

/// "Limelight" — playful, gamified aesthetic with energetic greens and golds.
///
/// Bright lime-green primary, golden-yellow accents for achievements,
/// sky-blue secondary, clean whites in light mode, and teal-charcoal darks.
const ThemeProfile limelightProfile = ThemeProfile(
  id: 'limelight',
  name: 'Limelight',
  tagline: 'Bright Green × Golden Yellow × Sky Blue',
  description:
      'A playful, gamified color scheme — bright green for primary actions, golden yellow for achievements and highlights, sky blue for secondary elements, and clean surfaces that keep the focus on content.',
  inspiration: 'Gamified learning interfaces, playful mobile UI',
  light: VersoPalette(
    style: AppearanceStyle.light,
    // Clean white canvas
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF7F7F7),
    // Soft grey borders
    border: Color(0xFFE5E5E5),
    borderLight: Color(0xFFF0F0F0),
    // Lime green
    primary: Color(0xFF58CC02),
    primaryHover: Color(0xFF4CAD02),
    // Sky blue
    secondary: Color(0xFF1CB0F6),
    accent: Color(0xFFFFC800), // Golden yellow
    accentBright: Color(0xFFFFD633),
    accentSoft: Color(0xFFF0FAE6), // Very light green tint
    // Dark text on white
    text: Color(0xFF3C3C3C),
    textMuted: Color(0xFFAFAFAF),
    textLight: Color(0xFFD4D4D4),
    // Status
    success: Color(0xFF58CC02),
    warning: Color(0xFFFFC800),
    danger: Color(0xFFFF4B4B),
    // Progress uses green
    progress: Color(0xFF58CC02),
    progressBg: Color(0xFFE6F7D9),
    // Tags use blue tint
    tag: Color(0xFFE5F5FE),
    tagText: Color(0xFF1CB0F6),
    divider: Color(0xFFE5E5E5),
    // Footer
    footerBg: Color(0xFFFFFFFF),
    footerActive: Color(0xFF58CC02),
    footerInactive: Color(0xFFAFAFAF),
    // Highlight uses golden tint
    highlight: Color(0xFFFFF8E0),
    cross: Color(0xFF58CC02),
  ),
  dark: VersoPalette(
    style: AppearanceStyle.dark,
    // Charcoal darks
    bg: Color(0xFF131F24),
    surface: Color(0xFF1A2B32),
    surfaceAlt: Color(0xFF233840),
    // Subtle dark borders
    border: Color(0xFF2E4A54),
    borderLight: Color(0xFF233840),
    // Green stays vibrant
    primary: Color(0xFF58CC02),
    primaryHover: Color(0xFF6EE018),
    // Sky blue
    secondary: Color(0xFF1CB0F6),
    accent: Color(0xFFFFC800),
    accentBright: Color(0xFFFFD633),
    accentSoft: Color(0xFF1A2E14), // Dark green tint
    // Light text on dark
    text: Color(0xFFF0F0F0),
    textMuted: Color(0xFF8BA0A8),
    textLight: Color(0xFF4A5E66),
    // Status
    success: Color(0xFF58CC02),
    warning: Color(0xFFFFC800),
    danger: Color(0xFFFF4B4B),
    // Progress
    progress: Color(0xFF58CC02),
    progressBg: Color(0xFF1A2E14),
    // Tags
    tag: Color(0xFF122838),
    tagText: Color(0xFF1CB0F6),
    divider: Color(0xFF233840),
    // Footer
    footerBg: Color(0xFF1A2B32),
    footerActive: Color(0xFF58CC02),
    footerInactive: Color(0xFF5E7880),
    // Highlight
    highlight: Color(0xFF2E2A10),
    cross: Color(0xFF58CC02),
  ),
);
