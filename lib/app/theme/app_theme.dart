import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern, professional theme configuration for Koala Financial App
class AppTheme {
  // Brand Colors - Modern Financial App Palette
  static const Color _primaryColor = Color(0xFF0066FF); // Modern blue
  static const Color _primaryVariant = Color(0xFF0052CC);
  static const Color _secondaryColor = Color(0xFF00D4AA); // Mint green
  static const Color _secondaryVariant = Color(0xFF00B894);

  // Surface Colors
  static const Color _surfaceLight = Color(0xFFFBFCFE);
  static const Color _surfaceDark = Color(0xFF0A0E13);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _cardDark = Color(0xFF151922);

  // Text Colors
  static const Color _textPrimaryLight = Color(0xFF1A1D29);
  static const Color _textSecondaryLight = Color(0xFF6B7280);
  static const Color _textPrimaryDark = Color(0xFFF9FAFB);
  static const Color _textSecondaryDark = Color(0xFFD1D5DB);

  // Accent Colors
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _errorColor = Color(0xFFEF4444);

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        primaryContainer: Color(0xFFE3F2FD),
        secondary: _secondaryColor,
        secondaryContainer: Color(0xFFE0F7F4),
        surface: _surfaceLight,
        surfaceVariant: Color(0xFFF8FAFC),
        background: _surfaceLight,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimaryLight,
        onSurfaceVariant: _textSecondaryLight,
        onBackground: _textPrimaryLight,
        onError: Colors.white,
        outline: Color(0xFFE5E7EB),
        shadow: Color(0x1A000000),
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

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: _cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: _primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        primaryContainer: Color(0xFF1E3A8A),
        secondary: _secondaryColor,
        secondaryContainer: Color(0xFF065F46),
        surface: _surfaceDark,
        surfaceVariant: Color(0xFF1F2937),
        background: _surfaceDark,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimaryDark,
        onSurfaceVariant: _textSecondaryDark,
        onBackground: _textPrimaryDark,
        onError: Colors.white,
        outline: Color(0xFF374151),
        shadow: Color(0x3D000000),
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

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: _cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF374151), width: 1),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: _primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF374151),
        thickness: 1,
        space: 1,
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
