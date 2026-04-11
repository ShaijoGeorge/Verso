import 'package:flutter/material.dart';
import 'tokens/colors.dart';

/// Convenience extensions on [BuildContext] for quick access to theme tokens.
///
/// ```dart
/// context.colors.primary
/// context.textTheme.bodyMedium
/// context.isDark
/// context.appColors.success
/// ```
extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDark => theme.brightness == Brightness.dark;
}

/// Semantic colors that aren't part of [ColorScheme] (success, charts, streaks).
///
/// Access via `context.appColors.success`.
extension AppColorsX on BuildContext {
  AppSemanticColors get appColors => AppSemanticColors(isDark);
}

class AppSemanticColors {
  final bool _isDark;
  const AppSemanticColors(this._isDark);

  Color get success => _isDark ? AppColors.successDark : AppColors.successLight;
  Color get streak => _isDark ? AppColors.streakDark : AppColors.streakLight;
  Color get chartPurple =>
      _isDark ? AppColors.chartPurpleDark : AppColors.chartPurpleLight;
  Color get chartTeal =>
      _isDark ? AppColors.chartTealDark : AppColors.chartTealLight;
  Color get otColor => _isDark ? AppColors.otColorDark : AppColors.otColorLight;
  Color get ntColor => _isDark ? AppColors.ntColorDark : AppColors.ntColorLight;
}
