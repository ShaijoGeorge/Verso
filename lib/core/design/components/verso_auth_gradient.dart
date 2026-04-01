import 'package:flutter/material.dart';
import '../tokens/colors.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF0F2640), AppColors.backgroundDark, const Color(0xFF0D0D0F)]
          : [const Color(0xFFD6E8F5), AppColors.backgroundLight, const Color(0xFFF0F2F5)],
      stops: const [0.0, 0.4, 1.0],
    );
  }
}