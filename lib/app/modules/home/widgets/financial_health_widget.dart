// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/services/intelligence/intelligence_service.dart';
import 'package:koaa/app/routes/app_pages.dart';
import 'package:intl/intl.dart';

/// A smart, clean financial profile widget
/// "Smart Clean" aesthetic: Solid colors, Bento grid, Functional animations
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
            // 1. Main Score Card (Minimalist Ring)
            _SmartScoreCard(summary: summary),
            SizedBox(height: 16.h),

            // 2. Alerts & Insights (Bento Grid)
            if (service.highPriorityAlerts.isNotEmpty ||
                service.forecast.value != null)
              _BentoGridSection(
                alerts: service.highPriorityAlerts,
                forecast: service.forecast.value,
              ),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.xl),
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              color: KoalaColors.primaryUi(context),
            ),
            SizedBox(height: 16.h),
            Text(
              'Analyse de vos finances...',
              style: KoalaTypography.bodyMedium(context)
                  .copyWith(color: KoalaColors.textSecondary(context)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimalist Score Card with Solid Ring
class _SmartScoreCard extends StatelessWidget {
  final IntelligenceSummary summary;

  const _SmartScoreCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    // Determine status color (Solid, no gradients)
    Color statusColor;
    if (summary.healthScore >= 80) {
      statusColor = KoalaColors.success;
    } else if (summary.healthScore >= 60) {
      statusColor = KoalaColors.warning;
    } else {
      statusColor = KoalaColors.destructive;
    }

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.xl),
        border: Border.all(color: KoalaColors.border(context)),
        boxShadow: KoalaShadows.sm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profil Financier',
                    style: KoalaTypography.bodyMedium(context).copyWith(
                      color: KoalaColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    summary.statusText,
                    style: KoalaTypography.heading2(context).copyWith(
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KoalaRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(summary.healthScore),
                            size: 14.sp, color: statusColor),
                        SizedBox(width: 6.w),
                        Text(
                          summary.healthScore >= 80
                              ? 'Excellent'
                              : summary.healthScore >= 60
                                  ? 'Bon'
                                  : 'Attention',
                          style: KoalaTypography.caption(context).copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Smart Ring
              _SolidScoreRing(score: summary.healthScore, color: statusColor),
            ],
          ),
          SizedBox(height: 24.h),
          Divider(height: 1, color: KoalaColors.border(context)),
          SizedBox(height: 16.h),
          // Action / Insight text
          Row(
            children: [
              Icon(CupertinoIcons.info,
                  size: 16.sp, color: KoalaColors.textSecondary(context)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  summary.statusDescription,
                  style: KoalaTypography.bodySmall(context).copyWith(
                    color: KoalaColors.textSecondary(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(int score) {
    if (score >= 80) return CupertinoIcons.check_mark_circled_solid;
    if (score >= 60) return CupertinoIcons.info_circle_fill;
    return CupertinoIcons.exclamationmark_triangle_fill;
  }
}

/// Functional, solid color ring
class _SolidScoreRing extends StatelessWidget {
  final int score;
  final Color color;

  const _SolidScoreRing({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      height: 100.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Track
          SizedBox(
            width: 100.w,
            height: 100.w,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 8.w,
              color:
                  KoalaColors.border(context).withOpacity(0.5), // Subtle track
            ),
          ),
          // Progress
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: 1000.ms,
            curve: Curves.easeOutExpo,
            builder: (context, value, _) {
              return SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8.w,
                    color: color,
                    strokeCap: StrokeCap.round,
                  ));
            },
          ),
          // Score Number
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: score),
                duration: 1000.ms,
                curve: Curves.easeOutExpo,
                builder: (context, value, _) {
                  return Text(
                    '$value',
                    style: KoalaTypography.heading2(context).copyWith(
                      fontSize: 28.sp,
                      height: 1.0,
                    ),
                  );
                },
              ),
              Text(
                '/100',
                style: KoalaTypography.caption(context).copyWith(
                  color: KoalaColors.textSecondary(context),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bento Grid for Alerts and Forecasts
class _BentoGridSection extends StatelessWidget {
  final List<ProactiveAlert> alerts;
  final CashFlowForecast? forecast;

  const _BentoGridSection({required this.alerts, this.forecast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (forecast != null) ...[
          // Forecast Card (Full Width)
          _ForecastBentoCard(forecast: forecast!),
          SizedBox(height: 16.h),
        ],
        // Alerts Grid (2 columns if multiple, or list)
        if (alerts.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.take(3).length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) =>
                _AlertBentoCard(alert: alerts[index]),
          ),
      ],
    );
  }
}

class _ForecastBentoCard extends StatelessWidget {
  final CashFlowForecast forecast;

  const _ForecastBentoCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final summary = forecast.summary;
    final isPositive = summary.endBalance > 0;
    final trendColor =
        isPositive ? KoalaColors.success : KoalaColors.destructive;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.lg),
        border: Border.all(color: KoalaColors.border(context)),
        boxShadow: KoalaShadows.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.graph_square_fill,
                  color: KoalaColors.primaryUi(context), size: 18.sp),
              SizedBox(width: 8.w),
              Text('Prévision 30 jours', style: KoalaTypography.label(context)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solde estimé',
                    style: KoalaTypography.caption(context),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${NumberFormat.compact(locale: "fr_FR").format(summary.endBalance)} F',
                    style: KoalaTypography.heading3(context)
                        .copyWith(color: trendColor),
                  ),
                ],
              ),
              Container(
                  width: 1, height: 32.h, color: KoalaColors.border(context)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Point bas',
                    style: KoalaTypography.caption(context),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${NumberFormat.compact(locale: "fr_FR").format(summary.lowestBalance)} F',
                    style: KoalaTypography.heading3(context).copyWith(
                        color: summary.lowestBalance < 0
                            ? KoalaColors.destructive
                            : KoalaColors.text(context)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertBentoCard extends StatelessWidget {
  final ProactiveAlert alert;

  const _AlertBentoCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    IconData icon;

    switch (alert.severity) {
      case AlertSeverity.critical:
        accentColor = KoalaColors.destructive;
        icon = CupertinoIcons.exclamationmark_shield_fill;
        break;
      case AlertSeverity.high:
        accentColor = KoalaColors.warning;
        icon = CupertinoIcons.exclamationmark_triangle_fill;
        break;
      case AlertSeverity.positive:
        accentColor = KoalaColors.success;
        icon = CupertinoIcons.hand_thumbsup_fill;
        break;
      default:
        accentColor = KoalaColors.accent;
        icon = CupertinoIcons.lightbulb_fill;
    }

    return GestureDetector(
      onTap: () {
        // Simple routing logic based on action suggestion (reused from before)
        _handleNavigation(alert.actionSuggestion);
      },
      child: Container(
        decoration: BoxDecoration(
          color: KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(KoalaRadius.lg),
          border: Border.all(color: KoalaColors.border(context)),
          boxShadow: KoalaShadows.xs,
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accent Strip
              Container(width: 4.w, color: accentColor),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle),
                        child: Icon(icon, size: 16.sp, color: accentColor),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.title,
                              style: KoalaTypography.bodyMedium(context)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              alert.message,
                              style: KoalaTypography.caption(context)
                                  .copyWith(height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (alert.actionSuggestion.isNotEmpty) ...[
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Text(
                                    alert.actionSuggestion,
                                    style: KoalaTypography.caption(context)
                                        .copyWith(
                                            color: accentColor,
                                            fontWeight: FontWeight.w600),
                                  ),
                                  Icon(CupertinoIcons.chevron_right,
                                      size: 12.sp, color: accentColor),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.find<IntelligenceService>()
                            .dismissAlert(alert.id),
                        child: Icon(CupertinoIcons.xmark,
                            size: 16.sp,
                            color: KoalaColors.textSecondary(context)),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(String action) {
    if (action.isEmpty) return;
    final act = action.toLowerCase();
    if (act.contains('budget') || act.contains('dépenses')) {
      Get.toNamed(Routes.budget);
    } else if (act.contains('dette') || act.contains('remboursement')) {
      Get.toNamed(Routes.debt);
    } else if (act.contains('objectif')) {
      Get.toNamed(Routes.goals);
    } else {
      Get.toNamed(Routes.analytics);
    }
  }
}

