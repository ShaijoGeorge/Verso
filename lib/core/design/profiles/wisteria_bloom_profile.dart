import 'package:flutter/material.dart';
import 'package:verso/core/design/profiles/theme_profile.dart';
import 'package:verso/core/design/profiles/verso_palette.dart';
import 'package:verso/core/design/tokens/colors.dart';
import 'package:verso/data/local/entities/user_settings.dart';

/// "Wisteria Bloom" - Deep Violet × Soft Orchid × Periwinkle.
const ThemeProfile wisteriaBloomProfile = ThemeProfile(
  id: 'wisteria_bloom',
  name: 'Wisteria Bloom',
  tagline: 'Deep Violet × Soft Orchid × Periwinkle',
  description:
      'A floral palette inspired by wisteria blossoms and evening skies. Deep purples ground the reading experience, while bright orchid and soft periwinkle provide elegant accents.',
  inspiration: 'Wisteria vines, spring dusk, orchid petals',
  light: VersoPalette(
    style: AppearanceStyle.light,
    bg: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    surfaceAlt: Color(0xFFF5EEFA), // Soft lavender tint
    border: AppColors.outlineLight,
    borderLight: AppColors.outlineVariantLight,
    primary: Color(0xFF9400D3), // Deep Violet
    primaryHover: Color(0xFF7A00B0),
    secondary: Color(0xFFEE80E9), // Orchid Pink
    accent: Color(0xFFD8D7FF), // Periwinkle
    accentBright: Color(0xFFB1AFFF),
    accentSoft: Color(0xFFF8EDFC),
    text: AppColors.onSurfaceLight,
    textMuted: AppColors.onSurfaceVariantLight,
    textLight: Color(0xFFADB5BD),
    success: Color(0xFF288C5E),
    warning: Color(0xFFC48020),
    danger: Color(0xFFC93859),
    progress: Color(0xFF9400D3),
    progressBg: Color(0xFFEADBEA),
    tag: Color(0xFFF5EEFA),
    tagText: Color(0xFF9400D3),
    divider: AppColors.outlineVariantLight,
    footerBg: AppColors.surfaceLight,
    footerActive: Color(0xFF9400D3),
    footerInactive: AppColors.onSurfaceVariantLight,
    highlight: Color(0xFFFDF7FF),
    cross: Color(0xFF9400D3),
  ),
  dark: VersoPalette(
    style: AppearanceStyle.dark,
    bg: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    surfaceAlt: Color(0xFF251E2E),
    border: AppColors.outlineDark,
    borderLight: AppColors.outlineVariantDark,
    primary: Color(0xFFD8D7FF), // Periwinkle pops beautifully on dark
    primaryHover: Color(0xFFB8B5FF),
    secondary: Color(0xFFEE80E9), // Orchid Pink
    accent: Color(0xFF9400D3), // Deep Violet
    accentBright: Color(0xFFB43FE8),
    accentSoft: Color(0xFF3A1A4A),
    text: AppColors.onSurfaceDark,
    textMuted: AppColors.onSurfaceVariantDark,
    textLight: Color(0xFF6B7280),
    success: Color(0xFF40C988),
    warning: Color(0xFFEAA84F),
    danger: Color(0xFFE65A78),
    progress: Color(0xFFD8D7FF),
    progressBg: Color(0xFF251E2E),
    tag: Color(0xFF251E2E),
    tagText: Color(0xFFD8D7FF),
    divider: AppColors.outlineVariantDark,
    footerBg: AppColors.surfaceDark,
    footerActive: Color(0xFFD8D7FF),
    footerInactive: AppColors.onSurfaceVariantDark,
    highlight: Color(0xFF1A1620),
    cross: Color(0xFFD8D7FF),
  ),
);
