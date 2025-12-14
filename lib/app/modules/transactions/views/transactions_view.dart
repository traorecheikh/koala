import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            const _SearchBar(),
            const _FilterChips(),
            const _ActiveFiltersBar(),
            Expanded(
              child: Obx(() {
                final transactions = controller.displayedTransactions;

                if (transactions.isEmpty && !controller.isLoading.value) {
                  return const _EmptyState();
                }

                return ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  itemCount:
                      transactions.length + (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == transactions.length) {
                      return const _LoadingIndicator();
                    }

                    final transaction = transactions[index];
                    return _EnhancedTransactionCard(
                      transaction: transaction,
                      index: index,
                    );
                  },
                ).animate().fadeIn(duration: 300.ms);
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingButtons(context),
    );
  }

  Widget _buildFloatingButtons(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          if (!controller.hasActiveFilters) return const SizedBox.shrink();

          return FloatingActionButton.small(
            heroTag: 'clear_filters',
            onPressed: () {
              HapticFeedback.mediumImpact();
              controller.clearFilters();
            },
            backgroundColor: theme.colorScheme.error,
            child: const Icon(CupertinoIcons.clear, color: Colors.white),
          ).animate().scale().fadeIn();
        }),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'filter',
          onPressed: () {
            HapticFeedback.lightImpact();
            _showFilterSheet(context);
          },
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(
            CupertinoIcons.slider_horizontal_3,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    Get.bottomSheet(
      const _FilterBottomSheet(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<TransactionsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(CupertinoIcons.back, size: 28),
            onPressed: () {
              HapticFeedback.lightImpact();
              NavigationHelper.safeBack();
            },
            splashRadius: 24,
          ),
          Expanded(
            child: Column(
              children: [
                Text('All Transactions', style: theme.textTheme.titleLarge),
                Obx(() {
                  final count = controller.displayedTransactions.length;
                  final total = controller.transactions.length;
                  return Text(
                    '$total transaction${total != 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(153),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _SearchBar extends GetView<TransactionsController> {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withAlpha(51)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CupertinoSearchTextField(
          controller: controller.searchController,
          placeholder: 'Search transactions...',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(),
          prefixIcon: const Icon(CupertinoIcons.search, size: 20),
          suffixIcon: const Icon(CupertinoIcons.clear_circled_solid, size: 20),
        ),
      ),
    ).animate().slideY(begin: -0.2, duration: 400.ms).fadeIn();
  }
}

class _FilterChips extends GetView<TransactionsController> {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Obx(
        () => Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: controller.currentFilter.value == FilterType.all,
              onTap: () => controller.setFilter(FilterType.all),
              icon: CupertinoIcons.square_stack_3d_up,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Income',
              isSelected: controller.currentFilter.value == FilterType.income,
              onTap: () => controller.setFilter(FilterType.income),
              icon: CupertinoIcons.arrow_down_circle,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Expense',
              isSelected: controller.currentFilter.value == FilterType.expense,
              onTap: () => controller.setFilter(FilterType.expense),
              icon: CupertinoIcons.arrow_up_circle,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    ).animate().slideX(begin: -0.1, duration: 400.ms).fadeIn();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withAlpha(25)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? chipColor
                : theme.colorScheme.outline.withAlpha(51),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? chipColor : theme.iconTheme.color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? chipColor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveFiltersBar extends GetView<TransactionsController> {
  const _ActiveFiltersBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (!controller.hasActiveFilters) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.checkmark_shield,
              size: 18,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Filters active',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                controller.clearFilters();
              },
              child: Text(
                'Clear All',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: -0.5, duration: 300.ms).fadeIn();
    });
  }
}

class _EnhancedTransactionCard extends StatelessWidget {
  final LocalTransaction transaction;
  final int index;

  const _EnhancedTransactionCard({
    required this.transaction,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.expense;
    final amountString = isExpense
        ? '- ${NumberFormat.currency(locale: 'fr_FR', symbol: '', decimalDigits: 0).format(transaction.amount)}'
        : '+ ${NumberFormat.currency(locale: 'fr_FR', symbol: '', decimalDigits: 0).format(transaction.amount)}';

    final color = isExpense
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    final icon = isExpense
        ? CupertinoIcons.arrow_up_circle_fill
        : CupertinoIcons.arrow_down_circle_fill;

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withAlpha(26),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                HapticFeedback.selectionClick();
                // Could open transaction details
              },
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 28.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.tag,
                                size: 14,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withAlpha(153),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                transaction.category?.displayName ??
                                    'Uncategorized',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withAlpha(153),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                CupertinoIcons.calendar,
                                size: 14,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withAlpha(153),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'dd MMM, yyyy',
                                ).format(transaction.date),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withAlpha(153),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amountString,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'FCFA',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color.withAlpha(153),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 30).ms)
        .slideX(
          begin: -0.1,
          duration: 400.ms,
          delay: (index * 30).ms,
          curve: Curves.easeOutQuart,
        );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(child: CupertinoActivityIndicator(radius: 14.r)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<TransactionsController>();

    return Center(
      child:
          Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.search,
                      size: 60.sp,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    controller.hasActiveFilters
                        ? 'No transactions found'
                        : 'No transactions yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: Text(
                      controller.hasActiveFilters
                          ? 'Try adjusting your filters'
                          : 'Start adding transactions to see them here',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(153),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (controller.hasActiveFilters) ...[
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        controller.clearFilters();
                      },
                      icon: const Icon(CupertinoIcons.clear),
                      label: const Text('Clear Filters'),
                    ),
                  ],
                ],
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
    );
  }
}

class _FilterBottomSheet extends GetView<TransactionsController> {
  const _FilterBottomSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter & Sort', style: theme.textTheme.titleLarge),
              IconButton(
                icon: const Icon(CupertinoIcons.xmark_circle_fill),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  NavigationHelper.safeBack();
                },
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Sort Options
          Text('Sort By', style: theme.textTheme.titleMedium),
          SizedBox(height: 12.h),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SortChip('Newest First', SortOption.dateNewest),
                _SortChip('Oldest First', SortOption.dateOldest),
                _SortChip('Highest Amount', SortOption.amountHighest),
                _SortChip('Lowest Amount', SortOption.amountLowest),
                _SortChip('A-Z', SortOption.description),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Date Range
          Text('Date Range', style: theme.textTheme.titleMedium),
          SizedBox(height: 12.h),
          Obx(() {
            final range = controller.dateRange.value;
            final hasRange = range != null;

            return OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _selectDateRange(context);
              },
              icon: Icon(
                hasRange
                    ? CupertinoIcons.calendar_badge_minus
                    : CupertinoIcons.calendar,
              ),
              label: Text(
                hasRange
                    ? '${DateFormat('dd MMM').format(range.start)} - ${DateFormat('dd MMM').format(range.end)}'
                    : 'Select Date Range',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            );
          }),

          SizedBox(height: 32.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    controller.clearFilters();
                    NavigationHelper.safeBack();
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    NavigationHelper.safeBack();
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: controller.dateRange.value,
    );

    if (picked != null) {
      controller.setDateRange(picked);
    }
  }
}

class _SortChip extends GetView<TransactionsController> {
  final String label;
  final SortOption option;

  const _SortChip(this.label, this.option);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = controller.currentSort.value == option;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        HapticFeedback.selectionClick();
        controller.setSort(option);
      },
      selectedColor: theme.colorScheme.primary.withAlpha(51),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
