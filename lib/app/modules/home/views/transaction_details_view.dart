import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

class TransactionDetailsView extends StatelessWidget {
  final LocalTransaction transaction;

  const TransactionDetailsView({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? KoalaColors.destructive : KoalaColors.success;
    final sign = isExpense ? '-' : '+';

    final categoriesController = Get.find<CategoriesController>();
    String categoryIconKey = 'other';
    String categoryName = 'Autre';
    Color iconColor = color;

    if (transaction.categoryId != null) {
      // First try UUID match
      var cat = categoriesController.categories
          .firstWhereOrNull((c) => c.id == transaction.categoryId);

      // If not found, try matching by category name (for catch-up transactions)
      if (cat == null) {
        cat = categoriesController.categories.firstWhereOrNull((c) =>
            c.name.toLowerCase() == transaction.categoryId!.toLowerCase());
      }

      if (cat != null) {
        categoryIconKey = cat.icon;
        categoryName = cat.name;
        iconColor = Color(cat.colorValue);
      }
    }

    // Fallback to transaction.category enum if no match found
    if (categoryIconKey == 'other' && transaction.category != null) {
      categoryIconKey = transaction.category!.iconKey;
      categoryName = transaction.category!.displayName;
    }

    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: KoalaColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.xmark, color: KoalaColors.text(context)),
          onPressed: () => NavigationHelper.safeBack(),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.pencil, color: KoalaColors.text(context)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'Modification des transactions bientôt disponible'),
                  backgroundColor: KoalaColors.accent,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Icon
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CategoryIcon(
                  iconKey: categoryIconKey,
                  size: 40.sp,
                  color: iconColor,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Amount
            Text(
              '$sign${NumberFormat('#,###', 'fr_FR').format(transaction.amount)} FCFA',
              style: KoalaTypography.heading1(context).copyWith(
                fontSize: 32.sp,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              transaction.description,
              style: KoalaTypography.bodyLarge(context).copyWith(
                color: KoalaColors.textSecondary(context),
              ),
            ),
            SizedBox(height: 40.h),

            // Details Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: KoalaColors.surface(context),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: KoalaColors.border(context)),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Date',
                    value: DateFormat('dd MMMM yyyy', 'fr_FR')
                        .format(transaction.date),
                    icon: CupertinoIcons.calendar,
                  ),
                  Divider(height: 32.h, color: KoalaColors.border(context)),
                  _DetailRow(
                    label: 'Heure',
                    value: DateFormat('HH:mm').format(transaction.date),
                    icon: CupertinoIcons.time,
                  ),
                  Divider(height: 32.h, color: KoalaColors.border(context)),
                  _DetailRow(
                    label: 'Catégorie',
                    value: categoryName,
                    icon: CupertinoIcons.tag,
                  ),
                  Divider(height: 32.h, color: KoalaColors.border(context)),
                  _DetailRow(
                    label: 'Type',
                    value: isExpense ? 'Dépense' : 'Revenu',
                    icon: isExpense
                        ? CupertinoIcons.arrow_up_right
                        : CupertinoIcons.arrow_down_left,
                    valueColor: color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: KoalaColors.textSecondary(context)),
        SizedBox(width: 12.w),
        Text(
          label,
          style: KoalaTypography.bodyMedium(context).copyWith(
            color: KoalaColors.textSecondary(context),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: KoalaTypography.bodyMedium(context).copyWith(
            color: valueColor ?? KoalaColors.text(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
