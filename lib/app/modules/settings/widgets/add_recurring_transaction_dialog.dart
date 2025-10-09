import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';

void showAddRecurringTransactionDialog(BuildContext context) {
  final controller = Get.find<RecurringTransactionsController>();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final frequency = Frequency.daily.obs;
  final selectedDays = <int>[].obs;

  Get.dialog(
    AlertDialog(
      title: const Text('Add Recurring Transaction'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            Obx(
              () => DropdownButton<Frequency>(
                value: frequency.value,
                onChanged: (newValue) {
                  if (newValue != null) {
                    frequency.value = newValue;
                  }
                },
                items: Frequency.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.toString().split('.').last)))
                    .toList(),
              ),
            ),
            Obx(() {
              if (frequency.value == Frequency.weekly) {
                return Wrap(
                  children: List.generate(7, (index) {
                    final day = index + 1;
                    return FilterChip(
                      label: Text(day.toString()),
                      selected: selectedDays.contains(day),
                      onSelected: (selected) {
                        if (selected) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                        }
                      },
                    );
                  }),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text) ?? 0.0;
            final description = descriptionController.text;
            if (amount > 0 && description.isNotEmpty) {
              final transaction = RecurringTransaction(
                amount: amount,
                description: description,
                frequency: frequency.value,
                daysOfWeek: selectedDays,
                lastGeneratedDate: DateTime.now(),
              );
              controller.addRecurringTransaction(transaction);
              Get.back();
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
