import 'package:flutter/material.dart';
import 'package:verso/core/design/extensions.dart';

/// The shared gradient background used on all auth screens.
///
/// ```dart
/// Container(
///   decoration: BoxDecoration(gradient: VersoAuthGradient.of(context)),
///   child: ...
/// )
/// ```
abstract final class VersoAuthGradient {
  static LinearGradient of(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        palette.accentSoft.withValues(alpha: isDark ? 0.85 : 1.0),
        palette.bg,
        palette.surfaceAlt.withValues(alpha: isDark ? 0.35 : 0.5),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
  }
}
