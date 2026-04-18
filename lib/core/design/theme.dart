import 'package:flutter/material.dart';
import 'package:verso/core/design/tokens/colors.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/typography.dart';

/// Builds light and dark [ThemeData] from design tokens.
abstract final class AppTheme {
  static final ThemeData lightTheme = _build(Brightness.light);
  static final ThemeData darkTheme = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isLight ? AppColors.primaryLight : AppColors.primaryDark,
      onPrimary: isLight ? AppColors.onPrimaryLight : AppColors.onPrimaryDark,
      primaryContainer: isLight
          ? AppColors.primaryContainerLight
          : AppColors.primaryContainerDark,
      onPrimaryContainer: isLight
          ? AppColors.onPrimaryContainerLight
          : AppColors.onPrimaryContainerDark,
      secondary: isLight ? AppColors.secondaryLight : AppColors.secondaryDark,
      onSecondary:
          isLight ? AppColors.onSecondaryLight : AppColors.onSecondaryDark,
      secondaryContainer: isLight
          ? AppColors.secondaryContainerLight
          : AppColors.secondaryContainerDark,
      onSecondaryContainer: isLight
          ? AppColors.onPrimaryContainerLight
          : AppColors.onPrimaryContainerDark,
      surface: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      onSurface: isLight ? AppColors.onSurfaceLight : AppColors.onSurfaceDark,
      onSurfaceVariant: isLight
          ? AppColors.onSurfaceVariantLight
          : AppColors.onSurfaceVariantDark,
      error: isLight ? AppColors.errorLight : AppColors.errorDark,
      onError: Colors.white,
      outline: isLight ? AppColors.outlineLight : AppColors.outlineDark,
      outlineVariant: isLight
          ? AppColors.outlineVariantLight
          : AppColors.outlineVariantDark,
      surfaceContainerHighest:
          isLight ? AppColors.primaryContainerLight : AppColors.surfaceDark,
    );

    final textTheme = AppTypography.textTheme(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: AppTypography.titleMedium.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.borderRadiusLG,
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: isLight ? 0.5 : 0.15),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        indicatorColor:
            colorScheme.primary.withValues(alpha: isLight ? 0.15 : 0.2),
        labelTextStyle: WidgetStateProperty.all(
          AppTypography.labelSmall.copyWith(color: colorScheme.onSurface),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusSM),
      ),
    );
  }
}
