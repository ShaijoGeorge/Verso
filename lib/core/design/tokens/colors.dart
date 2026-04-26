import 'package:flutter/material.dart';

/// "Sacred Blue" semantic color palette for Verso.
///
/// Never use raw hex values in widgets - always reference these tokens
/// or pull from [Theme.of(context).colorScheme].
abstract final class AppColors {
  // ──────────────── Primary ────────────────
  static const Color primaryLight = Color(0xFF1B3A5C); // Deep Navy
  static const Color primaryDark = Color(0xFF7EB8E0); // Soft Sky

  static const Color primaryContainerLight = Color(0xFFD6E8F5); // Pale Blue
  static const Color primaryContainerDark = Color(0xFF0F2640); // Dark Navy

  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF0F2640);

  static const Color onPrimaryContainerLight = Color(0xFF1B3A5C);
  static const Color onPrimaryContainerDark = Color(0xFFD6E8F5);

  // ──────────────── Secondary ────────────────
  static const Color secondaryLight = Color(0xFFC4973B); // Warm Gold
  static const Color secondaryDark = Color(0xFFA8864A); // Muted Gold

  static const Color secondaryContainerLight = Color(0xFFFFF3DC);
  static const Color secondaryContainerDark = Color(0xFF3D2E14);

  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryDark = Color(0xFF3D2E14);

  // ──────────────── Surface / Background ────────────────
  static const Color surfaceLight = Color(0xFFFAFBFC); // Off-White
  static const Color surfaceDark = Color(0xFF1A1A1E); // Charcoal

  static const Color backgroundLight = Color(0xFFF0F2F5); // Light Grey
  static const Color backgroundDark = Color(0xFF0D0D0F); // True Black

  // ──────────────── On Surface ────────────────
  static const Color onSurfaceLight = Color(0xFF1C1C1E); // Near Black
  static const Color onSurfaceDark = Color(0xFFF5F5F5); // White

  static const Color onSurfaceVariantLight = Color(0xFF6B7280); // Grey
  static const Color onSurfaceVariantDark = Color(0xFF9CA3AF); // Grey

  // ──────────────── Status ────────────────
  static const Color successLight = Color(0xFF2E7D4F); // Forest Green
  static const Color successDark = Color(0xFF4CAF7D); // Mint

  static const Color errorLight = Color(0xFFC62828); // Crimson
  static const Color errorDark = Color(0xFFEF5350); // Salmon

  // ──────────────── Accent / Chart Colors ────────────────
  static const Color streakLight =
      Color(0xFFC4973B); // Warm Gold (same as secondary)
  static const Color streakDark = Color(0xFFA8864A);

  static const Color chartPurpleLight = Color(0xFF7C3AED);
  static const Color chartPurpleDark = Color(0xFFA78BFA);

  static const Color chartTealLight = Color(0xFF0D9488);
  static const Color chartTealDark = Color(0xFF5EEAD4);

  static const Color otColorLight = Color(0xFFE65100); // Orange for OT
  static const Color otColorDark = Color(0xFFFF9800);

  static const Color ntColorLight = Color(0xFF1565C0); // Blue for NT
  static const Color ntColorDark = Color(0xFF64B5F6);

  // ──────────────── Outline / Divider ────────────────
  static const Color outlineLight = Color(0xFFD4D4D4);
  static const Color outlineDark = Color(0xFF2E2E32);

  static const Color outlineVariantLight = Color(0xFFE8E8E8);
  static const Color outlineVariantDark = Color(0xFF1F1F23);

  // ──────────────── AMOLED overrides (true black) ────────────────
  static const Color backgroundAmoled = Color(0xFF000000);
  static const Color surfaceAmoled = Color(0xFF000000);
  static const Color outlineAmoled = Color(0xFF1A1A1A);
  static const Color outlineVariantAmoled = Color(0xFF0F0F0F);
}
