import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF2196F3);
  static const primaryColorDark = Color(0xFF1976D2);
  static const secondaryColor = Color(0xFF03DAC6);
  static const errorColor = Color(0xFFB00020);
  static const surfaceColor = Color(0xFFFFFFFF);
  static const backgroundColor = Color(0xFFF5F5F5);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surfaceColor,
        elevation: 1,
        selectedIconTheme: const IconThemeData(
          color: primaryColor,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Colors.grey,
          size: 24,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 1,
        selectedIconTheme: const IconThemeData(
          color: primaryColor,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}