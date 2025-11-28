import 'package:flutter/material.dart';

class _AppColors {
  // --- Light Palette ---
  static const Color greyDark = Color(0xFFD4D4D4);
  static const Color greyLight = Color(0xFFF1F1F1); // Light Background
  static const Color bluePale = Color(0xFFC5E3EC);
  static const Color blueLight = Color(0xFFAADDEC);
  static const Color blueDeep = Color(0xFF395886);   // Light Mode Primary

  // --- Dark Palette (Derived for Dark Mode) ---
  static const Color darkBackground = Color(0xFF121212); // Deep Black
  static const Color darkSurface = Color(0xFF1E1E1E);    // Dark Cards
  static const Color blueAccent = Color(0xFF90D5EC);     // Lighter Blue for Dark Mode contrast
}

class AppTheme {

  // LIGHT THEME (Your Blue/Grey Palette)

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Metropolis',
    
    colorScheme: const ColorScheme.light(
      primary: _AppColors.blueDeep,
      onPrimary: Colors.white,
      secondary: _AppColors.blueLight,
      onSecondary: _AppColors.blueDeep,
      surface: Colors.white,
      onSurface: _AppColors.blueDeep,
      surfaceContainerHighest: _AppColors.bluePale, // Progress bar backgrounds
    ),
    
    scaffoldBackgroundColor: _AppColors.greyLight,
    
    textTheme: const TextTheme().apply(
      bodyColor: Colors.black87,
      displayColor: _AppColors.blueDeep,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: _AppColors.greyLight,
      foregroundColor: _AppColors.blueDeep,
      centerTitle: true,
      elevation: 0,
    ),
    
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _AppColors.greyDark.withValues(alpha: 0.5)),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: _AppColors.blueLight.withValues(alpha: 0.5),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _AppColors.blueDeep);
        }
        return IconThemeData(color: _AppColors.blueDeep.withValues(alpha: 0.5));
      }),
    ),
  );

  // DARK THEME (High Contrast Dark Mode

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Metropolis',
    
    colorScheme: const ColorScheme.dark(
      primary: _AppColors.blueAccent,    // Lighter blue stands out on black
      onPrimary: _AppColors.darkBackground,
      secondary: _AppColors.blueLight,
      onSecondary: _AppColors.darkBackground,
      surface: _AppColors.darkSurface,
      onSurface: Colors.white,
      surfaceContainerHighest: _AppColors.darkSurface,
    ),
    
    scaffoldBackgroundColor: _AppColors.darkBackground,
    
    textTheme: const TextTheme().apply(
      bodyColor: Colors.grey[200],
      displayColor: Colors.white,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: _AppColors.darkBackground,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    
    cardTheme: CardThemeData(
      color: _AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _AppColors.darkSurface,
      indicatorColor: _AppColors.blueAccent.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _AppColors.blueAccent);
        }
        return IconThemeData(color: Colors.grey);
      }),
    ),
  );
}