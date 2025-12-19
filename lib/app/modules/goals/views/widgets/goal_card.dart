import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/design_system.dart';

class GoalCard extends StatelessWidget {
  final FinancialGoal goal;

  const GoalCard({
    super.key,
    required this.goal,
  });

  String _formatAmount(double amount) {
    return NumberFormat('#,###', 'fr_FR').format(amount.round());
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(goal.colorValue ?? KoalaColors.primary.toARGB32());

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.lg), // 16->20 per plan
        boxShadow: KoalaShadows.sm,
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(KoalaRadius.xs),
                ),
                child: Icon(
                  IconHelper.getGoalIconByIndex(goal.iconKey),
                  color: color,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  goal.title,
                  style: KoalaTypography.heading4(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: KoalaColors.textSecondary(context),
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            goal.description ?? 'Aucune description',
            style: KoalaTypography.bodySmall(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression',
                style: KoalaTypography.caption(context)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                '${goal.progressPercentage.toStringAsFixed(1)}%',
                style: KoalaTypography.bodyMedium(context)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: (goal.progressPercentage / 100).clamp(0.0, 1.0),
              backgroundColor: KoalaColors.background(context),
              color: color,
              minHeight: 8.h,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatAmount(goal.currentAmount)} F / ${_formatAmount(goal.targetAmount)} F',
                style: KoalaTypography.caption(context),
              ),
              if (goal.targetDate != null)
                Flexible(
                  child: Text(
                    'Cible: ${DateFormat('dd/MM/yyyy').format(goal.targetDate!)}',
                    overflow: TextOverflow.ellipsis,
                    style: KoalaTypography.caption(context),
                  ),
                ),
            ],
          ),
          if (goal.status == GoalStatus.completed) ...[
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: KoalaColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(KoalaRadius.xs),
                ),
                child: Text(
                  'Objectif Atteint 🎉',
                  style: KoalaTypography.bodySmall(context).copyWith(
                    color: KoalaColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
