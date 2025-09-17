import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/core/theme/app_colors.dart';
import 'package:koala/app/core/theme/app_text_styles.dart';
import 'package:koala/app/modules/transactions/controllers/transaction_controller.dart';
import 'package:koala/app/shared/widgets/transaction_card.dart';

/// High-fidelity transaction list view with search and filters
class TransactionView extends GetView<TransactionController> {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchAndFilters(),
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : controller.filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : _buildTransactionList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Custom app bar with back navigation and actions
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Retour',
          ),
          Expanded(child: Text('Transactions', style: AppTextStyles.h2)),
          IconButton(
            onPressed: controller.toggleFilterPanel,
            icon: Obx(
              () => Icon(
                controller.isFilterPanelOpen.value
                    ? Icons.filter_list
                    : Icons.filter_list_outlined,
                color: controller.hasActiveFilters
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            tooltip: 'Filtres',
          ),
          IconButton(
            onPressed: controller.navigateToAddTransaction,
            icon: const Icon(Icons.add, color: AppColors.primary),
            tooltip: 'Ajouter',
          ),
        ],
      ),
    );
  }

  /// Search bar and filter controls
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          // Search TextField
          TextField(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Rechercher transactions...',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              suffixIcon: Obx(
                () => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        onPressed: controller.clearSearch,
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          // Filter Panel
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controller.isFilterPanelOpen.value ? null : 0,
              child: controller.isFilterPanelOpen.value
                  ? _buildFilterControls()
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Expandable filter controls
  Widget _buildFilterControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrer par',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          // Date Range Filter
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: 'Cette semaine',
                  isSelected: controller.selectedDateRange.value == 'week',
                  onTap: () => controller.setDateFilter('week'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'Ce mois',
                  isSelected: controller.selectedDateRange.value == 'month',
                  onTap: () => controller.setDateFilter('month'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'Tous',
                  isSelected: controller.selectedDateRange.value == 'all',
                  onTap: () => controller.setDateFilter('all'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Type Filter
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                label: 'Revenus',
                isSelected: controller.selectedType.value == 'income',
                onTap: () => controller.setTypeFilter('income'),
                color: AppColors.success,
              ),
              _buildFilterChip(
                label: 'Dépenses',
                isSelected: controller.selectedType.value == 'expense',
                onTap: () => controller.setTypeFilter('expense'),
                color: AppColors.error,
              ),
              _buildFilterChip(
                label: 'Prêts',
                isSelected: controller.selectedType.value == 'loan',
                onTap: () => controller.setTypeFilter('loan'),
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Clear Filters Button
          if (controller.hasActiveFilters)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: controller.clearAllFilters,
                child: Text(
                  'Effacer les filtres',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Individual filter chip widget
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? chipColor
                : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? chipColor : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// Transaction list with swipe actions
  Widget _buildTransactionList() {
    return RefreshIndicator(
      onRefresh: controller.refreshTransactions,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = controller.filteredTransactions[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Dismissible(
              key: Key(transaction.id),
              background: _buildSwipeBackground(isEdit: true),
              secondaryBackground: _buildSwipeBackground(isEdit: false),
              onDismissed: (direction) {
                if (direction == DismissDirection.startToEnd) {
                  controller.editTransaction(transaction);
                } else {
                  controller.deleteTransaction(transaction.id);
                }
              },
              child: TransactionCard(
                transaction: transaction,
                onTap: () => controller.viewTransactionDetails(transaction.id),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Swipe action background
  Widget _buildSwipeBackground({required bool isEdit}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: isEdit ? Alignment.centerLeft : Alignment.centerRight,
      decoration: BoxDecoration(
        color: isEdit ? AppColors.info : AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isEdit ? Icons.edit : Icons.delete,
        color: AppColors.white,
        size: 24,
      ),
    );
  }

  /// Empty state when no transactions found
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(48),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              controller.searchQuery.value.isNotEmpty ||
                      controller.hasActiveFilters
                  ? 'Aucune transaction trouvée'
                  : 'Aucune transaction',
              style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              controller.searchQuery.value.isNotEmpty ||
                      controller.hasActiveFilters
                  ? 'Essayez de modifier vos critères de recherche'
                  : 'Commencez par ajouter votre première transaction',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: controller.navigateToAddTransaction,
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Ajouter une transaction',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Floating action button for quick add
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: controller.navigateToAddTransaction,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 24),
    );
  }
}
