import 'package:flutter/material.dart';
import 'package:verso/core/design/profiles/current_profile.dart';
import 'package:verso/core/design/profiles/verso_palette.dart';
import 'package:verso/core/design/tokens/colors.dart';

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
  VersoPalette get palette =>
      theme.extension<VersoPalette>() ?? currentProfile.light;
}

/// Semantic colors that aren't part of [ColorScheme] (success, charts, streaks).
///
/// Access via `context.appColors.success`.
extension AppColorsX on BuildContext {
  AppSemanticColors get appColors => AppSemanticColors(isDark);
}

class AppSemanticColors {
  const AppSemanticColors(this._isDark);
  final bool _isDark;

  Color get success => _isDark ? AppColors.successDark : AppColors.successLight;
  Color get streak => _isDark ? AppColors.streakDark : AppColors.streakLight;
  Color get chapters =>
      _isDark ? AppColors.chaptersDark : AppColors.chaptersLight;
  Color get books => _isDark ? AppColors.booksDark : AppColors.booksLight;
  Color get chartPurple =>
      _isDark ? AppColors.chartPurpleDark : AppColors.chartPurpleLight;
  Color get chartTeal =>
      _isDark ? AppColors.chartTealDark : AppColors.chartTealLight;
  Color get otColor => _isDark ? AppColors.otColorDark : AppColors.otColorLight;
  Color get ntColor => _isDark ? AppColors.ntColorDark : AppColors.ntColorLight;
  Color get otContainer =>
      _isDark ? AppColors.otContainerDark : AppColors.otContainerLight;
  Color get ntContainer =>
      _isDark ? AppColors.ntContainerDark : AppColors.ntContainerLight;
  Color get completionEmpty =>
      _isDark ? AppColors.completionEmptyDark : AppColors.completionEmptyLight;
  Color get primaryAccent =>
      _isDark ? AppColors.primaryAccentDark : AppColors.primaryAccentLight;
  Color get primaryHighlight => _isDark
      ? AppColors.primaryHighlightDark
      : AppColors.primaryHighlightLight;
  Color get secondaryOnContainer =>
      _isDark ? AppColors.secondaryDark : AppColors.secondaryOnContainerLight;
}
