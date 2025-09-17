import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable gradient container widget for consistent modern UI design
/// Provides predefined gradient styles based on app theme
class GradientContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final GradientType gradientType;
  final List<Color>? customColors;
  final bool addShadow;
  final double elevation;
  final Border? border;

  const GradientContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.gradientType = GradientType.primary,
    this.customColors,
    this.addShadow = true,
    this.elevation = 4.0,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        gradient: _getGradient(theme),
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: border,
        boxShadow: addShadow ? _getShadow(theme) : null,
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(16.w),
        child: child,
      ),
    );
  }

  LinearGradient _getGradient(ThemeData theme) {
    if (customColors != null && customColors!.length >= 2) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: customColors!,
      );
    }

    switch (gradientType) {
      case GradientType.primary:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withBlue(
              (theme.colorScheme.primary.blue * 0.8).round(),
            ),
            theme.colorScheme.secondary.withOpacity(0.9),
          ],
        );
      case GradientType.secondary:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.secondary,
            theme.colorScheme.secondary.withOpacity(0.8),
          ],
        );
      case GradientType.surface:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceVariant.withOpacity(0.7),
          ],
        );
      case GradientType.error:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.error,
            theme.colorScheme.error.withOpacity(0.8),
          ],
        );
      case GradientType.warning:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFBBC04),
            const Color(0xFFFBBC04).withOpacity(0.8),
          ],
        );
      case GradientType.success:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.secondary,
            theme.colorScheme.secondary.withOpacity(0.8),
          ],
        );
      case GradientType.subtle:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surfaceVariant.withOpacity(0.3),
            theme.colorScheme.surface,
          ],
        );
    }
  }

  List<BoxShadow> _getShadow(ThemeData theme) {
    Color shadowColor;
    switch (gradientType) {
      case GradientType.primary:
        shadowColor = theme.colorScheme.primary;
        break;
      case GradientType.secondary:
        shadowColor = theme.colorScheme.secondary;
        break;
      case GradientType.error:
        shadowColor = theme.colorScheme.error;
        break;
      default:
        shadowColor = theme.colorScheme.shadow;
    }

    return [
      BoxShadow(
        color: shadowColor.withOpacity(0.15),
        blurRadius: elevation * 2,
        spreadRadius: elevation * 0.5,
        offset: Offset(0, elevation),
      ),
      BoxShadow(
        color: shadowColor.withOpacity(0.1),
        blurRadius: elevation * 4,
        spreadRadius: elevation,
        offset: Offset(0, elevation * 2),
      ),
    ];
  }
}

/// Predefined gradient types for consistent design
enum GradientType {
  primary,
  secondary,
  surface,
  error,
  warning,
  success,
  subtle,
}

/// Extension for easy gradient container creation
extension GradientContainerExtension on Widget {
  Widget withGradient({
    GradientType gradientType = GradientType.primary,
    double borderRadius = 16.0,
    bool addShadow = true,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double elevation = 4.0,
  }) {
    return GradientContainer(
      gradientType: gradientType,
      borderRadius: borderRadius,
      addShadow: addShadow,
      padding: padding,
      margin: margin,
      elevation: elevation,
      child: this,
    );
  }
}