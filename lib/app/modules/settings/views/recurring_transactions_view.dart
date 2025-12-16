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
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';
import 'package:koaa/app/modules/settings/widgets/add_recurring_transaction_dialog.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/data/models/job.dart';

class RecurringTransactionsView
    extends GetView<RecurringTransactionsController> {
  const RecurringTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject FinancialContextService to access Jobs
    final financialContextService = Get.find<FinancialContextService>();

    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: KoalaColors.background(context),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: KoalaColors.text(context)),
          onPressed: () => NavigationHelper.safeBack(),
          tooltip: 'Retour',
        ),
        title: Text(
          'Revenus récurrents',
          style: KoalaTypography.heading3(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              showAddRecurringTransactionDialog(context);
            },
            icon:
                Icon(CupertinoIcons.add, color: KoalaColors.primaryUi(context)),
            tooltip: 'Ajouter',
          ),
          SizedBox(width: KoalaSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () {
            // Filter to only show income (not expenses/subscriptions)
            final incomeTransactions = controller.recurringTransactions
                .where((t) => t.type == TransactionType.income)
                .toList();

            final jobs = financialContextService.allJobs
                //.where((j) => j.isActive) // Optionally filter active only, but viewing all is fine
                .toList();

            final bool isEmpty = incomeTransactions.isEmpty && jobs.isEmpty;

            return isEmpty
                ? _buildEmptyState(context)
                : ListView(
                    key: const PageStorageKey('recurring_income_list'),
                    padding: EdgeInsets.all(KoalaSpacing.xl),
                    children: [
                      // Section: Emplois / Salaires
                      if (jobs.isNotEmpty) ...[
                        Text(
                          'Salaires & Emplois',
                          style: KoalaTypography.heading4(context).copyWith(
                            color: KoalaColors.textSecondary(context),
                          ),
                        ),
                        SizedBox(height: KoalaSpacing.sm),
                        ...jobs.map((job) => Padding(
                              padding: EdgeInsets.only(bottom: KoalaSpacing.md),
                              child:
                                  _JobListItem(key: ValueKey(job.id), job: job),
                            )),
                        SizedBox(height: KoalaSpacing.md),
                      ],

                      // Section: Autres revenus
                      if (incomeTransactions.isNotEmpty) ...[
                        if (jobs.isNotEmpty)
                          Text(
                            'Autres revenus',
                            style: KoalaTypography.heading4(context).copyWith(
                              color: KoalaColors.textSecondary(context),
                            ),
                          ),
                        if (jobs.isNotEmpty) SizedBox(height: KoalaSpacing.sm),
                        ...incomeTransactions.map((transaction) => Padding(
                              padding: EdgeInsets.only(bottom: KoalaSpacing.md),
                              child: _TransactionListItem(
                                key: ValueKey(transaction.id),
                                transaction: transaction,
                              ),
                            )),
                      ],
                    ],
                  )
                    .animate()
                    .slideY(
                      begin: 0.1,
                      duration: 400.ms,
                      curve: Curves.easeOutQuart,
                    )
                    .fadeIn();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return KoalaEmptyState(
      title: 'Aucun revenu récurrent',
      message:
          'Ajoutez vos sources de revenus récurrents (salaire, freelance, etc.)',
      icon: CupertinoIcons.arrow_2_circlepath,
      buttonText: 'Ajouter un revenu',
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
          // Fix invalid days (e.g. 31st in Feb)
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

    // Fallback if category didn't provide color/icon
    if (transaction.type == TransactionType.income && iconKey == 'other') {
      iconKey = 'salary'; // Default logical icon for income
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
                      color: iconColor.withValues(alpha: 0.1),
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
                            // Show status badge
                            if (!transaction.isCurrentlyValid) ...[
                              SizedBox(width: KoalaSpacing.sm),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: KoalaColors.textSecondary(context)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  transaction.endDate != null &&
                                          DateTime.now()
                                              .isAfter(transaction.endDate!)
                                      ? 'Terminé'
                                      : 'Inactif',
                                  style:
                                      KoalaTypography.caption(context).copyWith(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: KoalaColors.textSecondary(context),
                                  ),
                                ),
                              ),
                            ],
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

class _JobListItem extends StatelessWidget {
  final Job job;

  const _JobListItem({super.key, required this.job});

  String _getNextPaymentDate() {
    final now = DateTime.now();

    DateTime nextDate = job.paymentDate;

    // If payment date is in past, project forward based on frequency
    if (nextDate.isBefore(now)) {
      while (nextDate.isBefore(now)) {
        if (job.frequency == PaymentFrequency.monthly) {
          nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
        } else if (job.frequency == PaymentFrequency.weekly) {
          nextDate = nextDate.add(const Duration(days: 7));
        } else if (job.frequency == PaymentFrequency.biweekly) {
          nextDate = nextDate.add(const Duration(days: 14));
        }
      }
    }

    return 'Prochain : ${DateFormat('dd MMM', 'fr_FR').format(nextDate)}';
  }

  @override
  Widget build(BuildContext context) {
    // Jobs are always income
    final amountPrefix = '+';
    final amountColor = KoalaColors.success;
    final iconColor = KoalaColors.success;
    const iconKey = 'salary'; // Special icon for salary

    return Container(
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.md),
        boxShadow: KoalaColors.shadowSubtle,
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(KoalaRadius.md),
        child: InkWell(
          onTap: () {
            // Option to navigate to Job details or show snackbar
            Get.snackbar('Emploi',
                'Modifiez les détails de votre emploi via le Profil > Configuration.',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 3));
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
                    color: iconColor.withValues(alpha: 0.1),
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
                        job.name,
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
                            CupertinoIcons.briefcase, // Briefcase icon for job
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
                          if (!job.isActive) ...[
                            SizedBox(width: KoalaSpacing.sm),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: KoalaColors.textSecondary(context)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'Inactif',
                                style:
                                    KoalaTypography.caption(context).copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: KoalaColors.textSecondary(context),
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$amountPrefix${NumberFormat('#,###', 'fr_FR').format(job.amount)}',
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
    );
  }
}
