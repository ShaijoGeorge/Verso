import 'package:flutter/material.dart';

/// Elevation / box shadow tokens.
abstract final class AppShadows {
  /// No shadow.
  static const List<BoxShadow> none = [];

  /// Subtle lift - cards at rest.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x08000000), // ~3% black
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Default card elevation.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0D000000), // ~5% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Raised elements - modals, dropdowns.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x14000000), // ~8% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Floating action buttons, popovers.
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A000000), // ~10% black
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
