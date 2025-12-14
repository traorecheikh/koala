import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const Color primaryTextLight = Color(0xFF1A1B1E);
    final textThemeLight = GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    ).apply(bodyColor: primaryTextLight, displayColor: primaryTextLight);

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF3E69FE), // Vibrant Blue
      scaffoldBackgroundColor: const Color(0xFFF2F2F7), // iOS light background
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF3E69FE), // Vibrant Blue
        secondary: Color(0xFF30D5C8), // Teal for variety
        surface: Colors.white, // Pure white for cards
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1C1C1E), // Dark grey for text on white surfaces
        error: Colors.redAccent,
      ),
      textTheme: textThemeLight.copyWith(
        headlineSmall: textThemeLight.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1C1C1E),
        ),
        headlineMedium: textThemeLight.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1C1C1E),
          fontSize: 48,
        ),
        titleLarge: textThemeLight.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1C1C1E),
        ),
        titleMedium: textThemeLight.titleMedium?.copyWith(
          color: const Color(0xFF1C1C1E),
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: textThemeLight.bodyMedium?.copyWith(
          color: const Color(0xFF6A6A6A),
          fontSize: 16,
        ),
        bodySmall: textThemeLight.bodySmall?.copyWith(
          color: const Color(0xFF6A6A6A),
          fontSize: 12,
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1C1C1E), size: 24),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF3E69FE), // Match primary color
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    const Color primaryTextDark = Color(0xFFEAEAEA);
    const Color secondaryTextDark = Color(0xFFB0B0B0);
    final textThemeDark = GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: primaryTextDark, displayColor: primaryTextDark);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF3E69FE), // Vibrant Blue
      scaffoldBackgroundColor: const Color(0xFF1A1B1E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3E69FE), // Vibrant Blue
        secondary: Color(0xFF30D5C8), // Teal for variety
        surface: Color(0xFF242529), // Lighter Dark
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        error: Colors.redAccent,
      ),
      textTheme: textThemeDark.copyWith(
        headlineSmall: textThemeDark.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: primaryTextDark,
        ),
        headlineMedium: textThemeDark.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: primaryTextDark,
          fontSize: 48,
        ),
        titleLarge: textThemeDark.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        titleMedium: textThemeDark.titleMedium?.copyWith(
          color: primaryTextDark,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: textThemeDark.bodyMedium?.copyWith(
          color: secondaryTextDark,
          fontSize: 16,
        ),
        bodySmall: textThemeDark.bodySmall?.copyWith(
          color: secondaryTextDark,
          fontSize: 12,
        ),
      ),
      iconTheme: const IconThemeData(color: primaryTextDark, size: 24),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF3E69FE),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      useMaterial3: true,
    );
  }
}


