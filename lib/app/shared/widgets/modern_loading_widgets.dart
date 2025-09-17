import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modern loading indicators with smooth animations
class ModernLoadingIndicator extends StatefulWidget {
  final String? message;
  final bool showProgress;
  final double? progress;
  final Color? color;

  const ModernLoadingIndicator({
    Key? key,
    this.message,
    this.showProgress = false,
    this.progress,
    this.color,
  }) : super(key: key);

  @override
  State<ModernLoadingIndicator> createState() => _ModernLoadingIndicatorState();
}

class _ModernLoadingIndicatorState extends State<ModernLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _rotationController.repeat();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.color ?? theme.colorScheme.primary;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modern circular progress indicator
          if (!widget.showProgress) ...[
            SizedBox(
              width: 48.w,
              height: 48.w,
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * 3.14159,
                    child: CustomPaint(
                      size: Size(48.w, 48.w),
                      painter: ModernCircularProgressPainter(
                        color: primaryColor,
                        strokeWidth: 3.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            // Linear progress indicator
            Container(
              width: 200.w,
              height: 4.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.h),
                color: primaryColor.withOpacity(0.2),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: (widget.progress ?? 0) * 200.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.h),
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Loading message
          if (widget.message != null) ...[
            SizedBox(height: 24.h),
            Text(
              widget.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom painter for modern circular progress indicator
class ModernCircularProgressPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  ModernCircularProgressPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    const startAngle = -3.14159 / 2; // Start from top
    const sweepAngle = 3.14159; // Half circle

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Modern error display widget
class ModernErrorDisplay extends StatefulWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ModernErrorDisplay({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon,
  }) : super(key: key);

  @override
  State<ModernErrorDisplay> createState() => _ModernErrorDisplayState();
}

class _ModernErrorDisplayState extends State<ModernErrorDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error icon with subtle animation
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.errorContainer,
                    border: Border.all(
                      color: theme.colorScheme.error.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    widget.icon ?? Icons.error_outline_rounded,
                    color: theme.colorScheme.error,
                    size: 32.w,
                  ),
                ),

                SizedBox(height: 20.h),

                // Error message
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Text(
                    widget.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Retry button
                if (widget.onRetry != null) ...[
                  SizedBox(height: 24.h),
                  OutlinedButton.icon(
                    onPressed: widget.onRetry,
                    icon: Icon(Icons.refresh_rounded, size: 18.w),
                    label: const Text('Réessayer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.5,
                      ),
                      minimumSize: Size(120.w, 40.h),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
