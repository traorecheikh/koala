import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/services/ml/smart_financial_brain.dart';

/// A premium widget that displays smart recommendations from the Financial Brain
class SmartRecommendationsWidget extends StatelessWidget {
  const SmartRecommendationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get or create the SmartFinancialBrain
    if (!Get.isRegistered<SmartFinancialBrain>()) {
      Get.put(SmartFinancialBrain());
    }
    final brain = Get.find<SmartFinancialBrain>();

    return Obx(() {
      final intelligence = brain.intelligence.value;
      final recommendations = intelligence.recommendations;

      if (recommendations.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(CupertinoIcons.wand_stars,
                      color: Colors.white, size: 18.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Recommandations IA',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _RiskBadge(level: intelligence.overallRiskLevel),
              ],
            ),
          ),

          // Recommendations list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.take(3).length,
            itemBuilder: (context, index) {
              return _RecommendationCard(
                recommendation: recommendations[index],
                index: index,
              );
            },
          ),
        ],
      ).animate().fadeIn().slideY(begin: 0.1);
    });
  }
}

class _RiskBadge extends StatelessWidget {
  final RiskLevel level;

  const _RiskBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (level) {
      case RiskLevel.critical:
        color = const Color(0xFFEF4444);
        text = 'Critique';
        break;
      case RiskLevel.high:
        color = const Color(0xFFF97316);
        text = 'Élevé';
        break;
      case RiskLevel.medium:
        color = const Color(0xFFF59E0B);
        text = 'Modéré';
        break;
      case RiskLevel.low:
        color = const Color(0xFF22C55E);
        text = 'Faible';
        break;
      case RiskLevel.minimal:
        color = const Color(0xFF10B981);
        text = 'Minimal';
        break;
      default:
        color = Colors.grey;
        text = 'N/A';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final SmartRecommendation recommendation;
  final int index;

  const _RecommendationCard({
    required this.recommendation,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color priorityColor;
    IconData icon;

    switch (recommendation.priority) {
      case RecommendationPriority.critical:
        priorityColor = const Color(0xFFEF4444);
        icon = CupertinoIcons.exclamationmark_octagon_fill;
        break;
      case RecommendationPriority.high:
        priorityColor = const Color(0xFFF97316);
        icon = CupertinoIcons.exclamationmark_triangle_fill;
        break;
      case RecommendationPriority.medium:
        priorityColor = const Color(0xFFF59E0B);
        icon = CupertinoIcons.lightbulb_fill;
        break;
      default:
        priorityColor = const Color(0xFF22C55E);
        icon = CupertinoIcons.checkmark_circle_fill;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.toNamed(recommendation.actionRoute);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: priorityColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: priorityColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: priorityColor, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        recommendation.category.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: priorityColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: Colors.grey,
                  size: 16.sp,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              recommendation.description,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.bolt_fill,
                    color: const Color(0xFF8B5CF6),
                    size: 12.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    recommendation.impact,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(delay: (100 * index).ms).fadeIn().slideX(begin: 0.1),
    );
  }
}

/// A compact cash flow prediction widget
class CashFlowPredictionCard extends StatelessWidget {
  const CashFlowPredictionCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SmartFinancialBrain>()) {
      Get.put(SmartFinancialBrain());
    }
    final brain = Get.find<SmartFinancialBrain>();

    String formatAmount(double amount) {
      return NumberFormat.compact(locale: 'fr_FR').format(amount.round());
    }

    return Obx(() {
      final prediction = brain.intelligence.value.cashFlowPrediction;

      final isHealthy = prediction.willSurviveMonth &&
          prediction.predictedMonthEndBalance > 0;
      final gradientColors = isHealthy
          ? [const Color(0xFF22C55E), const Color(0xFF10B981)]
          : [const Color(0xFFEF4444), const Color(0xFFF97316)];

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isHealthy
                      ? CupertinoIcons.chart_bar_alt_fill
                      : CupertinoIcons.exclamationmark_triangle_fill,
                  color: Colors.white,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Prévision fin de mois',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              '${formatAmount(prediction.predictedMonthEndBalance)} F',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              prediction.willSurviveMonth
                  ? 'Solde prévu dans ${prediction.daysRemainingInMonth} jours'
                  : '⚠️ Risque de découvert détecté',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 16.h),
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _PredictionStat(
                    label: 'Dépense/jour',
                    value: '${formatAmount(prediction.avgDailySpending)} F',
                  ),
                ),
                Container(
                  width: 1,
                  height: 30.h,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _PredictionStat(
                    label: 'Budget/jour',
                    value: '${formatAmount(prediction.safeDailySpending)} F',
                  ),
                ),
                if (prediction.daysUntilBroke != null) ...[
                  Container(
                    width: 1,
                    height: 30.h,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _PredictionStat(
                      label: 'Autonomie',
                      value: '${prediction.daysUntilBroke} j',
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
    });
  }
}

class _PredictionStat extends StatelessWidget {
  final String label;
  final String value;

  const _PredictionStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Spending velocity gauge widget
class SpendingVelocityGauge extends StatelessWidget {
  const SpendingVelocityGauge({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SmartFinancialBrain>()) {
      Get.put(SmartFinancialBrain());
    }
    final brain = Get.find<SmartFinancialBrain>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final behavior = brain.intelligence.value.spendingBehavior;

      Color patternColor;
      String patternText;
      IconData patternIcon;

      switch (behavior.pattern) {
        case SpendingPattern.reckless:
          patternColor = const Color(0xFFEF4444);
          patternText = 'Dépenses excessives';
          patternIcon = CupertinoIcons.flame_fill;
          break;
        case SpendingPattern.aggressive:
          patternColor = const Color(0xFFF97316);
          patternText = 'Dépenses agressives';
          patternIcon = CupertinoIcons.arrow_up_right;
          break;
        case SpendingPattern.atRisk:
          patternColor = const Color(0xFFF59E0B);
          patternText = 'À surveiller';
          patternIcon = CupertinoIcons.exclamationmark_triangle;
          break;
        case SpendingPattern.balanced:
          patternColor = const Color(0xFF22C55E);
          patternText = 'Équilibré';
          patternIcon = CupertinoIcons.checkmark_circle;
          break;
        case SpendingPattern.conservative:
          patternColor = const Color(0xFF10B981);
          patternText = 'Économe';
          patternIcon = CupertinoIcons.shield_fill;
          break;
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: patternColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(patternIcon, color: patternColor, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patternText,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${NumberFormat.compact(locale: 'fr_FR').format(behavior.avgDailySpending)} F/jour en moyenne',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(behavior.velocityRatio * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: patternColor,
                  ),
                ),
                Text(
                  'vitesse',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().slideX(begin: 0.1);
    });
  }
}
