import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/services/intelligence/intelligence_service.dart';

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

            // Quick Forecast Summary
            if (service.forecast.value != null)
              _ForecastSummaryCard(forecast: service.forecast.value!),
            SizedBox(height: 16.h),

            // Proactive Alerts (if any critical/high)
            if (service.highPriorityAlerts.isNotEmpty) ...[
              _AlertsSection(alerts: service.highPriorityAlerts),
            ],
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
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
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

/// Displays the financial health score with a clean, secondary card style
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
        color: isDark ? const Color(0xFF1A1B1E) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                Text(
                  'Santé Financière',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      summary.statusText,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      summary.statusEmoji,
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  summary.statusDescription,
                  style: TextStyle(
                    fontSize: 12.sp,
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
      width: 70.w,
      height: 70.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 70.w,
            height: 70.w,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 6.w,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color.withOpacity(0.1)),
            ),
          ),
          // Animated progress circle
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return SizedBox(
                width: 70.w,
                height: 70.w,
                child: CustomPaint(
                  painter: _ArcPainter(
                    progress: value,
                    color: color,
                    strokeWidth: 6.w,
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
                  fontSize: 22.sp,
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
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.bell_fill,
                color: Colors.orange,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Alertes',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...alerts.take(3).map((alert) => _AlertCard(alert: alert)),
      ],
    );
  }
}

/// Individual alert card styled like Insights
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
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1B1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: alertColor, width: 6.w)),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: alertColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(alert.icon, size: 16.sp, color: alertColor),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    alert.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                InkWell(
                  onTap: () => Get.find<IntelligenceService>().dismissAlert(alert.id),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(CupertinoIcons.xmark, size: 18.sp, color: Colors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              alert.message,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
            ),
            if (alert.actionSuggestion.isNotEmpty) ...[
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  // TODO: Implement specific fix actions
                  Get.snackbar('Action', 'Applying fix: ${alert.actionSuggestion}');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: alertColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.lightbulb,
                        size: 14.sp,
                        color: alertColor,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          alert.actionSuggestion,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(CupertinoIcons.chevron_right, size: 14.sp, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
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
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1B1E) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.chart_bar_alt_fill,
                    color: Colors.blue,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Prévision 30 jours',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
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
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40.h,
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
                Expanded(
                  child: _ForecastMetric(
                    label: 'Point bas',
                    value: '${summary.lowestBalance.toStringAsFixed(0)} F',
                    color: summary.lowestBalance < 0 ? Colors.red : Colors.grey,
                    icon: CupertinoIcons.arrow_down,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }
}

class _ForecastMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _ForecastMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? Colors.white54 : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}