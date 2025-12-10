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
              children: [
                Icon(CupertinoIcons.lightbulb_fill, color: Colors.amber, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Insights',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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
                return _InsightCard(insight: insight);
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

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
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

    return Container(
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
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
              Icon(icon, color: color, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Text(
              insight.description,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
