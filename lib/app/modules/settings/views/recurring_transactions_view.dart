import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';
import 'package:koaa/app/modules/settings/widgets/add_recurring_transaction_dialog.dart';

class RecurringTransactionsView
    extends GetView<RecurringTransactionsController> {
  const RecurringTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Transactions récurrentes',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => controller.recurringTransactions.isEmpty
              ? _buildEmptyState(theme)
              : ListView.separated(
                    padding: EdgeInsets.all(20.w),
                    itemCount: controller.recurringTransactions.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final transaction =
                          controller.recurringTransactions[index];
                      return _TransactionListItem(
                        transaction: transaction,
                      );
                    },
                  )
                  .animate()
                  .slideY(
                    begin: 0.1,
                    duration: 400.ms,
                    curve: Curves.easeOutQuart,
                  )
                  .fadeIn(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          showAddRecurringTransactionDialog(context);
        },
        backgroundColor: Colors.black,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.repeat,
              size: 48.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Aucune récurrence',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Vos abonnements et factures apparaîtront ici',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final RecurringTransaction transaction;

  const _TransactionListItem({required this.transaction});

  String _getNextPaymentDate() {
    final now = DateTime.now();
    DateTime nextDate;
    
    if (transaction.frequency == Frequency.monthly) {
       nextDate = DateTime(now.year, now.month, transaction.dayOfMonth);
       if (nextDate.isBefore(now)) {
         nextDate = DateTime(now.year, now.month + 1, transaction.dayOfMonth);
       }
       return 'Prochain : ${DateFormat('dd MMM', 'fr_FR').format(nextDate)}';
    } else if (transaction.frequency == Frequency.weekly) {
      // Simplified weekly logic
      return 'Hebdomadaire';
    } else {
      return 'Quotidien';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesController = Get.find<CategoriesController>();
    
    String amountPrefix = '';
    Color amountColor = Colors.black;
    String iconKey = 'other';
    Color iconColor = Colors.grey;

    try {
      if (transaction.type == TransactionType.expense) {
        amountPrefix = '-';
        amountColor = Colors.orange.shade800;
        iconColor = Colors.orange;
      } else {
        amountPrefix = '+';
        amountColor = Colors.green.shade700;
        iconColor = Colors.green;
      }

      if (transaction.categoryId != null) {
        final cat = categoriesController.categories.firstWhereOrNull((c) => c.id == transaction.categoryId);
        if (cat != null) {
          iconKey = cat.icon;
          iconColor = Color(cat.colorValue);
        }
      } else {
         iconKey = transaction.category.iconKey;
      }
    } catch (e) {
      // Fallback
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            showAddRecurringTransactionDialog(context, transaction: transaction);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: CategoryIcon(
                      iconKey: iconKey,
                      size: 24.sp,
                      color: iconColor,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            size: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _getNextPaymentDate(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$amountPrefix${NumberFormat('#,###', 'fr_FR').format(transaction.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: amountColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'FCFA',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
