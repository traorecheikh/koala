import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/modules/splash/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // 1. Hero Logo (Clean & Iconic)
              Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(28.w),
                child: Image.asset(
                  'assets/logo.png',
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.account_balance_wallet,
                    size: 60.sp,
                    color: Colors.black,
                  ),
                ),
              )
                  .animate()
                  .scale(
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                      begin: const Offset(0.5, 0.5))
                  .then()
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(
                      end: 1.05,
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOutSine), // Subtle Breathing

              SizedBox(height: 40.h),

              // 2. Title (Bold & Big)
              Text(
                'Koala',
                style: KoalaTypography.heading1(context).copyWith(
                  fontSize: 56.sp, // Much Bigger
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(
                      begin: 0.5, end: 0, curve: Curves.easeOutBack) // Slide Up
                  .shimmer(
                      delay: 1200.ms,
                      duration: 1500.ms,
                      color: Colors.white.withValues(alpha: 0.5)),

              SizedBox(height: 12.h),

              Text(
                'Finance Intelligente',
                style: KoalaTypography.bodyLarge(context).copyWith(
                  color: KoalaColors.textSecondary(context),
                  fontSize: 18.sp, // Bigger tagline
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

              const Spacer(),

              // 3. Status & Loader (Bottom Anchored)
              SizedBox(
                height: 100.h,
                child: Column(
                  children: [
                    // Native iOS-style loader for premium feel
                    const CupertinoActivityIndicator(radius: 12),

                    SizedBox(height: 20.h),

                    Obx(() => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            controller.statusMessage.value,
                            key: ValueKey(controller.statusMessage.value),
                            style: KoalaTypography.caption(context).copyWith(
                              color: KoalaColors.textSecondary(context)
                                  .withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                  ],
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ],
      ),
    );
  }
}
