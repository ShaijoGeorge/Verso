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
        fontSize: 38,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.6,
        height: 1.15,
      );

  static TextStyle get displayMedium => GoogleFonts.dmSerifDisplay(
        fontSize: 30,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.4,
        height: 1.2,
      );

  static TextStyle get displaySmall => GoogleFonts.dmSerifDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        height: 1.25,
      );

  // ── Headline (DM Serif Display) ──

  static TextStyle get headlineLarge => GoogleFonts.dmSerifDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.3,
        height: 1.22,
      );

  static TextStyle get headlineMedium => GoogleFonts.dmSerifDisplay(
        fontSize: 21,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get headlineSmall => GoogleFonts.dmSerifDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.38,
      );

  // ── Title (Plus Jakarta Sans) ──

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.28,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.35,
      );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        height: 1.4,
      );

  // ── Body (Plus Jakarta Sans) ──

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.55,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.45,
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
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        height: 1.35,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.35,
        height: 1.35,
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
      headlineLarge: headlineLarge.copyWith(color: bodyColor),
      headlineMedium: headlineMedium.copyWith(color: bodyColor),
      headlineSmall: headlineSmall.copyWith(color: bodyColor),
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
