// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:ui'; // For ImageFilter

import 'package:countup/countup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/data/models/local_transaction.dart'; // Re-added import
import 'package:koaa/app/modules/home/controllers/home_controller.dart';
import 'package:koaa/app/modules/settings/controllers/settings_controller.dart'; // For BalanceCardStyle

/// Enhanced balance card with flip animation, time-of-day effects, and summary view
/// Now supports Theming and Preview Mode!
class EnhancedBalanceCard extends GetView<HomeController> {
  final BalanceCardStyle? style;
  final Color? themeColor;
  final String? heroAsset;
  final bool isPreview;

  const EnhancedBalanceCard({
    super.key,
    this.style, // If null, uses SettingsController.currentCardStyle
    this.themeColor,
    this.heroAsset,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    // If specific parameters are not provided, we might want to listen to SettingsController?
    // However, for the main Home view, we want it to be reactive to global settings.
    // For the carousel (isPreview), we pass specific values.

    return Obx(() {
      // Resolve effective style parameters
      final settings = Get.find<SettingsController>();
      final effectiveStyle = style ??
          (isPreview
              ? BalanceCardStyle.classic
              : settings.currentCardStyle.value);

      // Resolve Theme Color: override -> settings -> fallback
      // For Home View, we want it to match the App Skin usually, unless Hero.
      // Resolve Hero Asset
      final effectiveHeroAsset = heroAsset ?? settings.currentHeroAsset.value;

      // Resolve Theme Color: override -> hero map -> settings -> fallback
      Color effectiveColor;
      if (themeColor != null) {
        effectiveColor = themeColor!;
      } else if (effectiveStyle == BalanceCardStyle.hero &&
          effectiveHeroAsset.isNotEmpty) {
        effectiveColor = SettingsController.heroThemes[effectiveHeroAsset] ??
            settings.activeThemeColor;
      } else {
        effectiveColor = settings.activeThemeColor;
      }

      // Handle Flip Logic
      // In preview mode, we might disable flip or handle it locally, but controller handles Global flip.
      // We will allow flip even in preview? Maybe consume tap in preview to select?
      // For now, let's allow flip.

      return GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          // In preview, we might just want to show visual.
          // allowing toggleFlip for fun.
          controller.toggleCardFlip();
        },
        child: TweenAnimationBuilder<double>(
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
                  ? _FrontCard(
                      style: effectiveStyle,
                      themeColor: effectiveColor,
                      heroAsset: effectiveHeroAsset,
                      isPreview: isPreview,
                    )
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _BackCard(
                        style: effectiveStyle,
                        themeColor: effectiveColor,
                        heroAsset: effectiveHeroAsset,
                        isPreview: isPreview,
                      ),
                    ),
            );
          },
        ),
      );
    });
  }
}

/// Front side of the card showing balance
class _FrontCard extends GetView<HomeController> {
  final BalanceCardStyle style;
  final Color themeColor;
  final String? heroAsset;
  final bool isPreview;

  const _FrontCard({
    required this.style,
    required this.themeColor,
    this.heroAsset,
    required this.isPreview,
  });

  @override
  Widget build(BuildContext context) {
    return _buildContainer(
      context,
      child: Stack(
        children: [
          // Overlay effects (Particles, etc)
          _buildEffects(),

          // Main content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: 12.h),
                _buildBalance(context),
                const Spacer(),
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(BuildContext context, {required Widget child}) {
    // 1. Classic (Gradient)
    if (style == BalanceCardStyle.classic) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        height: 215.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(KoalaRadius.xl),
          gradient: controller.getTimeOfDayGradient(),
          boxShadow: KoalaShadows.md,
        ),
        child: child,
      );
    }

    // 2. Minimalist
    if (style == BalanceCardStyle.minimal) {
      return Container(
        height: 215.h,
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: BorderRadius.circular(KoalaRadius.xl),
          boxShadow: KoalaShadows.sm,
        ),
        child: child,
      );
    }

    // 6. Mesh (Simulated with Gradient for now)
    if (style == BalanceCardStyle.mesh) {
      return Container(
        height: 215.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(KoalaRadius.xl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeColor,
              themeColor.withValues(alpha: 0.5),
              Colors.purpleAccent.withValues(alpha: 0.3), // Add some funk
              themeColor,
            ],
          ),
          boxShadow: KoalaShadows.md,
        ),
        child: child,
      );
    }

    // 7. Comic / Pop-Art
    if (style == BalanceCardStyle.comic) {
      return Container(
        height: 215.h,
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: BorderRadius.circular(KoalaRadius.lg),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Stack(
          children: [
            // Halftone Dots Overlay (Simulated)
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: _DotPainter(color: Colors.black)),
              ),
            ),
            child,
          ],
        ),
      );
    }

    // 8. Hero
    if (style == BalanceCardStyle.hero) {
      return Container(
        height: 215.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(KoalaRadius.xl),
          boxShadow: KoalaShadows.lg,
          image: heroAsset != null && heroAsset!.isNotEmpty
              ? DecorationImage(
                  image: AssetImage(heroAsset!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                )
              : null,
          color: themeColor, // Fallback
        ),
        child: child,
      );
    }

    // Default Fallback
    return Container(
      height: 215.h,
      color: themeColor,
      child: child,
    );
  }

  Widget _buildEffects() {
    if (style == BalanceCardStyle.minimal) {
      return const SizedBox.shrink(); // Clean look for these
    }

    return Stack(
      children: List.generate(5, (index) {
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Style adjustments
    Color subTextColor = Colors.white70;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        isPreview
            ? Builder(builder: (context) {
                const balanceVal = 150000.0;
                const freeVal = 120000.0;
                final hasAllocations = (balanceVal - freeVal).abs() > 0.01;
                return Text(
                  hasAllocations ? 'Disponible' : 'Votre solde',
                  style: KoalaTypography.bodyLarge(context).copyWith(
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                );
              })
            : Obx(() {
                final balanceVal = controller.balance.value;
                final freeVal = controller.freeBalance.value;
                final hasAllocations = (balanceVal - freeVal).abs() > 0.01;

                return Text(
                  hasAllocations ? 'Disponible' : 'Votre solde',
                  style: KoalaTypography.bodyLarge(context).copyWith(
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
        Row(
          children: [
            Semantics(
              label: 'Masquer ou afficher le solde',
              button: true,
              child: GestureDetector(
                onTap: () {
                  if (!isPreview) {
                    HapticFeedback.lightImpact();
                    controller.toggleBalanceVisibility();
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(12.w),
                  child: isPreview
                      ? Icon(
                          CupertinoIcons.eye_fill,
                          size: 24,
                          color: subTextColor,
                        )
                      : Obx(
                          () => Icon(
                            controller.balanceVisible.value
                                ? CupertinoIcons.eye_slash_fill
                                : CupertinoIcons.eye_fill,
                            size: 24,
                            color: subTextColor,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(width: 0.w), // Adjusted spacing due to padding
            Icon(
              CupertinoIcons.arrow_2_circlepath,
              size: 20.sp,
              color: subTextColor.withValues(alpha: 0.8),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 2000.ms),
          ],
        ),
      ],
    );
  }

  Widget _buildBalance(BuildContext context) {
    Color textColor = Colors.white;
    Color subTextColor = Colors.white70;

    return isPreview
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '150 000 FCFA', // Dummy balance
                style: KoalaTypography.heading2(context).copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 32.sp,
                ),
              ),
              Text(
                'Solde total: 180 000 FCFA',
                style: KoalaTypography.bodySmall(context).copyWith(
                  color: subTextColor,
                ),
              ),
            ],
          )
        : Obx(() {
            final isHidden = !controller.balanceVisible.value;
            final balance = controller.balance.value;
            final freeBalance = controller.freeBalance.value;
            final hasAllocations = (balance - freeBalance).abs() > 0.01;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isHidden
                    ? Text(
                        '••••••••',
                        style: KoalaTypography.heading2(context).copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 32.sp,
                        ),
                      )
                    : Countup(
                        begin: 0,
                        end: hasAllocations ? freeBalance : balance,
                        duration: const Duration(milliseconds: 1500),
                        separator: ' ',
                        style: KoalaTypography.heading2(context).copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 32.sp,
                        ),
                        suffix: ' FCFA',
                      ),
                if (hasAllocations && !isHidden)
                  Text(
                    'Solde total: ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(balance)}',
                    style: KoalaTypography.bodySmall(context).copyWith(
                      color: subTextColor,
                    ),
                  ),
              ],
            );
          });
  }

  Widget _buildFooter(BuildContext context) {
    Color textColor = Colors.white60;

    return Row(
      children: [
        Icon(
          _getTimeIcon(),
          size: 16.sp,
          color: textColor,
        ),
        SizedBox(width: 6.w),
        Text(
          _getTimeGreeting(),
          style: KoalaTypography.caption(context).copyWith(
            color: textColor,
          ),
        ),
        const Spacer(),
        // Only show "Tap to view details" if NOT in preview to avoid confusion
        if (!isPreview)
          Text(
            'Appuyez pour voir les détails',
            style: KoalaTypography.caption(context).copyWith(
              color: textColor.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
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
    if (hour >= 5 && hour < 12) return 'Bonjour';
    if (hour >= 12 && hour < 17) return 'Bon après-midi';
    if (hour >= 17 && hour < 21) return 'Bonsoir';
    return 'Bonne nuit';
  }
}

/// Back side of the card showing summary
class _BackCard extends GetView<HomeController> {
  final BalanceCardStyle style;
  final Color themeColor;
  final String? heroAsset;
  final bool isPreview;

  const _BackCard({
    required this.style,
    required this.themeColor,
    this.heroAsset,
    required this.isPreview,
  });

  @override
  Widget build(BuildContext context) {
    // Reuse the same container styling
    // We can use a factory/helper, but for now duplicate logic for container (refactor later)
    // Actually, can we reuse FrontCard's _buildContainer?
    // It's in a different class. Let's make it standard.
    // For now, I'll copy the basic container logic needed for Back.

    // BACK side usually doesn't need particles, just the bg.
    Widget container(Widget child) {
      if (style == BalanceCardStyle.classic) {
        return Container(
          height: 215.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KoalaRadius.xl),
            gradient: controller.getTimeOfDayGradient(),
            boxShadow: KoalaShadows.md,
          ),
          child: child,
        );
      }
      // Fallback for others (Minimal, Comic, Hero, Mesh) -> just color or simple
      // Simpler back for complex styles to ensure readability
      return Container(
        height: 215.h,
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: BorderRadius.circular(KoalaRadius.xl),
          image: (style == BalanceCardStyle.hero && heroAsset != null)
              ? DecorationImage(
                  image: AssetImage(heroAsset!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.7),
                      BlendMode.darken), // Darker for back read
                )
              : null,
        ),
        child: child,
      );
    }

    Color textColor = Colors.white;

    return container(Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Résumé rapide',
                style: KoalaTypography.heading3(context).copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                CupertinoIcons.chart_bar_alt_fill,
                size: 20.sp,
                color: textColor.withValues(alpha: 0.7),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: (controller.transactions.isEmpty && !isPreview)
                ? Center(
                    child: Text(
                      'Aucune transaction pour le moment',
                      style: KoalaTypography.bodyMedium(context).copyWith(
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Last transaction
                      _SummaryItem(
                        icon: CupertinoIcons.time,
                        title: 'Dernière transaction',
                        value: isPreview
                            ? 'Achat Supermarché'
                            : (controller.lastTransaction?.description ??
                                'N/A'),
                        subtitle: isPreview
                            ? '- 15,000 FCFA'
                            : (controller.lastTransaction != null
                                ? NumberFormat.currency(
                                        locale: 'fr_FR', symbol: 'FCFA')
                                    .format(controller.lastTransaction!.amount)
                                : ''),
                        textColor: textColor,
                      ),
                      SizedBox(height: 12.h),
                      // Top spending
                      _SummaryItem(
                        icon: CupertinoIcons.chart_pie_fill,
                        title: 'Catégorie principale',
                        value: isPreview
                            ? 'Alimentation'
                            : (controller
                                    .topSpendingCategory?.key.displayName ??
                                'N/A'),
                        subtitle: isPreview
                            ? '45%'
                            : (controller.topSpendingCategory != null
                                ? NumberFormat.currency(
                                        locale: 'fr_FR', symbol: 'FCFA')
                                    .format(
                                        controller.topSpendingCategory!.value)
                                : ''),
                        textColor: textColor,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    )).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, duration: 300.ms);
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color textColor; // Text color passed from parent

  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 18.sp, color: textColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: KoalaTypography.caption(context)
                    .copyWith(color: textColor.withValues(alpha: 0.6)),
              ),
              Text(
                value,
                style: KoalaTypography.bodyLarge(context).copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: KoalaTypography.caption(context)
                      .copyWith(color: textColor.withValues(alpha: 0.7)),
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

// Custom Helpers Painters for Effects

class _DotPainter extends CustomPainter {
  final Color color;
  _DotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 15.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
