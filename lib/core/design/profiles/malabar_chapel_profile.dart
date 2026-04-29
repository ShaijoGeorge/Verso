import 'package:flutter/material.dart';
import 'package:verso/core/design/profiles/theme_profile.dart';
import 'package:verso/core/design/profiles/verso_palette.dart';
import 'package:verso/core/design/tokens/colors.dart';
import 'package:verso/data/local/entities/user_settings.dart';

/// "Malabar Chapel" — Marian Blue × Kerala Terracotta × Ivory.
///
/// Inspired by white-washed Kerala Latin Catholic churches — Our Lady's blue
/// as the primary, terracotta from church tile roofs, ivory candlelight.
const ThemeProfile malabarChapelProfile = ThemeProfile(
  id: 'malabar_chapel',
  name: 'Malabar Chapel',
  tagline: 'Marian Blue × Kerala Terracotta × Ivory',
  description:
      "Inspired by white-washed Kerala Latin Catholic churches — Our Lady's blue as the primary, terracotta from church tile roofs, ivory candlelight. Friendly for children (10+), dignified for elders. The most universally accessible palette.",
  inspiration:
      "Latin Catholic churches of Thrissur, Our Lady's blue robes, Kerala terracotta roof tiles, St. Thomas traditions",
  light: VersoPalette(
    style: AppearanceStyle.light,
    bg: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    surfaceAlt: Color(0xFFEEF2FA),
    border: AppColors.outlineLight,
    borderLight: AppColors.outlineVariantLight,
    primary: Color(0xFF1B4D8E),
    primaryHover: Color(0xFF143A6E),
    secondary: Color(0xFF2E6AB5),
    accent: Color(0xFFC4501A),
    accentBright: Color(0xFFD96020),
    accentSoft: Color(0xFFFDEEE6),
    text: AppColors.onSurfaceLight,
    textMuted: AppColors.onSurfaceVariantLight,
    textLight: Color(0xFFADB5BD),
    success: Color(0xFF1E7A4A),
    warning: Color(0xFFB86A10),
    danger: Color(0xFFB82020),
    progress: Color(0xFF1B4D8E),
    progressBg: Color(0xFFD8E4F4),
    tag: Color(0xFFE8F0FA),
    tagText: Color(0xFF1B4D8E),
    streakBg: Color(0xFFFDEEE6),
    streakText: Color(0xFFC4501A),
    divider: AppColors.outlineVariantLight,
    footerBg: AppColors.surfaceLight,
    footerActive: Color(0xFF1B4D8E),
    footerInactive: AppColors.onSurfaceVariantLight,
    highlight: Color(0xFFF0F5FF),
    cross: Color(0xFF1B4D8E),
  ),
  dark: VersoPalette(
    style: AppearanceStyle.dark,
    bg: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    surfaceAlt: Color(0xFF152038),
    border: AppColors.outlineDark,
    borderLight: AppColors.outlineVariantDark,
    primary: Color(0xFF4A90E8),
    primaryHover: Color(0xFF68A8F8),
    secondary: Color(0xFF3070C0),
    accent: Color(0xFFE87040),
    accentBright: Color(0xFFF08050),
    accentSoft: Color(0xFF281408),
    text: AppColors.onSurfaceDark,
    textMuted: AppColors.onSurfaceVariantDark,
    textLight: Color(0xFF6B7280),
    success: Color(0xFF38B870),
    warning: Color(0xFFE09030),
    danger: Color(0xFFE05050),
    progress: Color(0xFF4A90E8),
    progressBg: Color(0xFF122040),
    tag: Color(0xFF102038),
    tagText: Color(0xFF4A90E8),
    streakBg: Color(0xFF201008),
    streakText: Color(0xFFF08050),
    divider: AppColors.outlineVariantDark,
    footerBg: AppColors.surfaceDark,
    footerActive: Color(0xFF4A90E8),
    footerInactive: AppColors.onSurfaceVariantDark,
    highlight: Color(0xFF0E1A30),
    cross: Color(0xFF4A90E8),
  ),
);
