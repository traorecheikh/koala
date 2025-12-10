import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/services/intelligence/intelligence_service.dart';
import 'package:koaa/app/services/intelligence/koala_brain.dart';

/// A comprehensive financial health dashboard widget
/// Shows health score, alerts, and quick forecasts
class FinancialHealthWidget extends StatelessWidget {
  const FinancialHealthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<IntelligenceService>(
      builder: (service) {
        if (service.isLoading.value) {
          return _buildLoadingState(context);
        }

        final summary = service.getSummary();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Score Header
            _HealthScoreCard(summary: summary),
            SizedBox(height: 16.h),

            // Proactive Alerts (if any critical/high)
            if (service.highPriorityAlerts.isNotEmpty) ...[
              _AlertsSection(alerts: service.highPriorityAlerts),
              SizedBox(height: 16.h),
            ],

            // Quick Forecast Summary
            if (service.forecast.value != null)
              _ForecastSummaryCard(forecast: service.forecast.value!),
          ],
        ).animate().fadeIn().slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 8.h),
            Text(
              'Analyse en cours...',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays the financial health score with a circular progress indicator
class _HealthScoreCard extends StatelessWidget {
  final IntelligenceSummary summary;

  const _HealthScoreCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color scoreColor;
    if (summary.healthScore >= 80) {
      scoreColor = Colors.green;
    } else if (summary.healthScore >= 60) {
      scoreColor = Colors.amber;
    } else if (summary.healthScore >= 40) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E1E2E),
                  const Color(0xFF2A2A3E),
                ]
              : [
                  Colors.white,
                  Colors.grey.shade50,
                ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Score Indicator
          _AnimatedHealthScore(
            score: summary.healthScore,
            color: scoreColor,
          ),
          SizedBox(width: 20.w),

          // Status Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      summary.statusEmoji,
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Santé Financière',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  summary.statusText,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  summary.statusDescription,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? Colors.white54 : Colors.black45,
                    height: 1.3,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(
      begin: const Offset(0.95, 0.95),
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }
}

/// Animated circular health score indicator
class _AnimatedHealthScore extends StatelessWidget {
  final int score;
  final Color color;

  const _AnimatedHealthScore({
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80.w,
      height: 80.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 80.w,
            height: 80.w,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 8.w,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color.withOpacity(0.15)),
            ),
          ),
          // Animated progress circle
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return SizedBox(
                width: 80.w,
                height: 80.w,
                child: CustomPaint(
                  painter: _ArcPainter(
                    progress: value,
                    color: color,
                    strokeWidth: 8.w,
                  ),
                ),
              );
            },
          ),
          // Score text
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: score),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Text(
                '$value',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the arc progress indicator
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ArcPainter({
    required this.progress,
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

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress, // Sweep angle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

/// Section showing proactive alerts
class _AlertsSection extends StatelessWidget {
  final List<ProactiveAlert> alerts;

  const _AlertsSection({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.bell_fill,
                color: Colors.orange,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Alertes',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${alerts.length}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ...alerts.take(3).map((alert) => _AlertCard(alert: alert)),
      ],
    );
  }
}

/// Individual alert card
class _AlertCard extends StatelessWidget {
  final ProactiveAlert alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color alertColor;
    switch (alert.severity) {
      case AlertSeverity.critical:
        alertColor = Colors.red;
        break;
      case AlertSeverity.high:
        alertColor = Colors.orange;
        break;
      case AlertSeverity.medium:
        alertColor = Colors.amber;
        break;
      case AlertSeverity.positive:
        alertColor = Colors.green;
        break;
      default:
        alertColor = Colors.blue;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark
            ? alertColor.withOpacity(0.15)
            : alertColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: alertColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(alert.icon, style: TextStyle(fontSize: 24.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.3,
                  ),
                ),
                if (alert.actionSuggestion.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.lightbulb,
                        size: 12.sp,
                        color: alertColor,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          alert.actionSuggestion,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: alertColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
  }
}

/// Quick forecast summary card
class _ForecastSummaryCard extends StatelessWidget {
  final CashFlowForecast forecast;

  const _ForecastSummaryCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final summary = forecast.summary;

    final isPositive = summary.endBalance > 0;
    final trendColor = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.chart_bar_alt_fill,
                color: Colors.blue,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Prévision 30 jours',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _ForecastMetric(
                  label: 'Solde prévu',
                  value: '${summary.endBalance.toStringAsFixed(0)} F',
                  color: trendColor,
                  icon: isPositive
                      ? CupertinoIcons.arrow_up_right
                      : CupertinoIcons.arrow_down_right,
                ),
              ),
              Container(
                width: 1,
                height: 50.h,
                color: Colors.grey.withOpacity(0.2),
              ),
              Expanded(
                child: _ForecastMetric(
                  label: 'Point bas',
                  value: '${summary.lowestBalance.toStringAsFixed(0)} F',
                  color: summary.lowestBalance < 0 ? Colors.red : Colors.grey,
                  icon: CupertinoIcons.minus_circle,
                ),
              ),
            ],
          ),
          if (summary.warnings.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    color: Colors.orange,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      summary.warnings.first,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }
}

/// Individual forecast metric display
class _ForecastMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ForecastMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
