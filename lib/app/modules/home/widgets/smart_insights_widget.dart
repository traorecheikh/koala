import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';
import 'package:koaa/app/services/ml_service.dart';

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
                    Icon(CupertinoIcons.lightbulb_fill, color: Colors.amber, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Insights',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    // Quick dismiss all logic for demo (or implement per-card dismiss)
                    controller.insights.clear(); 
                  },
                  child: Icon(CupertinoIcons.xmark_circle_fill, color: Colors.grey.withOpacity(0.5), size: 20.sp),
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
                  onDismiss: () => controller.insights.remove(insight), // Pass dismiss handler
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
  final VoidCallback onDismiss; // Add callback

  const _InsightCard({required this.insight, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color color;
    IconData icon;

    switch (insight.type) {
      case InsightType.positive:
        color = Colors.green;
        icon = CupertinoIcons.checkmark_circle_fill;
        break;
      case InsightType.warning:
        color = Colors.orange;
        icon = CupertinoIcons.exclamationmark_triangle_fill;
        break;
      case InsightType.tip:
        color = Colors.blue;
        icon = CupertinoIcons.info_circle_fill;
        break;
      case InsightType.info:
      default:
        color = Colors.grey;
        icon = CupertinoIcons.lightbulb_fill;
        break;
    }

    return Stack( // Wrap in stack for close button
      children: [
        Container(
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Expanded(
                          child: Text(
                            insight.description,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark ? Colors.white70 : Colors.black54,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8.h,
          right: 20.w,
          child: GestureDetector(
            onTap: onDismiss,
            child: Icon(CupertinoIcons.xmark, size: 16.sp, color: Colors.grey.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }
}
