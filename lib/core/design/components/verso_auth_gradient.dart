import 'package:flutter/material.dart';
import 'package:verso/core/design/tokens/colors.dart';

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
          ? [
              AppColors.primaryContainerDark,
              AppColors.backgroundDark,
              AppColors.backgroundDark,
            ]
          : [
              AppColors.primaryContainerLight,
              AppColors.backgroundLight,
              AppColors.backgroundLight,
            ],
      stops: const [0.0, 0.4, 1.0],
    );
  }
}
