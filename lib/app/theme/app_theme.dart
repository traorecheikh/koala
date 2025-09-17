import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF00A87A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE0FFF8),
    onPrimaryContainer: Color(0xFF002018),
    secondary: Color(0xFF6A5ACD),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF0EEFF),
    onSecondaryContainer: Color(0xFF24005A),
    tertiary: Color(0xFFFFA000),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFECB3),
    onTertiaryContainer: Color(0xFF241A00),
    error: Color(0xFFD32F2F),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFEBEE),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF8F9FA),
    onSurface: Color(0xFF212529),
    surfaceVariant: Color(0xFFE9ECEF),
    onSurfaceVariant: Color(0xFF495057),
    outline: Color(0xFFADB5BD),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFF343A40),
    onInverseSurface: Color(0xFFF1F3F4),
    inversePrimary: Color(0xFF00C896),
    surfaceTint: Color(0xFF00A87A),
  );

  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF00C896),
    onPrimary: Color(0xFF00382B),
    primaryContainer: Color(0xFF00513F),
    onPrimaryContainer: Color(0xFFE0FFF8),
    secondary: Color(0xFF7B68EE),
    onSecondary: Color(0xFF3E008E),
    secondaryContainer: Color(0xFF5B4BA6),
    onSecondaryContainer: Color(0xFFF0EEFF),
    tertiary: Color(0xFFFFB74D),
    onTertiary: Color(0xFF3F2E00),
    tertiaryContainer: Color(0xFF5B4300),
    onTertiaryContainer: Color(0xFFFFECB3),
    error: Color(0xFFE57373),
    onError: Color(0xFF601414),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFEBEE),
    surface: Color(0xFF1A1D20),
    onSurface: Color(0xFFE9ECEF),
    surfaceVariant: Color(0xFF212529),
    onSurfaceVariant: Color(0xFFCED4DA),
    outline: Color(0xFF6C757D),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFFE9ECEF),
    onInverseSurface: Color(0xFF212529),
    inversePrimary: Color(0xFF00A87A),
    surfaceTint: Color(0xFF00C896),
  );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    textTheme: _textTheme(_lightColorScheme),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: _lightColorScheme.surface,
      foregroundColor: _lightColorScheme.onSurface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: _lightColorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _lightColorScheme.outline.withOpacity(0.2)),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    textTheme: _textTheme(_darkColorScheme),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: _darkColorScheme.surface,
      foregroundColor: _darkColorScheme.onSurface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: _darkColorScheme.surfaceVariant,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _darkColorScheme.outline.withOpacity(0.3)),
      ),
    ),
  );

  static TextTheme _textTheme(ColorScheme colorScheme) {
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: colorScheme.brightness).textTheme,
    );
    return textTheme
        .copyWith(
          displayLarge: textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          displayMedium: textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          displaySmall: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          headlineLarge: textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleLarge: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleMedium: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleSmall: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: textTheme.bodyLarge?.copyWith(),
          bodyMedium: textTheme.bodyMedium?.copyWith(),
          bodySmall: textTheme.bodySmall?.copyWith(),
          labelLarge: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          labelMedium: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          labelSmall: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        )
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );
  }
}
