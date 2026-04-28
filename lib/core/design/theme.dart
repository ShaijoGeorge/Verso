import 'package:flutter/material.dart';
import 'package:verso/core/design/tokens/colors.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/typography.dart';

/// Builds light, dark, and AMOLED [ThemeData] from design tokens.
abstract final class AppTheme {
  static final ThemeData lightTheme = _build(Brightness.light);
  static final ThemeData darkTheme = _build(Brightness.dark);
  static final ThemeData amoledTheme = _build(Brightness.dark, amoled: true);

  static ThemeData _build(Brightness brightness, {bool amoled = false}) {
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
      surface: isLight
          ? AppColors.surfaceLight
          : (amoled ? AppColors.surfaceAmoled : AppColors.surfaceDark),
      onSurface: isLight ? AppColors.onSurfaceLight : AppColors.onSurfaceDark,
      onSurfaceVariant: isLight
          ? AppColors.onSurfaceVariantLight
          : AppColors.onSurfaceVariantDark,
      error: isLight ? AppColors.errorLight : AppColors.errorDark,
      onError: Colors.white,
      outline: isLight
          ? AppColors.outlineLight
          : (amoled ? AppColors.outlineAmoled : AppColors.outlineDark),
      outlineVariant: isLight
          ? AppColors.outlineVariantLight
          : (amoled
              ? AppColors.outlineVariantAmoled
              : AppColors.outlineVariantDark),
      surfaceContainerHighest:
          isLight ? AppColors.primaryContainerLight : AppColors.surfaceDark,
    );

    final textTheme = AppTypography.textTheme(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.primary,
    );

    final bgColor = isLight
        ? AppColors.backgroundLight
        : (amoled ? AppColors.backgroundAmoled : AppColors.backgroundDark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: AppTypography.titleMedium.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: isLight ? 0.2 : 0.5),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xl)),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: isLight ? 0.2 : 0.5),
          ),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xl)),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: isLight ? 0.2 : 0.5),
          ),
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
        backgroundColor: isLight
            ? AppColors.surfaceLight
            : (amoled ? AppColors.surfaceAmoled : AppColors.surfaceDark),
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
