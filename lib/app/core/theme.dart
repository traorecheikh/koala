import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppSkin {
  blue(Color(0xFF3E69FE), 'Bleu Koala'),
  purple(Color(0xFFAF52DE), 'Violet Royal'),
  green(Color(0xFF32D74B), 'Vert Nature'),
  orange(Color(0xFFFF9F0A), 'Orange Sunset'),
  red(Color(0xFFFF453A), 'Rouge Passion'),
  teal(Color(0xFF30D5C8), 'Teal Océan'),

  spiderRed(Color(0xFFE23636), 'Spider-Man'),
  deadpoolRed(Color(0xFF8B0000), 'Deadpool'),
  gojoPurple(Color(0xFF512DA8), 'Gojo Satoru'),
  batmanDark(Color(0xFF263238), 'Batman'),
  ironmanRed(Color(0xFFBF360C), 'Iron Man'),
  narutoOrange(Color(0xFFFF6D00), 'Naruto'),
  tanjiroGreen(Color(0xFF2E7D32), 'Demon Slayer'),
  flashRed(Color(0xFFFF0000), 'The Flash');

  final Color color;
  final String label;
  const AppSkin(this.color, this.label);
}

class HeroThemeData {
  final String patternAsset;
  final Color baseColor; // Usually matches the skin color or a specific tint
  late final Color patternColor; // Derived or custom
  final double patternOpacity;

  HeroThemeData({
    required this.patternAsset,
    required this.baseColor,
    Color? patternColor,
    this.patternOpacity = 0.05,
  }) {
    this.patternColor = patternColor ?? baseColor;
  }
}

class AppTheme {
  static final ValueNotifier<AppSkin> skinNotifier =
      ValueNotifier(AppSkin.blue);

  static final ValueNotifier<HeroThemeData?> heroThemeNotifier =
      ValueNotifier(null);

  static ThemeData getTheme({
    required AppSkin skin,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = skin.color;

    // Base Colors
    final scaffoldBg =
        isDark ? const Color(0xFF1A1B1E) : const Color(0xFFF2F2F7);
    final surface = isDark ? const Color(0xFF242529) : Colors.white;
    final onSurface = isDark ? Colors.white : const Color(0xFF1C1C1E);

    // Text Theme Base
    final baseTextTheme =
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    final primaryTextColor =
        isDark ? const Color(0xFFEAEAEA) : const Color(0xFF1A1B1E);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6A6A6A);

    final textTheme = GoogleFonts.poppinsTextTheme(baseTextTheme).apply(
      bodyColor: primaryTextColor,
      displayColor: primaryTextColor,
    );

    return ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white, // Assuming white text on primary color buttons
        secondary: const Color(
            0xFF30D5C8), // Fixed secondary or derived? Keeping fixed for now or could match skin
        onSecondary: Colors.white,
        surface: surface,
        onSurface: onSurface,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      textTheme: textTheme.copyWith(
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
          fontSize: 48,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: primaryTextColor,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: secondaryTextColor,
          fontSize: 16,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: secondaryTextColor,
          fontSize: 12,
        ),
      ),
      iconTheme: IconThemeData(color: primaryTextColor, size: 24),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // Keep page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      useMaterial3: true,
    );
  }

  // Deprecated static getters provided for backward compatibility if needed,
  // but better to switch to dynamic generation.
  // We will remove lightTheme/darkTheme and force usage of getTheme with a default skin.
}
