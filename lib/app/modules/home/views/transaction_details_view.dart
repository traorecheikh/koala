import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    final color = isExpense ? Colors.orange.shade700 : Colors.green.shade700;
    final bgColor = isExpense ? Colors.orange.shade50 : Colors.green.shade50;
    final sign = isExpense ? '-' : '+';

    final categoriesController = Get.find<CategoriesController>();
    String categoryIconKey = 'other';
    String categoryName = 'Autre';
    Color iconColor = color;

    if (transaction.categoryId != null) {
      final cat = categoriesController.categories
          .firstWhereOrNull((c) => c.id == transaction.categoryId);
      if (cat != null) {
        categoryIconKey = cat.icon;
        categoryName = cat.name;
        iconColor = Color(cat.colorValue);
      }
    } else if (transaction.category != null) {
      categoryIconKey = transaction.category!.iconKey;
      categoryName = transaction.category!.displayName;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark, color: Colors.black),
          onPressed: () => NavigationHelper.safeBack(),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.pencil, color: Colors.black),
            onPressed: () {
              // Show edit coming soon message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'Modification des transactions bientôt disponible'),
                  backgroundColor: Colors.blue,
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
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              transaction.description,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 40.h),

            // Details Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Date',
                    value: DateFormat('dd MMMM yyyy', 'fr_FR')
                        .format(transaction.date),
                    icon: CupertinoIcons.calendar,
                  ),
                  Divider(height: 32.h, color: Colors.grey.shade300),
                  _DetailRow(
                    label: 'Heure',
                    value: DateFormat('HH:mm').format(transaction.date),
                    icon: CupertinoIcons.time,
                  ),
                  Divider(height: 32.h, color: Colors.grey.shade300),
                  _DetailRow(
                    label: 'Catégorie',
                    value: categoryName,
                    icon: CupertinoIcons.tag,
                  ),
                  Divider(height: 32.h, color: Colors.grey.shade300),
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
        Icon(icon, size: 20.sp, color: Colors.grey.shade400),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: valueColor ?? Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}


