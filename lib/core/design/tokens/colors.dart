import 'package:flutter/material.dart';

/// "Sacred Blue" semantic color palette for Verso.
///
/// Every color used across the app must reference these semantic tokens rather
/// than raw hex values, enabling clean dark mode and future theming support.
abstract final class AppColors {
  // ──────────────── Primary ────────────────
  static const Color primaryLight = Color(0xFF173254); // Deep Navy
  static const Color primaryDark = Color(0xFF7CB8F7); // Soft Sky

  static const Color primaryContainerLight = Color(0xFFE6F0FA); // Pale Blue
  static const Color primaryContainerDark = Color(0xFF132642); // Dark Navy

  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF0A192F);

  static const Color onPrimaryContainerLight = Color(0xFF173254);
  static const Color onPrimaryContainerDark = Color(0xFFDCEBFA);

  // ──────────────── Secondary ────────────────
  static const Color secondaryLight = Color(0xFFC59434); // Warm Gold
  static const Color secondaryDark = Color(0xFFE2B45A); // Muted Gold

  static const Color secondaryContainerLight = Color(0xFFFEF6E4);
  static const Color secondaryContainerDark = Color(0xFF332610);

  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryDark = Color(0xFF2B1F0A);

  // ──────────────── Surface / Background ────────────────
  static const Color surfaceLight = Color(0xFFFFFFFF); // Off-White
  static const Color surfaceDark = Color(0xFF131722); // Charcoal

  static const Color backgroundLight = Color(0xFFF6F8FB); // Light Grey
  static const Color backgroundDark = Color(0xFF0A0D14); // True Black

  // ──────────────── On Surface ────────────────
  static const Color onSurfaceLight = Color(0xFF0F172A); // Near Black
  static const Color onSurfaceDark = Color(0xFFF8FAFC); // White

  static const Color onSurfaceVariantLight = Color(0xFF64748B); // Grey
  static const Color onSurfaceVariantDark = Color(0xFF94A3B8); // Grey

  // ──────────────── Status ────────────────
  static const Color successLight = Color(0xFF0D9488); // Forest Green
  static const Color successDark = Color(0xFF2DD4BF); // Mint

  static const Color errorLight = Color(0xFFE11D48); // Crimson
  static const Color errorDark = Color(0xFFFB7185); // Salmon

  // ──────────────── Accent / Chart Colors ────────────────
  static const Color streakLight = Color(0xFFF97316); // Vibrant Orange
  static const Color streakDark = Color(0xFFFB923C); // Bright Orange
  static const Color chaptersLight = Color(0xFF0D9488); // Teal
  static const Color chaptersDark = Color(0xFF2DD4BF);
  static const Color booksLight = Color(0xFFD97706); // Yellow/Gold
  static const Color booksDark = Color(0xFFFBBF24);

  static const Color chartPurpleLight = Color(0xFF6D28D9);
  static const Color chartPurpleDark = Color(0xFFA78BFA);
  static const Color chartPurpleContainerDark = Color(0xFF251652);
  static const Color chartPurpleDeepDark = Color(0xFF3F2485);

  static const Color chartTealLight = Color(0xFF0D9488);
  static const Color chartTealDark = Color(0xFF5EEAD4);

  static const Color otColorLight = Color(0xFFD95D14); // Orange for OT
  static const Color otColorDark = Color(0xFFFB923C);
  static const Color otContainerLight = Color(0xFFFFEDD5);
  static const Color otContainerDark = Color(0xFF38200A);

  static const Color ntColorLight = Color(0xFF2563EB); // Blue for NT
  static const Color ntColorDark = Color(0xFF60A5FA);
  static const Color ntContainerLight = Color(0xFFDBEAFE);
  static const Color ntContainerDark = Color(0xFF102447);
  static const Color completionEmptyLight = Color(0xFFE8ECF2);
  static const Color completionEmptyDark = Color(0xFF1E2433);

  static const Color primaryAccentLight = Color(0xFF234B7A);
  static const Color primaryAccentDark = Color(0xFF5698E0);
  static const Color primaryHighlightLight = Color(0xFF3674B8);
  static const Color primaryHighlightDark = Color(0xFF63A4EB);
  static const Color secondaryAccentDark = Color(0xFF5C4520);
  static const Color secondaryOnContainerLight = Color(0xFF78350F);

  // ──────────────── Outline / Divider ────────────────
  static const Color outlineLight = Color(0xFFDFE4EE);
  static const Color outlineDark = Color(0xFF242C3D);

  static const Color outlineVariantLight = Color(0xFFEEF1F6);
  static const Color outlineVariantDark = Color(0xFF1A202E);

  // ──────────────── AMOLED overrides (true black) ────────────────
  static const Color backgroundAmoled = Color(0xFF000000);
  static const Color surfaceAmoled = Color(0xFF0B0D12);
  static const Color outlineAmoled = Color(0xFF2A303C);
  static const Color outlineVariantAmoled = Color(0xFF161A22);
}
