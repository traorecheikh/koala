// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/challenge.dart';
import 'package:koaa/app/data/models/badge_assets.dart';
import 'package:koaa/app/modules/challenges/controllers/challenges_controller.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

class ChallengesView extends GetView<ChallengesController> {
  const ChallengesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              sliver: SliverToBoxAdapter(
                child: _Header(onBadgesTap: () {}), // No tap needed now
              ),
            ),

            // Hero Stats Card
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverToBoxAdapter(
                child: Obx(() => _HeroStatsCard(
                      streak: controller.currentStreak.value,
                      points: controller.totalPoints.value,
                      completed: controller.completedChallenges
                          .length, // Show all completed challenges
                    )),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 32.h)),

            // BADGES SECTION (Main focus now)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'MA COLLECTION'),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: Obx(() {
                if (controller.earnedBadges.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: KoalaColors.surface(context),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/achievements/trophy_gold.png',
                            width: 64.sp,
                            height: 64.sp,
                            opacity: const AlwaysStoppedAnimation(0.3),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Aucun badge pour l\'instant',
                            style: KoalaTypography.bodyMedium(context).copyWith(
                              color: KoalaColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final badge = controller.earnedBadges[index];
                      // Simple resolution of asset
                      // Use a safe default or helper from controller
                      final assetPath = BadgeAssets.getAssetPath(badge.badgeId);

                      return _EarnedBadgeCard(
                        badgeId: badge.badgeId,
                        assetPath: assetPath,
                        delay: index * 50,
                      );
                    },
                    childCount: controller.earnedBadges.length,
                  ),
                );
              }),
            ),

            // COMPLETED CHALLENGES (New Section)
            if (controller.completedChallenges.isNotEmpty) ...[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(title: 'SUCCÈS TERMINÉS'),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Show newest first
                      final challengeData = controller
                          .completedChallenges.reversed
                          .toList()[index];
                      final challenge = controller
                          .getChallengeById(challengeData.challengeId);
                      if (challenge == null) return const SizedBox.shrink();

                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _CompletedAchievementCard(
                          challenge: challenge,
                          completedAt: challengeData.completedAt,
                        ),
                      );
                    },
                    childCount: controller.completedChallenges.length,
                  ),
                ),
              ),
            ],

            // NEXT MILESTONES (Replaces active challenges)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'PROCHAINS SUCCÈS'),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

            // List of locked achievements (OneTime & Streak only)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Filter available challenges for OneTime/Streak
                    final challenges = controller.allChallenges
                        .where((c) =>
                            (c.type == ChallengeType.oneTime ||
                                c.type == ChallengeType.streak) &&
                            !controller.completedChallenges
                                .any((uc) => uc.challengeId == c.id))
                        .toList();

                    if (index >= challenges.length) return null;

                    final challenge = challenges[index];
                    // Pseudo-progress (0 for locked usually, unless we calc it)
                    // Ideally AchievementsService exposes progress for locked items
                    // For now, show 0 progress or create a "Locked" card style

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _LockedAchievementCard(challenge: challenge),
                    );
                  },
                  // Just show top 5 nearest? Or all? Let's show all
                  // childCount logic handled by return null check above, but safer to supply count
                  childCount: controller.allChallenges
                      .where((c) =>
                          (c.type == ChallengeType.oneTime ||
                              c.type == ChallengeType.streak) &&
                          !controller.completedChallenges
                              .any((uc) => uc.challengeId == c.id))
                      .length,
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onBadgesTap;
  const _Header({required this.onBadgesTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => NavigationHelper.safeBack(),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: KoalaColors.surface(context),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: KoalaShadows.xs,
              ),
              child: Icon(CupertinoIcons.back,
                  size: 20.sp, color: KoalaColors.text(context)),
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          const Spacer(),
          Text('Défis', style: KoalaTypography.heading3(context))
              .animate()
              .fadeIn(),
          const Spacer(),
          GestureDetector(
            onTap: onBadgesTap,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFFD700), const Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/achievements/crown.png',
                width: 20.sp,
                height: 20.sp,
              ),
            ),
          ).animate().fadeIn().slideX(begin: 0.1),
        ],
      ),
    );
  }
}

class _HeroStatsCard extends StatelessWidget {
  final int streak;
  final int points;
  final int completed;

  const _HeroStatsCard(
      {required this.streak, required this.points, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KoalaColors.primary,
            KoalaColors.primary.withBlue(180),
          ],
        ),
        borderRadius: BorderRadius.circular(KoalaRadius.xl),
        boxShadow: [
          BoxShadow(
            color: KoalaColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeroStatItem(
                asset: 'assets/achievements/fire_7day.png',
                value: '$streak',
                label: 'Série',
              ),
              Container(
                width: 1,
                height: 50.h,
                color: Colors.white24,
              ),
              _HeroStatItem(
                asset: 'assets/achievements/gold.png',
                value: '$points',
                label: 'Points',
              ),
              Container(
                width: 1,
                height: 50.h,
                color: Colors.white24,
              ),
              _HeroStatItem(
                asset: 'assets/achievements/trophy_gold.png',
                value: '$completed',
                label: 'Terminés',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

class _HeroStatItem extends StatelessWidget {
  final String asset;
  final String value;
  final String label;

  const _HeroStatItem(
      {required this.asset, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(asset, width: 32.sp, height: 32.sp),
        SizedBox(height: 10.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: KoalaTypography.caption(context).copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: KoalaColors.textSecondary(context),
      ),
    );
  }
}

class _LockedAchievementCard extends StatelessWidget {
  final Challenge challenge;

  const _LockedAchievementCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.lg),
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Row(
        children: [
          // Grayscale/Opacified Icon
          Opacity(
            opacity: 0.5,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: KoalaColors.background(context),
                borderRadius: BorderRadius.circular(KoalaRadius.md),
              ),
              child: Image.asset(
                _getChallengeAsset(challenge.type),
                width: 24.sp,
                height: 24.sp,
                color: KoalaColors.textSecondary(context),
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: KoalaTypography.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: KoalaColors.text(context).withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Bloqué • +${challenge.rewardPoints} pts',
                  style: KoalaTypography.caption(context).copyWith(
                    color: KoalaColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Icon(CupertinoIcons.lock_fill,
              color: KoalaColors.textSecondary(context).withValues(alpha: 0.3),
              size: 20.sp),
        ],
      ),
    );
  }

  String _getChallengeAsset(ChallengeType type) {
    switch (type) {
      case ChallengeType.spending:
        return 'assets/achievements/snowflake.png';
      case ChallengeType.saving:
        return 'assets/achievements/money_bag_small.png';
      case ChallengeType.budget:
        return 'assets/achievements/bullseye.png';
      case ChallengeType.streak:
        return 'assets/achievements/fire_7day.png';
      case ChallengeType.oneTime:
        return 'assets/achievements/trophy_bronze.png';
    }
  }
}

class _EarnedBadgeCard extends StatelessWidget {
  final String badgeId;
  final String? assetPath;
  final int delay;

  const _EarnedBadgeCard({
    required this.badgeId,
    required this.assetPath,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.lg),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset(assetPath ?? 'assets/achievements/gold.png',
            width: 44.sp, height: 44.sp),
        SizedBox(height: 8.h),
        Text(
          _formatBadgeName(badgeId),
          style: KoalaTypography.caption(context).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        )
      ]),
    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.9, 0.9));
  }

  String _formatBadgeName(String badgeId) {
    return badgeId
        .replaceFirst('badge_', '')
        .split('_')
        .map(
            (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}

class _CompletedAchievementCard extends StatelessWidget {
  final Challenge challenge;
  final DateTime? completedAt;

  const _CompletedAchievementCard({
    required this.challenge,
    this.completedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.lg),
        border: Border.all(
          color:
              KoalaColors.success.withValues(alpha: 0.2), // Subtle green border
        ),
        boxShadow: KoalaShadows.xs,
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: KoalaColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(KoalaRadius.md),
            ),
            child: Image.asset(
              _getChallengeAsset(challenge.type),
              width: 24.sp,
              height: 24.sp,
              color: KoalaColors.success,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: KoalaTypography.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (completedAt != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Complété le ${_formatDate(completedAt!)}', // Helper needed or inline
                    style: KoalaTypography.caption(context).copyWith(
                      color: KoalaColors.success,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: KoalaColors.success,
              borderRadius: BorderRadius.circular(KoalaRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.checkmark_alt,
                    color: Colors.white, size: 12.sp),
                SizedBox(width: 4.w),
                Text(
                  '+${challenge.rewardPoints}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getChallengeAsset(ChallengeType type) {
    switch (type) {
      case ChallengeType.spending:
        return 'assets/achievements/snowflake.png';
      case ChallengeType.saving:
        return 'assets/achievements/money_bag_small.png';
      case ChallengeType.budget:
        return 'assets/achievements/bullseye.png';
      case ChallengeType.streak:
        return 'assets/achievements/fire_7day.png';
      case ChallengeType.oneTime:
        return 'assets/achievements/trophy_bronze.png';
    }
  }
}
