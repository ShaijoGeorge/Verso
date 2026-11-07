import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verso/core/design/profiles/verso_palette.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/typography.dart';
import 'package:verso/data/local/entities/user_settings.dart';

/// Builds a [ThemeData] from a [VersoPalette].
///
/// The palette is attached as a [ThemeExtension] so widgets can access
/// extended tokens via `context.palette`.
abstract final class AppTheme {
  static ThemeData build(VersoPalette palette) {
    final isLight = palette.style.isLight;

    // Derive on-colors from luminance so profile authors don't need to specify them.
    final onPrimary = _onColor(palette.primary);
    final onSecondary = _onColor(palette.secondary);

    final colorScheme = ColorScheme(
      brightness: isLight ? Brightness.light : Brightness.dark,
      primary: palette.primary,
      onPrimary: onPrimary,
      primaryContainer: palette.accentSoft,
      onPrimaryContainer: palette.text,
      secondary: palette.secondary,
      onSecondary: onSecondary,
      secondaryContainer: palette.tag,
      onSecondaryContainer: palette.tagText,
      surface: palette.surface,
      onSurface: palette.text,
      onSurfaceVariant: palette.textMuted,
      error: palette.danger,
      onError: _onColor(palette.danger),
      outline: palette.border,
      outlineVariant: palette.borderLight,
      surfaceContainerHighest: palette.surfaceAlt,
    );

    final textTheme = AppTypography.textTheme(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isLight ? Brightness.light : Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: palette.bg,
      extensions: [palette],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.bg,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle:
            isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.titleMedium.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
          side: BorderSide(
            color: palette.border.withValues(alpha: isLight ? 0.35 : 0.6),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xl)),
          side: BorderSide(
            color: palette.border.withValues(alpha: isLight ? 0.35 : 0.6),
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
            color: palette.border.withValues(alpha: isLight ? 0.35 : 0.6),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.borderRadiusLG,
          side: BorderSide(
            color: palette.border.withValues(alpha: isLight ? 0.6 : 0.22),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.borderRadiusMD,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(
            color: palette.border.withValues(alpha: isLight ? 0.8 : 0.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.borderRadiusMD,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.divider.withValues(alpha: isLight ? 0.7 : 0.3),
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.footerBg,
        indicatorColor:
            palette.footerActive.withValues(alpha: isLight ? 0.12 : 0.2),
        labelTextStyle: WidgetStateProperty.all(
          AppTypography.labelSmall.copyWith(color: palette.text),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: palette.footerActive);
          }
          return IconThemeData(color: palette.footerInactive);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusMD),
      ),
    );
  }

  static Color _onColor(Color bg) => bg.computeLuminance() > 0.42
      ? const Color(0xFF0F172A)
      : const Color(0xFFF8FAFC);
}
