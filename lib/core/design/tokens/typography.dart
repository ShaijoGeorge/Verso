import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale for Verso.
///
/// **DM Serif Display** - headlines and display text (editorial, biblical feel).
/// **Plus Jakarta Sans** - titles, body, labels (modern, highly readable).
///
/// Use [AppTypography.textTheme] to build the full [TextTheme] for [ThemeData].
/// For one-off styles, reference the static fields directly.
abstract final class AppTypography {
  // ── Display (DM Serif Display) ──

  static TextStyle get displayLarge => GoogleFonts.dmSerifDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.dmSerifDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.25,
      );

  static TextStyle get displaySmall => GoogleFonts.dmSerifDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.3,
      );

  // ── Headline (DM Serif Display) ──

  static TextStyle get headlineLarge => GoogleFonts.dmSerifDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        height: 1.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.dmSerifDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        height: 1.35,
      );

  static TextStyle get headlineSmall => GoogleFonts.dmSerifDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  // ── Title (Plus Jakarta Sans) ──

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.3,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  // ── Body (Plus Jakarta Sans) ──

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.5,
      );

  // ── Label (Plus Jakarta Sans) ──

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
      );

  /// Builds the complete [TextTheme] for use in [ThemeData].
  static TextTheme textTheme({
    required Color bodyColor,
    required Color displayColor,
  }) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: displayColor),
      displayMedium: displayMedium.copyWith(color: displayColor),
      displaySmall: displaySmall.copyWith(color: displayColor),
      headlineLarge: headlineLarge.copyWith(color: displayColor),
      headlineMedium: headlineMedium.copyWith(color: displayColor),
      headlineSmall: headlineSmall.copyWith(color: displayColor),
      titleLarge: titleLarge.copyWith(color: bodyColor),
      titleMedium: titleMedium.copyWith(color: bodyColor),
      titleSmall: titleSmall.copyWith(color: bodyColor),
      bodyLarge: bodyLarge.copyWith(color: bodyColor),
      bodyMedium: bodyMedium.copyWith(color: bodyColor),
      bodySmall: bodySmall.copyWith(color: bodyColor),
      labelLarge: labelLarge.copyWith(color: bodyColor),
      labelMedium: labelMedium.copyWith(color: bodyColor),
      labelSmall: labelSmall.copyWith(color: bodyColor),
    );
  }
}
