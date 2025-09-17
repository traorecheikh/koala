import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koala/app/modules/transactions/controllers/transactions_controller.dart';

/// Modern transactions view with enhanced UX
/// - Better filtering and search
/// - Improved transaction cards
/// - Floating action button for quick add
/// - Pull-to-refresh functionality
class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showSearchDialog(context),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () => _showFilterOptions(context),
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // TODO: Implement refresh functionality
                await Future.delayed(const Duration(seconds: 1));
              },
              child: _buildTransactionsList(context),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.showAddTransactionSheet(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: [
              _buildFilterChip(context, 'Tous', 'All', theme),
              SizedBox(width: 8.w),
              _buildFilterChip(context, 'Revenus', 'Income', theme),
              SizedBox(width: 8.w),
              _buildFilterChip(context, 'Dépenses', 'Expense', theme),
              SizedBox(width: 8.w),
              _buildFilterChip(context, 'Transferts', 'Transfer', theme),
              SizedBox(width: 8.w),
              _buildFilterChip(context, 'Prêts', 'Loan', theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String value, ThemeData theme) {
    final isSelected = controller.selectedFilter.value == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) => controller.applyFilter(value),
      backgroundColor: theme.colorScheme.surfaceVariant,
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: theme.colorScheme.onPrimary,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    return Obx(() {
      if (controller.filteredTransactions.isEmpty) {
        return _buildEmptyState(context);
      }
      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: controller.filteredTransactions.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final transaction = controller.filteredTransactions[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: _buildModernTransactionItem(context, transaction),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeIn(
            child: Icon(
              Icons.receipt_long_outlined,
              size: 64.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 16.h),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Aucune transaction trouvée',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Ajoutez votre première transaction\nen appuyant sur le bouton +',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTransactionItem(BuildContext context, Map<String, dynamic> transaction) {
    final theme = Theme.of(context);
    final type = transaction['type'] as String;
    final amount = transaction['amount'] as double;
    final isIncome = amount > 0;
    
    Color getTypeColor() {
      switch (type) {
        case 'income':
          return theme.colorScheme.primary;
        case 'expense':
          return theme.colorScheme.error;
        case 'transfer':
          return theme.colorScheme.secondary;
        case 'loan':
        case 'repayment':
          return theme.colorScheme.tertiary;
        default:
          return theme.colorScheme.onSurface;
      }
    }

    String getTypeLabel() {
      switch (type) {
        case 'income':
          return 'Revenu';
        case 'expense':
          return 'Dépense';
        case 'transfer':
          return 'Transfert';
        case 'loan':
          return 'Prêt';
        case 'repayment':
          return 'Remboursement';
        default:
          return type;
      }
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: getTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              transaction['icon'] as IconData,
              color: getTypeColor(),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: getTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        getTypeLabel(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: getTypeColor(),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      transaction['category'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  transaction['time'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : ''}${amount.toStringAsFixed(0)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: getTypeColor(),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'XOF',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Show search dialog
  void _showSearchDialog(BuildContext context) {
    // TODO: Implement search functionality
    Get.snackbar(
      'À venir',
      'La fonctionnalité de recherche sera bientôt disponible',
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      colorText: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  /// Show filter options
  void _showFilterOptions(BuildContext context) {
    // TODO: Implement advanced filtering
    Get.snackbar(
      'À venir',
      'Les options de filtrage avancées seront bientôt disponibles',
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      colorText: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}
