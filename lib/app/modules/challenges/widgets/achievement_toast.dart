import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';

class AchievementToast extends StatelessWidget {
  final String title;
  final String description;
  final int points;
  final VoidCallback? onTap;

  const AchievementToast({
    super.key,
    required this.title,
    required this.description,
    required this.points,
    this.onTap,
  });

  static void show({
    required String title,
    required String description,
    required int points,
  }) {
    if (Get.context == null) return;

    Get.showSnackbar(
      GetSnackBar(
        messageText: AchievementToast(
          title: title,
          description: description,
          points: points,
        ),
        backgroundColor: Colors.transparent,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        animationDuration: const Duration(milliseconds: 500),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        borderRadius: 16.r,
        padding: EdgeInsets.zero,
        isDismissible: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: KoalaShadows.md,
        border: Border.all(
          color: KoalaColors.primaryUi(context).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.2), // Gold
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.star_fill,
              color: const Color(0xFFFFD700),
              size: 24.sp,
            ),
          ).animate().scale(curve: Curves.elasticOut),

          SizedBox(width: 16.w),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: KoalaTypography.heading4(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: KoalaTypography.caption(context).copyWith(
                    color: KoalaColors.textSecondary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Points Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: KoalaColors.primaryUi(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '+$points XP',
              style: KoalaTypography.label(context).copyWith(
                color: KoalaColors.primaryUi(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
