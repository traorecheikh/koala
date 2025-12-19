// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:countup/countup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';
import 'package:koaa/app/core/design_system.dart'; // Import Design System

/// Enhanced balance card with flip animation, time-of-day effects, and summary view
class EnhancedBalanceCard extends GetView<HomeController> {
  const EnhancedBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        controller.toggleCardFlip();
      },
      child: Obx(
        () => TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: controller.isCardFlipped.value ? math.pi : 0,
          ),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            final isFront = value < math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(value),
              child: isFront
                  ? _FrontCard()
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _BackCard(),
                    ),
            );
          },
        ),
      ),
    );
  }
}

/// Front side of the card showing balance
class _FrontCard extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final gradient = controller.getTimeOfDayGradient();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      height: 215.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KoalaRadius.xl),
        gradient: gradient,
        boxShadow: KoalaShadows.md,
      ),
      child: Stack(
        children: [
          // Animated particles effect
          ...List.generate(5, (index) {
            return Positioned(
              left: (index * 80).toDouble(),
              top: (index * 40).toDouble(),
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  CupertinoIcons.sparkles,
                  size: 30.sp,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: 2000.ms, delay: (index * 400).ms)
                  .fadeOut(
                    duration: 2000.ms,
                    delay: (2000 + index * 400).ms,
                  ),
            );
          }),

          // Main content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Votre solde', // Translated from 'Your Balance'
                      style: KoalaTypography.bodyLarge(context).copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            controller.toggleBalanceVisibility();
                          },
                          child: Obx(
                            () => Icon(
                              controller.balanceVisible.value
                                  ? CupertinoIcons.eye_slash_fill
                                  : CupertinoIcons.eye_fill,
                              size: 24,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(
                          CupertinoIcons.arrow_2_circlepath,
                          size: 20.sp,
                          color: Colors.white60,
                        )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .rotate(duration: 2000.ms),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Balance display
                Obx(
                  () => controller.balanceVisible.value
                      ? Countup(
                          begin: 0,
                          end: controller.balance.value,
                          duration: const Duration(milliseconds: 800),
                          separator: ' ',
                          style: KoalaTypography.heading1(context).copyWith(
                            fontSize: 42.sp, // Override for Hero size
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                          curve: Curves.easeOut,
                          prefix: 'FCFA ',
                        )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.3, end: 0, duration: 400.ms)
                      : Text(
                          '••••••••',
                          style: KoalaTypography.heading1(context).copyWith(
                            fontSize: 42.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                ),

                const Spacer(),

                // Time of day indicator
                Row(
                  children: [
                    Icon(
                      _getTimeIcon(),
                      size: 16.sp,
                      color: Colors.white60,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _getTimeGreeting(),
                      style: KoalaTypography.caption(context).copyWith(
                        color: Colors.white60,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Appuyez pour voir les détails', // Translated from 'Tap to view details'
                      style: KoalaTypography.caption(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack);
  }

  IconData _getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return CupertinoIcons.sun_max_fill;
    if (hour >= 12 && hour < 17) return CupertinoIcons.sun_max;
    if (hour >= 17 && hour < 21) return CupertinoIcons.sunset_fill;
    return CupertinoIcons.moon_stars_fill;
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Bonjour'; // Good Morning
    if (hour >= 12 && hour < 17) return 'Bon après-midi'; // Good Afternoon
    if (hour >= 17 && hour < 21) return 'Bonsoir'; // Good Evening
    return 'Bonne nuit'; // Good Night
  }
}

/// Back side of the card showing summary
class _BackCard extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final gradient = controller.getTimeOfDayGradient();

    return Container(
      height: 215.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KoalaRadius.xl),
        gradient: gradient,
        boxShadow: KoalaShadows.md,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Résumé rapide', // Translated from 'Quick Summary'
                  style: KoalaTypography.heading3(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                  size: 20.sp,
                  color: Colors.white70,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: controller.transactions.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune transaction pour le moment', // Translated from 'No transactions yet'
                        style: KoalaTypography.bodyMedium(context).copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Last transaction
                        _SummaryItem(
                          icon: CupertinoIcons.time,
                          title:
                              'Dernière transaction', // Translated from 'Last Transaction'
                          value: controller.lastTransaction != null
                              ? controller.lastTransaction!.description
                              : 'N/A',
                          subtitle: controller.lastTransaction != null
                              ? NumberFormat.currency(
                                  locale: 'fr_FR',
                                  symbol: 'FCFA',
                                ).format(controller.lastTransaction!.amount)
                              : '',
                        ),

                        SizedBox(height: 12.h),

                        // Top spending category
                        _SummaryItem(
                          icon: CupertinoIcons.chart_pie_fill,
                          title:
                              'Catégorie principale', // Translated from 'Top Spending'
                          value: controller.topSpendingCategory != null
                              ? controller.topSpendingCategory!.key.displayName
                              : 'N/A',
                          subtitle: controller.topSpendingCategory != null
                              ? NumberFormat.currency(
                                  locale: 'fr_FR',
                                  symbol: 'FCFA',
                                ).format(controller.topSpendingCategory!.value)
                              : '',
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, duration: 300.ms);
  }
}

/// Summary item widget
class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 18.sp, color: Colors.white),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: KoalaTypography.caption(context)
                    .copyWith(color: Colors.white60),
              ),
              Text(
                value,
                style: KoalaTypography.bodyLarge(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: KoalaTypography.caption(context)
                      .copyWith(color: Colors.white70),
                ),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideX(begin: -0.2, end: 0, duration: 400.ms, delay: 200.ms);
  }
}
