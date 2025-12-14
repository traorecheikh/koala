import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KoalaTheme {
  static final Color primaryColor = const Color(0xFF4C6EF5);
  static final Color accentColor = const Color(0xFF748FFC); // Lighter shade of primary
  static final Color successColor = const Color(0xFF40C057);
  static final Color warningColor = const Color(0xFFFAB005);
  static final Color dangerColor = const Color(0xFFFA5252);
  static final Color infoColor = const Color(0xFF228BE6);

  static final Color darkBackgroundColor = const Color(0xFF1A1B1E);
  static final Color darkCardColor = const Color(0xFF2B2C30);
  static final Color lightBackgroundColor = const Color(0xFFF8F9FA);
  static final Color lightCardColor = Colors.white;

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      error: dangerColor,
      surface: lightCardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: lightBackgroundColor,
    cardColor: lightCardColor,
    appBarTheme: AppBarTheme(
      backgroundColor: lightBackgroundColor,
      foregroundColor: Colors.black87,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87, size: 24.sp),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 57.sp, fontWeight: FontWeight.bold, color: Colors.black87),
      displayMedium: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.bold, color: Colors.black87),
      displaySmall: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold, color: Colors.black87),
      headlineLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.black87),
      headlineMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.black87),
      headlineSmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.black87),
      titleLarge: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black87),
      titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
      titleSmall: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black87),
      bodyLarge: TextStyle(fontSize: 16.sp, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14.sp, color: Colors.black87),
      bodySmall: TextStyle(fontSize: 12.sp, color: Colors.black87),
      labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.black87),
      labelSmall: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: Colors.black87),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 1.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: primaryColor, width: 2.w),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.w),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    ),
    // cardTheme: CardTheme(
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16.r),
    //     side: BorderSide(color: Colors.grey.shade200, width: 1.w),
    //   ),
    //   margin: EdgeInsets.zero,
    // ),
    // dialogTheme: DialogTheme(
    //   backgroundColor: lightCardColor,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(20.r),
    //   ),
    //   titleTextStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black87),
    //   contentTextStyle: TextStyle(fontSize: 14.sp, color: Colors.black87),
    // ),
    // Add other common theme properties here
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      error: dangerColor,
      surface: darkCardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white70,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackgroundColor,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white, size: 24.sp),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 57.sp, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.bold, color: Colors.white),
      displaySmall: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold, color: Colors.white),
      headlineLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
      headlineSmall: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white),
      titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
      titleSmall: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16.sp, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 14.sp, color: Colors.white70),
      bodySmall: TextStyle(fontSize: 12.sp, color: Colors.white60),
      labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.white70),
      labelSmall: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: Colors.white60),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 1.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: primaryColor, width: 2.w),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade700, width: 1.w),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    ),
    // cardTheme: CardTheme(
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16.r),
    //     side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.w),
    //   ),
    //   margin: EdgeInsets.zero,
    // ),
    // dialogTheme: DialogTheme(
    //   backgroundColor: darkCardColor,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(20.r),
    //   ),
    //   titleTextStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
    //   contentTextStyle: TextStyle(fontSize: 14.sp, color: Colors.white70),
    // ),
  );
}

