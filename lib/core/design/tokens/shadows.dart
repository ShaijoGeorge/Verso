import 'package:flutter/material.dart';

/// Elevation / box shadow tokens.
abstract final class AppShadows {
  /// No shadow.
  static const List<BoxShadow> none = [];

  /// Subtle lift - cards at rest.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x060F172A),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x040F172A),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Default card elevation.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x050F172A),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Raised elements - modals, dropdowns.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x120F172A),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ];

  /// Floating action buttons, popovers.
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x180F172A),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Colored ambient glow for accent elements.
  static List<BoxShadow> glow(Color color, {double opacity = 0.28}) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: color.withValues(alpha: opacity * 0.4),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
}
