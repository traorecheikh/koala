import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';
import 'package:koaa/app/modules/settings/widgets/add_recurring_transaction_dialog.dart';

class RecurringTransactionsView extends GetView<RecurringTransactionsController> {
  const RecurringTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.recurringTransactions.length,
          itemBuilder: (context, index) {
            final transaction = controller.recurringTransactions[index];
            return ListTile(
              title: Text(transaction.description),
              subtitle: Text('${transaction.amount} - ${transaction.frequency}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => controller.deleteRecurringTransaction(index),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddRecurringTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
