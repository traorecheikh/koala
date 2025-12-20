import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:intl/intl.dart';

class SpendingHeatmap extends StatelessWidget {
  final Map<int, double> dailySpending;
  final int daysInMonth;

  const SpendingHeatmap({
    super.key,
    required this.dailySpending,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    // calculate max spend for intensity
    double maxSpend = 0;
    if (dailySpending.isNotEmpty) {
      // Find max value safely
      for (final value in dailySpending.values) {
        if (value > maxSpend) maxSpend = value;
      }
    }

    // Safety check
    if (maxSpend == 0) maxSpend = 1;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.xl),
        boxShadow: KoalaColors.shadowSubtle,
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_on_rounded,
                  size: 20.sp, color: KoalaColors.textSecondary(context)),
              SizedBox(width: 8.w),
              Text(
                'Intensité Dépenses',
                style: KoalaTypography.heading4(context),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 days a week
              mainAxisSpacing: 6.w,
              crossAxisSpacing: 6.w,
              childAspectRatio: 1,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final amount = dailySpending[day] ?? 0.0;
              final intensity = (amount / maxSpend).clamp(0.0, 1.0);

              Color cellColor;
              Color textColor;

              if (amount == 0) {
                cellColor = Colors.transparent;
                textColor = KoalaColors.textSecondary(context).withOpacity(0.5);
              } else {
                // Use shades of red/orange based on intensity
                // Low: Orange, High: Red
                if (intensity < 0.5) {
                  cellColor = Colors.orange.withOpacity(0.3 + intensity);
                } else {
                  cellColor = KoalaColors.destructive
                      .withOpacity(0.5 + (intensity * 0.5));
                }
                textColor = Colors.white;
              }

              return Tooltip(
                message: 'Jour $day: ${_formatAmount(amount)}',
                child: Container(
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: amount == 0
                        ? Border.all(
                            color: KoalaColors.border(context).withOpacity(0.5))
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: KoalaTypography.caption(context).copyWith(
                        color: textColor,
                        fontWeight:
                            amount > 0 ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Moins', style: KoalaTypography.caption(context)),
              SizedBox(width: 4.w),
              _legendBox(context, Colors.transparent, border: true),
              SizedBox(width: 2.w),
              _legendBox(context, Colors.orange.withOpacity(0.4)),
              SizedBox(width: 2.w),
              _legendBox(context, KoalaColors.destructive.withOpacity(0.8)),
              SizedBox(width: 4.w),
              Text('Plus', style: KoalaTypography.caption(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendBox(BuildContext context, Color color, {bool border = false}) {
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.r),
        border: border
            ? Border.all(color: KoalaColors.border(context).withOpacity(0.5))
            : null,
      ),
    );
  }

  String _formatAmount(double amount) {
    return NumberFormat.compact(locale: 'fr_FR').format(amount);
  }
}
