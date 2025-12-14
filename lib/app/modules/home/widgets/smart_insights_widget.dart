import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';
import 'package:koaa/app/services/ml_service.dart';
import 'package:koaa/app/routes/app_pages.dart';

class SmartInsightsWidget extends GetView<HomeController> {
  const SmartInsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final insights = controller.insights;
      if (insights.isEmpty) return const SizedBox.shrink();

      // Show top 3 insights
      final topInsights = insights.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.lightbulb_fill,
                        color: KoalaColors.warning, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Insights',
                      style: KoalaTypography.heading3(context),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    // Quick dismiss all logic for demo (or implement per-card dismiss)
                    controller.insights.clear();
                  },
                  child: Icon(CupertinoIcons.xmark_circle_fill,
                      color:
                          KoalaColors.textSecondary(context).withOpacity(0.5),
                      size: 20.sp),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 140.h,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: topInsights.length,
              padEnds: false,
              itemBuilder: (context, index) {
                final insight = topInsights[index];
                return _InsightCard(
                  insight: insight,
                  onDismiss: () => controller.insights
                      .remove(insight), // Pass dismiss handler
                );
              },
            ),
          ),
        ],
      ).animate().fadeIn().slideY(begin: 0.2, end: 0);
    });
  }
}

class _InsightCard extends StatelessWidget {
  final MLInsight insight;
  final VoidCallback onDismiss;

  const _InsightCard({required this.insight, required this.onDismiss});

  void _handleAction(BuildContext context) {
    final label = insight.actionLabel?.toLowerCase() ?? '';

    if (label.contains('budget') || label.contains('dépenses')) {
      Get.toNamed(Routes.budget);
    } else if (label.contains('dette') || label.contains('remboursement')) {
      Get.toNamed(Routes.debt);
    } else if (label.contains('objectif')) {
      Get.toNamed(Routes.goals);
    } else if (label.contains('voir') || label.contains('détail')) {
      Get.toNamed(Routes.analytics);
    } else if (label.contains('conseils')) {
      Get.toNamed(Routes.analytics);
    } else if (label.contains('prêts')) {
      Get.toNamed(Routes.debt);
    } else if (label.contains('planifier')) {
      Get.toNamed(Routes.budget);
    } else {
      Get.toNamed(Routes.analytics);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (insight.type) {
      case InsightType.positive:
        color = KoalaColors.success;
        icon = CupertinoIcons.checkmark_circle_fill;
        break;
      case InsightType.warning:
        color = KoalaColors.warning;
        icon = CupertinoIcons.exclamationmark_triangle_fill;
        break;
      case InsightType.tip:
        color = KoalaColors.accent;
        icon = CupertinoIcons.info_circle_fill;
        break;
      case InsightType.info:
      default:
        color = KoalaColors.textSecondary(context);
        icon = CupertinoIcons.lightbulb_fill;
        break;
    }

    return Stack(
      children: [
        GestureDetector(
          onTap:
              insight.actionLabel != null ? () => _handleAction(context) : null,
          child: Container(
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              color: KoalaColors.surface(context),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: KoalaColors.shadowSubtle,
              border: Border.all(color: KoalaColors.border(context)),
            ),
            clipBehavior: Clip.hardEdge,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 6.w,
                    color: color,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: color, size: 16.sp),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  insight.title,
                                  style: KoalaTypography.bodyLarge(context)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            insight.description,
                            style: KoalaTypography.bodyMedium(context).copyWith(
                              color: KoalaColors.textSecondary(context),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (insight.actionLabel != null) ...[
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    insight.actionLabel!,
                                    style: KoalaTypography.caption(context)
                                        .copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(CupertinoIcons.chevron_right,
                                      color: color, size: 12.sp),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8.h,
          right: 20.w,
          child: GestureDetector(
            onTap: onDismiss,
            child: Icon(CupertinoIcons.xmark,
                size: 16.sp,
                color: KoalaColors.textSecondary(context).withOpacity(0.5)),
          ),
        ),
      ],
    );
  }
}

