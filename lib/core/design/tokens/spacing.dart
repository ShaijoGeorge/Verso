import 'package:flutter/material.dart';

/// 8px base grid spacing system.
///
/// ```dart
/// Padding(padding: Spacing.pagePadding)
/// SizedBox(height: Spacing.md)
/// ```
abstract final class Spacing {
  /// 4px - hairline gaps, icon-to-text
  static const double xs = 4;

  /// 8px - tight padding, compact lists
  static const double sm = 8;

  /// 16px - default content padding
  static const double md = 16;

  /// 24px - card internal padding, section gaps
  static const double lg = 24;

  /// 32px - section separators
  static const double xl = 32;

  /// 48px - major section gaps
  static const double xxl = 48;

  /// 64px - hero / top-level gaps
  static const double xxxl = 64;

  // ── Reusable EdgeInsets Presets ──

  /// Standard page padding - 24px horizontal, 24px vertical.
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: lg,
  );

  /// Card internal padding - 16px all around.
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Section gap - used as padding between major sections.
  static const EdgeInsets sectionGap = EdgeInsets.only(bottom: xl);

  // ── Common EdgeInsets ──

  static const EdgeInsets allXS = EdgeInsets.all(xs);
  static const EdgeInsets allSM = EdgeInsets.all(sm);
  static const EdgeInsets allMD = EdgeInsets.all(md);
  static const EdgeInsets allLG = EdgeInsets.all(lg);
  static const EdgeInsets allXL = EdgeInsets.all(xl);

  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
}
