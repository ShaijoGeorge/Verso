import 'package:flutter/material.dart';

/// Border radius tokens.
abstract final class AppRadii {
  /// 6px - tags, tiny chips
  static const double xs = 6;

  /// 10px - buttons, inputs
  static const double sm = 10;

  /// 14px - small cards, tiles
  static const double md = 14;

  /// 20px - standard cards, bento containers
  static const double lg = 20;

  /// 24px - hero cards, pills, bottom sheets
  static const double xl = 24;

  /// 32px - ultra-rounded docks, feature sheets
  static const double xxl = 32;

  /// 9999px - fully round (circles, capsules)
  static const double full = 9999;

  // ── Common BorderRadius ──

  static final BorderRadius borderRadiusXS = BorderRadius.circular(xs);
  static final BorderRadius borderRadiusSM = BorderRadius.circular(sm);
  static final BorderRadius borderRadiusMD = BorderRadius.circular(md);
  static final BorderRadius borderRadiusLG = BorderRadius.circular(lg);
  static final BorderRadius borderRadiusXL = BorderRadius.circular(xl);
  static final BorderRadius borderRadiusXXL = BorderRadius.circular(xxl);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(full);
}
