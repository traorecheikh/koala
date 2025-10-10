import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';
import 'package:koaa/app/modules/settings/widgets/add_recurring_transaction_dialog.dart';

class RecurringTransactionsView
    extends GetView<RecurringTransactionsController> {
  const RecurringTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: Obx(
                () =>
                    ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          itemCount: controller.recurringTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction =
                                controller.recurringTransactions[index];
                            return _TransactionListItem(
                              transaction: transaction,
                              index: index,
                            );
                          },
                        )
                        .animate()
                        .slideY(
                          begin: 0.2,
                          duration: 400.ms,
                          curve: Curves.easeOutQuart,
                        )
                        .fadeIn(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddRecurringTransactionDialog(context),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(CupertinoIcons.back, size: 28),
            onPressed: () => Get.back(),
            splashRadius: 24,
          ),
          Text('Recurring Transactions', style: theme.textTheme.titleLarge),
          const SizedBox(width: 48), // For spacing
        ],
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final RecurringTransaction transaction;
  final int index;

  const _TransactionListItem({required this.transaction, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<RecurringTransactionsController>();

    return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          leading: CircleAvatar(
            radius: 25.r,
            backgroundColor: theme.colorScheme.secondary.withAlpha(25),
            child: Icon(
              CupertinoIcons.refresh_bold,
              color: theme.colorScheme.secondary,
              size: 24.sp,
            ),
          ),
          title: Text(
            transaction.description,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            '${transaction.amount} FCFA - Every ${transaction.frequency}',
            style: theme.textTheme.bodySmall,
          ),
          trailing: IconButton(
            icon: Icon(
              CupertinoIcons.delete,
              color: theme.colorScheme.error,
              size: 24.sp,
            ),
            onPressed: () => controller.deleteRecurringTransaction(index),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideX(begin: -0.2, curve: Curves.easeOutQuart);
  }
}
