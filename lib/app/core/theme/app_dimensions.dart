import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App dimensions and spacing constants based on design tokens with ScreenUtil responsiveness
class AppDimensions {
  // Responsive spacing values from design tokens
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;

  // Responsive touch targets
  static double get minTouchTarget => 44.w;
  static double get buttonPadding => 16.w;
  static double get listItemHeight => 48.h;
}

/// App spacing constants with ScreenUtil responsiveness
class AppSpacing {
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get minTouchTarget => 44.w;
}

/// App radius constants with ScreenUtil responsiveness
class AppRadius {
  static double get sm => 8.r;
  static double get md => 12.r;
  static double get lg => 16.r;
}

/// App elevation constants
class AppElevation {
  static const double level1 = 2.0;
  static const double level2 = 4.0;
  static const double level3 = 8.0;
}
