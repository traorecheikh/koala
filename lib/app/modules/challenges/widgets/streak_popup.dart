import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';

class StreakPopup extends StatelessWidget {
  final int days;
  final VoidCallback? onDismiss;

  const StreakPopup({super.key, required this.days, this.onDismiss});

  static Future<void> show(int days) async {
    if (Get.context == null) return;

    final overlay = Get.overlayContext;
    if (overlay == null) return;

    // Show dialog-like overlay
    await Get.dialog(
      StreakPopup(days: days),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 300.w,
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: KoalaColors.surface(context),
            borderRadius: BorderRadius.circular(32.r),
            boxShadow: KoalaShadows.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fire Icon with Pulse
              Icon(
                Icons
                    .local_fire_department_sharp, // Use standard icon closest to 'fire'
                size: 80.sp,
                color: const Color(0xFFFF9500),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: 1000.ms)
                  .then()
                  .shimmer(color: Colors.yellow, duration: 1500.ms),

              SizedBox(height: 24.h),

              Text(
                '$days',
                style: KoalaTypography.heading1(context).copyWith(
                  fontSize: 64.sp,
                  color: const Color(0xFFFF9500),
                  height: 1,
                ),
              )
                  .animate()
                  .fadeIn()
                  .scale(delay: 200.ms, curve: Curves.elasticOut),

              Text(
                'JOURS',
                style: KoalaTypography.heading3(context).copyWith(
                  letterSpacing: 4,
                  fontWeight: FontWeight.w900,
                  color: KoalaColors.textSecondary(context),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0),

              SizedBox(height: 16.h),

              Text(
                'Série en cours !',
                style: KoalaTypography.bodyMedium(context),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 600.ms),

              SizedBox(height: 32.h),

              SizedBox(
                width: 200.w,
                child: KoalaButton(
                  text: 'Continuer',
                  onPressed: () => Get.back(),
                ),
              ).animate().fadeIn(delay: 800.ms).scale(),
            ],
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}
