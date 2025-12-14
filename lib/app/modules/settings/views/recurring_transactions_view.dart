// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';
import 'package:koaa/app/modules/settings/widgets/add_recurring_transaction_dialog.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

class RecurringTransactionsView
    extends GetView<RecurringTransactionsController> {
  const RecurringTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      appBar: AppBar(
        backgroundColor: KoalaColors.background(context),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: KoalaColors.text(context)),
          onPressed: () => NavigationHelper.safeBack(),
          tooltip: 'Retour',
        ),
        title: Text(
          'Transactions récurrentes',
          style: KoalaTypography.heading3(context),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => controller.recurringTransactions.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  key: const PageStorageKey('recurring_transactions_list'),
                  padding: EdgeInsets.all(KoalaSpacing.xl),
                  itemCount: controller.recurringTransactions.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: KoalaSpacing.md),
                  itemBuilder: (context, index) {
                    final transaction = controller.recurringTransactions[index];
                    return _TransactionListItem(
                      key: ValueKey(transaction.id),
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
        backgroundColor: KoalaColors.primaryUi(context),
        elevation: 4,
        tooltip: 'Ajouter une transaction récurrente',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return KoalaEmptyState(
      title: 'Aucune récurrence',
      message:
          'Ajoutez vos abonnements et factures récurrentes pour un meilleur suivi',
      icon: CupertinoIcons.repeat,
      buttonText: 'Ajouter une transaction',
      onButtonPressed: () {
        HapticFeedback.lightImpact();
        showAddRecurringTransactionDialog(context);
      },
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final RecurringTransaction transaction;

  const _TransactionListItem({super.key, required this.transaction});

  String _getNextPaymentDate() {
    final now = DateTime.now();

    if (transaction.frequency == Frequency.monthly) {
      try {
        DateTime nextDate =
            DateTime(now.year, now.month, transaction.dayOfMonth);

        if (nextDate.isBefore(now)) {
          final nextMonth = now.month == 12 ? 1 : now.month + 1;
          final nextYear = now.month == 12 ? now.year + 1 : now.year;
          final lastDayOfMonth = DateTime(nextYear, nextMonth + 1, 0).day;
          final validDay = transaction.dayOfMonth > lastDayOfMonth
              ? lastDayOfMonth
              : transaction.dayOfMonth;

          nextDate = DateTime(nextYear, nextMonth, validDay);
        }

        return 'Prochain : ${DateFormat('dd MMM', 'fr_FR').format(nextDate)}';
      } catch (e) {
        return 'Mensuel';
      }
    } else if (transaction.frequency == Frequency.weekly) {
      return 'Hebdomadaire';
    } else {
      return 'Quotidien';
    }
  }

  @override
  Widget build(BuildContext context) {
    CategoriesController? categoriesController;
    try {
      categoriesController = Get.find<CategoriesController>();
    } catch (e) {
      // Ignore
    }

    String amountPrefix = '';
    Color amountColor;
    String iconKey = 'other';
    Color iconColor = Colors.grey;

    if (transaction.type == TransactionType.expense) {
      amountPrefix = '-';
      amountColor = KoalaColors.destructive; // Standardized
      iconColor = KoalaColors.destructive;
    } else {
      amountPrefix = '+';
      amountColor = KoalaColors.success; // Standardized
      iconColor = KoalaColors.success;
    }

    if (transaction.categoryId != null && categoriesController != null) {
      try {
        final cat = categoriesController.categories.firstWhereOrNull(
          (c) => c.id == transaction.categoryId,
        );
        if (cat != null) {
          iconKey = cat.icon;
          iconColor = Color(cat.colorValue);
        }
      } catch (e) {
        // Ignore
      }
    } else {
      iconKey = transaction.category.iconKey;
    }

    final typeText =
        transaction.type == TransactionType.expense ? 'Dépense' : 'Revenu';
    final semanticLabel =
        '$typeText récurrente: ${transaction.description}, ${amountPrefix}${NumberFormat('#,###', 'fr_FR').format(transaction.amount)} FCFA, ${_getNextPaymentDate()}';

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(KoalaRadius.md),
          boxShadow: KoalaColors.shadowSubtle, // Standardized
          border: Border.all(color: KoalaColors.border(context)),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(KoalaRadius.md),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              showAddRecurringTransactionDialog(context,
                  transaction: transaction);
            },
            borderRadius: BorderRadius.circular(KoalaRadius.md),
            child: Padding(
              padding: EdgeInsets.all(KoalaSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KoalaRadius.sm),
                    ),
                    child: Center(
                      child: CategoryIcon(
                        iconKey: iconKey,
                        size: 24.sp,
                        color: iconColor,
                      ),
                    ),
                  ),
                  SizedBox(width: KoalaSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.description,
                          style: KoalaTypography.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: KoalaSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.calendar,
                              size: 12.sp,
                              color: KoalaColors.textSecondary(context),
                            ),
                            SizedBox(width: KoalaSpacing.xs),
                            Text(
                              _getNextPaymentDate(),
                              style: KoalaTypography.caption(context).copyWith(
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
                        style: KoalaTypography.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                      SizedBox(height: KoalaSpacing.xs),
                      Text(
                        'FCFA',
                        style: KoalaTypography.caption(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


