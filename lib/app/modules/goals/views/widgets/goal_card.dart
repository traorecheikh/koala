import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:intl/intl.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Color(goal.colorValue ?? Colors.blue.value).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  IconHelper.getGoalIconByIndex(goal.iconKey),
                  color: Color(goal.colorValue ?? Colors.blue.value),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Show options (Edit/Delete) - This needs a callback or controller access
                  // For now, let's assume the parent handles the tap on the card for details
                  // But if we want specific actions here:
                  // Get.find<GoalsController>().showGoalOptions(goal);
                },
                child: Icon(
                  CupertinoIcons.ellipsis,
                  color: isDark ? Colors.white70 : Colors.grey.shade400,
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            goal.description ?? 'Aucune description',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
              Text(
                '${goal.progressPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: (goal.progressPercentage / 100).clamp(0.0, 1.0),
            backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            color: Color(goal.colorValue ?? Colors.blue.value),
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FCFA ${_formatAmount(goal.currentAmount)} / ${_formatAmount(goal.targetAmount)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.white60 : Colors.grey.shade500,
                ),
              ),
              if (goal.targetDate != null)
                Flexible(
                  child: Text(
                    'Date cible: ${DateFormat('dd/MM/yyyy').format(goal.targetDate!)}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white60 : Colors.grey.shade500,
                    ),
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
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Objectif Atteint 🎉',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green,
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