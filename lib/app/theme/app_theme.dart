import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern, professional theme configuration for Koala Financial App
/// Following modern financial app design patterns (inspired by Revolut, Monzo, etc.)
class AppTheme {
  // Brand Colors - Modern Financial App Palette (No gradients, flat design)
  static const Color _primaryColor = Color(0xFF1A73E8); // Google-style blue
  static const Color _primaryVariant = Color(0xFF1557B0);
  static const Color _secondaryColor = Color(0xFF34A853); // Success green
  static const Color _secondaryVariant = Color(0xFF2D8F46);

  // Surface Colors - Clean, modern surfaces
  static const Color _surfaceLight = Color(0xFFFBFBFB);
  static const Color _surfaceDark = Color(0xFF121212);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _cardDark = Color(0xFF1E1E1E);

  // Text Colors - High contrast for readability
  static const Color _textPrimaryLight = Color(0xFF202124);
  static const Color _textSecondaryLight = Color(0xFF5F6368);
  static const Color _textPrimaryDark = Color(0xFFF8F9FA);
  static const Color _textSecondaryDark = Color(0xFFE8EAED);

  // Accent Colors - Modern financial app palette
  static const Color _successColor = Color(0xFF34A853);
  static const Color _warningColor = Color(0xFFFBBC04);
  static const Color _errorColor = Color(0xFFEA4335);

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme - Clean, accessible colors
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        primaryContainer: Color(0xFFE8F0FE),
        secondary: _secondaryColor,
        secondaryContainer: Color(0xFFE6F4EA),
        surface: _surfaceLight,
        surfaceVariant: Color(0xFFF8F9FA),
        background: _surfaceLight,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimaryLight,
        onSurfaceVariant: _textSecondaryLight,
        onBackground: _textPrimaryLight,
        onError: Colors.white,
        outline: Color(0xFFDADCE0),
        shadow: Color(0x0A000000),
      ),

      // Typography
      textTheme: _buildTextTheme(Brightness.light),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: _surfaceLight,
        foregroundColor: _textPrimaryLight,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Card Theme - Modern card design with subtle borders
      cardTheme: CardThemeData(
        elevation: 0,
        color: _cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE8EAED), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),

      // Elevated Button Theme - Modern button design
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Outlined Button Theme - Consistent with elevated buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: _primaryColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input Decoration Theme - Clean, modern inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDADCE0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDADCE0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Divider Theme - Subtle dividers
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8EAED),
        thickness: 0.5,
        space: 0.5,
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme - Modern dark theme
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        primaryContainer: Color(0xFF1A73E8),
        secondary: _secondaryColor,
        secondaryContainer: Color(0xFF2D5016),
        surface: _surfaceDark,
        surfaceVariant: Color(0xFF2C2C2C),
        background: _surfaceDark,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimaryDark,
        onSurfaceVariant: _textSecondaryDark,
        onBackground: _textPrimaryDark,
        onError: Colors.white,
        outline: Color(0xFF5F6368),
        shadow: Color(0x4D000000),
      ),

      // Typography
      textTheme: _buildTextTheme(Brightness.dark),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: _surfaceDark,
        foregroundColor: _textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // Card Theme - Dark mode cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: _cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF5F6368), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),

      // Elevated Button Theme - Dark mode buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Outlined Button Theme - Dark mode outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: _primaryColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input Decoration Theme - Dark mode inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5F6368)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5F6368)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Divider Theme - Dark mode dividers
      dividerTheme: const DividerThemeData(
        color: Color(0xFF5F6368),
        thickness: 0.5,
        space: 0.5,
      ),
    );
  }

  /// Alias for light theme (for compatibility)
  static ThemeData get light => lightTheme;

  /// Alias for dark theme (for compatibility)
  static ThemeData get dark => darkTheme;

  /// Build text theme for the given brightness
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color primaryTextColor = brightness == Brightness.light
        ? _textPrimaryLight
        : _textPrimaryDark;
    final Color secondaryTextColor = brightness == Brightness.light
        ? _textSecondaryLight
        : _textSecondaryDark;

    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.25,
        color: primaryTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: primaryTextColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: primaryTextColor,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: primaryTextColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: secondaryTextColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: secondaryTextColor,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: primaryTextColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondaryTextColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondaryTextColor,
      ),
    );
  }

  // Status Colors
  static const Color successColor = _successColor;
  static const Color warningColor = _warningColor;
  static const Color errorColor = _errorColor;
}
