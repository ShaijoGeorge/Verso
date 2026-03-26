import 'package:flutter/material.dart';

/// Border radius tokens.
abstract final class AppRadii {
  /// 4px - tags, tiny chips
  static const double xs = 4;

  /// 8px - buttons, inputs
  static const double sm = 8;

  /// 12px - small cards
  static const double md = 12;

  /// 16px - cards, dialogs
  static const double lg = 16;

  /// 20px - pills, bottom sheets
  static const double xl = 20;

  /// 9999px - fully round (circles, capsules)
  static const double full = 9999;

  // ── Common BorderRadius ──

  static final BorderRadius borderRadiusXS = BorderRadius.circular(xs);
  static final BorderRadius borderRadiusSM = BorderRadius.circular(sm);
  static final BorderRadius borderRadiusMD = BorderRadius.circular(md);
  static final BorderRadius borderRadiusLG = BorderRadius.circular(lg);
  static final BorderRadius borderRadiusXL = BorderRadius.circular(xl);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(full);
}
