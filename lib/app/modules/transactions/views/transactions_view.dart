import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koala/app/modules/transactions/controllers/transactions_controller.dart';

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          _buildFilterSection(context),
          Expanded(child: _buildTransactionsList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showAddTransactionSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: controller.selectedFilter.value == 'All',
              onSelected: (selected) => controller.applyFilter('All'),
            ),
            FilterChip(
              label: const Text('Income'),
              selected: controller.selectedFilter.value == 'Income',
              onSelected: (selected) => controller.applyFilter('Income'),
            ),
            FilterChip(
              label: const Text('Expense'),
              selected: controller.selectedFilter.value == 'Expense',
              onSelected: (selected) => controller.applyFilter('Expense'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    return Obx(() {
      if (controller.filteredTransactions.isEmpty) {
        return const Center(child: Text('No transactions found.'));
      }
      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.filteredTransactions.length,
        separatorBuilder: (context, index) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final transaction = controller.filteredTransactions[index];
          return _buildTransactionItem(context, transaction);
        },
      );
    });
  }

  Widget _buildTransactionItem(BuildContext context, Map<String, dynamic> transaction) {
    final theme = Theme.of(context);
    final isIncome = transaction['type'] == 'income';
    final color = isIncome ? Colors.green : theme.colorScheme.error;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(transaction['icon'] as IconData, color: color),
        ),
        title: Text(transaction['title'] as String, style: theme.textTheme.titleMedium),
        subtitle: Text(transaction['category'] as String, style: theme.textTheme.bodySmall),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${transaction['amount']}',
              style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            Text(transaction['time'] as String, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
