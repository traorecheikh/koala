// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:koala/app/core/theme/app_colors.dart';
import 'package:koala/app/core/theme/app_dimensions.dart';
import 'package:koala/app/core/theme/app_text_styles.dart';

class HeroBalanceCard extends StatelessWidget {
  final double currentBalance;
  final String currency;
  final VoidCallback? onTap;

  const HeroBalanceCard({
    super.key,
    required this.currentBalance,
    this.currency = 'XOF',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: AppElevation.level2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solde actuel',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
              Icon(
                Icons.visibility_outlined,
                color: AppColors.white.withValues(alpha: 0.8),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            '${currentBalance.toStringAsFixed(0)} $currency',
            style: AppTextStyles.h1.copyWith(
              color: AppColors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              'Mis à jour maintenant',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
