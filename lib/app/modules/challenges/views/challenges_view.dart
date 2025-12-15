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
                child: _Header(onBadgesTap: () => _showBadgesSheet(context)),
              ),
            ),

            // Hero Stats Card with Gradient
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverToBoxAdapter(
                child: Obx(() => _HeroStatsCard(
                      streak: controller.currentStreak.value,
                      points: controller.totalPoints.value,
                      completed: controller.completedChallenges.length,
                    )),
              ),
            ),

            // Active Challenges
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 0),
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.activeChallenges.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(title: 'DÉFIS EN COURS'),
                      SizedBox(height: 16.h),
                      ...controller.activeChallenges
                          .asMap()
                          .entries
                          .map((entry) {
                        final uc = entry.value;
                        final challenge =
                            controller.getChallengeById(uc.challengeId);
                        if (challenge == null) return const SizedBox.shrink();
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _ActiveChallengeCard(
                            challenge: challenge,
                            userChallenge: uc,
                            delay: entry.key * 100,
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ),

            // Challenge Categories
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'EXPLORER'),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

            // Premium Category Cards
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverToBoxAdapter(
                child: _PremiumCategories(
                  onCategoryTap: (type) => _showChallengesList(context, type),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ),
      ),
    );
  }

  void _showChallengesList(BuildContext context, ChallengeType type) {
    final challenges = controller.getChallengesByType(type);

    Get.bottomSheet(
      KoalaBottomSheet(
        title: _getCategoryTitle(type),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(20.w),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            final displayData = controller.getChallengeDisplayData(challenge);
            final isActive = displayData['isActive'] as bool;
            final isCompleted = displayData['isCompleted'] as bool;

            return _ChallengeListItem(
              challenge: challenge,
              isActive: isActive,
              isCompleted: isCompleted,
              onTap: isActive || isCompleted
                  ? null
                  : () => _confirmStartChallenge(context, challenge),
              delay: index * 40,
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmStartChallenge(BuildContext context, Challenge challenge) {
    NavigationHelper.safeBack();

    Get.bottomSheet(
      KoalaBottomSheet(
        title: 'Nouveau Défi',
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Challenge Preview Card
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getDifficultyColor(challenge.difficulty)
                          .withOpacity(0.15),
                      _getDifficultyColor(challenge.difficulty)
                          .withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(KoalaRadius.xl),
                  border: Border.all(
                    color: _getDifficultyColor(challenge.difficulty)
                        .withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    // Badge image for challenge
                    Image.asset(
                      _getChallengeAsset(challenge.type),
                      width: 64.sp,
                      height: 64.sp,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      challenge.title,
                      style: KoalaTypography.heading3(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      challenge.description,
                      style: KoalaTypography.bodyMedium(context).copyWith(
                        color: KoalaColors.textSecondary(context),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _InfoChip(
                          label: '+${challenge.rewardPoints} pts',
                          color: KoalaColors.primary,
                        ),
                        SizedBox(width: 12.w),
                        _InfoChip(
                          label: _getDifficultyLabel(challenge.difficulty),
                          color: _getDifficultyColor(challenge.difficulty),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),

              // Action buttons
              KoalaButton(
                text: 'Relever le Défi',
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  controller.startChallenge(challenge.id);
                  NavigationHelper.safeBack();
                  Get.snackbar(
                    'Défi lancé! 🔥',
                    challenge.title,
                    backgroundColor: KoalaColors.primary,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    margin: EdgeInsets.all(16.w),
                  );
                },
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => NavigationHelper.safeBack(),
                child: Text(
                  'Plus tard',
                  style: KoalaTypography.bodyMedium(context).copyWith(
                    color: KoalaColors.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showBadgesSheet(BuildContext context) {
    Get.bottomSheet(
      KoalaBottomSheet(
        title: 'Collection de Badges',
        child: Obx(() {
          if (controller.earnedBadges.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(40.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/achievements/trophy_gold.png',
                    width: 80.sp,
                    height: 80.sp,
                    opacity: const AlwaysStoppedAnimation(0.3),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Aucun badge pour l\'instant',
                    style: KoalaTypography.heading4(context),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Complétez des défis pour débloquer vos premiers badges!',
                    style: KoalaTypography.bodyMedium(context).copyWith(
                      color: KoalaColors.textSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.all(20.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.85,
            ),
            itemCount: controller.earnedBadges.length,
            itemBuilder: (context, index) {
              final badge = controller.earnedBadges[index];
              final assetPath = BadgeAssets.getAssetPath(badge.badgeId);

              return _EarnedBadgeCard(
                badgeId: badge.badgeId,
                assetPath: assetPath,
                delay: index * 60,
              );
            },
          );
        }),
      ),
      isScrollControlled: true,
    );
  }

  String _getCategoryTitle(ChallengeType type) {
    switch (type) {
      case ChallengeType.spending:
        return 'Défis Dépenses';
      case ChallengeType.saving:
        return 'Défis Épargne';
      case ChallengeType.budget:
        return 'Défis Budget';
      case ChallengeType.streak:
        return 'Défis Séries';
      case ChallengeType.oneTime:
        return 'Accomplissements';
    }
  }

  String _getChallengeAsset(ChallengeType type) {
    switch (type) {
      case ChallengeType.spending:
        return 'assets/achievements/snowflake.png';
      case ChallengeType.saving:
        return 'assets/achievements/money_bag_large.png';
      case ChallengeType.budget:
        return 'assets/achievements/bullseye.png';
      case ChallengeType.streak:
        return 'assets/achievements/fire_30day.png';
      case ChallengeType.oneTime:
        return 'assets/achievements/trophy_gold.png';
    }
  }

  Color _getDifficultyColor(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return const Color(0xFF34C759);
      case ChallengeDifficulty.medium:
        return const Color(0xFF007AFF);
      case ChallengeDifficulty.hard:
        return const Color(0xFFFF9500);
      case ChallengeDifficulty.legendary:
        return const Color(0xFFAF52DE);
    }
  }

  String _getDifficultyLabel(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Facile';
      case ChallengeDifficulty.medium:
        return 'Moyen';
      case ChallengeDifficulty.hard:
        return 'Difficile';
      case ChallengeDifficulty.legendary:
        return 'Légendaire';
    }
  }
}

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
                    color: const Color(0xFFFFD700).withOpacity(0.3),
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
            color: KoalaColors.primary.withOpacity(0.4),
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

class _ActiveChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final UserChallenge userChallenge;
  final int delay;

  const _ActiveChallengeCard({
    required this.challenge,
    required this.userChallenge,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        (userChallenge.currentProgress / challenge.targetValue).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.xl),
        border: Border.all(color: KoalaColors.primary.withOpacity(0.2)),
        boxShadow: KoalaShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: KoalaColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KoalaRadius.lg),
            ),
            child: Image.asset(
              _getChallengeAsset(challenge.type),
              width: 36.sp,
              height: 36.sp,
            ),
          ),
          SizedBox(width: 16.w),
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
                SizedBox(height: 6.h),
                Text(
                  '${userChallenge.currentProgress}/${challenge.targetValue} ${challenge.targetUnit}',
                  style: KoalaTypography.caption(context).copyWith(
                    color: KoalaColors.textSecondary(context),
                  ),
                ),
                SizedBox(height: 10.h),
                Stack(
                  children: [
                    Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: KoalaColors.border(context),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              KoalaColors.primary,
                              KoalaColors.primary.withBlue(180)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: KoalaColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KoalaRadius.full),
            ),
            child: Text(
              '+${challenge.rewardPoints}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: KoalaColors.primary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.03, end: 0);
  }

  String _getChallengeAsset(ChallengeType type) {
    switch (type) {
      case ChallengeType.spending:
        return 'assets/achievements/snowflake.png';
      case ChallengeType.saving:
        return 'assets/achievements/money_bag_large.png';
      case ChallengeType.budget:
        return 'assets/achievements/bullseye.png';
      case ChallengeType.streak:
        return 'assets/achievements/fire_30day.png';
      case ChallengeType.oneTime:
        return 'assets/achievements/trophy_gold.png';
    }
  }
}

class _PremiumCategories extends StatelessWidget {
  final Function(ChallengeType) onCategoryTap;

  const _PremiumCategories({required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top row - 2 larger cards
        Row(
          children: [
            Expanded(
              child: _PremiumCategoryCard(
                type: ChallengeType.spending,
                title: 'Dépenses',
                subtitle: 'Maîtrisez vos achats',
                asset: 'assets/achievements/snowflake.png',
                gradient: [const Color(0xFF00D2FF), const Color(0xFF3A7BD5)],
                onTap: () => onCategoryTap(ChallengeType.spending),
                delay: 0,
                aspectRatio: 1.2,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _PremiumCategoryCard(
                type: ChallengeType.saving,
                title: 'Épargne',
                subtitle: 'Faites fructifier',
                asset: 'assets/achievements/money_bag_large.png',
                gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                onTap: () => onCategoryTap(ChallengeType.saving),
                delay: 80,
                aspectRatio: 1.2,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Middle row - 2 cards
        Row(
          children: [
            Expanded(
              child: _PremiumCategoryCard(
                type: ChallengeType.budget,
                title: 'Budget',
                subtitle: 'Restez dans les limites',
                asset: 'assets/achievements/bullseye.png',
                gradient: [const Color(0xFFFF512F), const Color(0xFFDD2476)],
                onTap: () => onCategoryTap(ChallengeType.budget),
                delay: 160,
                aspectRatio: 1.2,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _PremiumCategoryCard(
                type: ChallengeType.streak,
                title: 'Séries',
                subtitle: 'Gardez le rythme',
                asset: 'assets/achievements/fire_100day.png',
                gradient: [const Color(0xFFF12711), const Color(0xFFF5AF19)],
                onTap: () => onCategoryTap(ChallengeType.streak),
                delay: 240,
                aspectRatio: 1.2,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Bottom row - Full width
        _PremiumCategoryCard(
          type: ChallengeType.oneTime,
          title: 'Accomplissements',
          subtitle: 'Débloquez des succès uniques',
          asset: 'assets/achievements/crown.png',
          gradient: [const Color(0xFFAA076B), const Color(0xFF61045F)],
          onTap: () => onCategoryTap(ChallengeType.oneTime),
          delay: 320,
          aspectRatio: 2.8,
          isWide: true,
        ),
      ],
    );
  }
}

class _PremiumCategoryCard extends StatelessWidget {
  final ChallengeType type;
  final String title;
  final String subtitle;
  final String asset;
  final List<Color> gradient;
  final VoidCallback onTap;
  final int delay;
  final double aspectRatio;
  final bool isWide;

  const _PremiumCategoryCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.gradient,
    required this.onTap,
    required this.delay,
    required this.aspectRatio,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(KoalaRadius.xl),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background asset with opacity
              Positioned(
                right: isWide ? 16.w : -8.w,
                bottom: isWide ? -8.h : -12.h,
                child: Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    asset,
                    width: isWide ? 60.sp : 56.sp,
                    height: isWide ? 60.sp : 56.sp,
                  ),
                ),
              ),
              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(asset, width: 32.sp, height: 32.sp),
                  SizedBox(height: 10.h),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(KoalaRadius.full),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withOpacity(0.2),
            const Color(0xFFFFA500).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(KoalaRadius.lg),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (assetPath != null)
            Image.asset(assetPath!, width: 44.sp, height: 44.sp)
          else
            Image.asset('assets/achievements/gold.png',
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
          ),
        ],
      ),
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

class _ChallengeListItem extends StatelessWidget {
  final Challenge challenge;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;
  final int delay;

  const _ChallengeListItem({
    required this.challenge,
    required this.isActive,
    required this.isCompleted,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(KoalaRadius.lg),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF34C759).withOpacity(0.3)
                : isActive
                    ? KoalaColors.primary.withOpacity(0.3)
                    : KoalaColors.border(context),
            width: isCompleted || isActive ? 2 : 1,
          ),
          boxShadow: KoalaShadows.xs,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    _getDifficultyColor(challenge.difficulty).withOpacity(0.1),
                borderRadius: BorderRadius.circular(KoalaRadius.md),
              ),
              child: Image.asset(
                _getChallengeAsset(challenge.type),
                width: 24.sp,
                height: 24.sp,
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
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        '+${challenge.rewardPoints} pts',
                        style: KoalaTypography.caption(context).copyWith(
                          color: KoalaColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: BoxDecoration(
                          color: KoalaColors.textSecondary(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        _getDifficultyLabel(challenge.difficulty),
                        style: KoalaTypography.caption(context).copyWith(
                          color: _getDifficultyColor(challenge.difficulty),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(CupertinoIcons.checkmark,
                    color: const Color(0xFF34C759), size: 16.sp),
              )
            else if (isActive)
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: KoalaColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(CupertinoIcons.hourglass,
                    color: KoalaColors.primary, size: 16.sp),
              )
            else
              Icon(CupertinoIcons.chevron_right,
                  color: KoalaColors.textSecondary(context), size: 18.sp),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.03, end: 0);
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

  Color _getDifficultyColor(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return const Color(0xFF34C759);
      case ChallengeDifficulty.medium:
        return const Color(0xFF007AFF);
      case ChallengeDifficulty.hard:
        return const Color(0xFFFF9500);
      case ChallengeDifficulty.legendary:
        return const Color(0xFFAF52DE);
    }
  }

  String _getDifficultyLabel(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Facile';
      case ChallengeDifficulty.medium:
        return 'Moyen';
      case ChallengeDifficulty.hard:
        return 'Difficile';
      case ChallengeDifficulty.legendary:
        return 'Légendaire';
    }
  }
}
