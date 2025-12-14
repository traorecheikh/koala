// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
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
            backgroundColor: KoalaColors.destructive,
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
          backgroundColor: KoalaColors.primaryUi(context),
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
      backgroundColor: KoalaColors.surface(context),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.back,
                size: 24.sp, color: KoalaColors.text(context)),
            onPressed: () {
              HapticFeedback.lightImpact();
              NavigationHelper.safeBack();
            },
            splashRadius: 24,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Toutes les transactions',
                  style: KoalaTypography.heading3(context),
                ),
                Obx(() {
                  final count = controller.displayedTransactions.length;
                  final total = controller.transactions.length;
                  final displayTotal = total > 0 ? total : 0;
                  return Text(
                    '$displayTotal transaction${displayTotal != 1 ? 's' : ''}',
                    style: KoalaTypography.caption(context).copyWith(
                      color: KoalaColors.textSecondary(context),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}

class _SearchBar extends GetView<TransactionsController> {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: KoalaColors.border(context)),
          boxShadow: KoalaColors.shadowSubtle,
        ),
        child: CupertinoSearchTextField(
          controller: controller.searchController,
          placeholder: 'Rechercher...',
          placeholderStyle:
              TextStyle(color: KoalaColors.textSecondary(context)),
          style: KoalaTypography.bodyMedium(context),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: const BoxDecoration(),
          prefixIcon: Icon(CupertinoIcons.search,
              size: 20.sp, color: KoalaColors.textSecondary(context)),
          suffixIcon: Icon(CupertinoIcons.clear_circled_solid,
              size: 20.sp, color: KoalaColors.textSecondary(context)),
        ),
      ),
    ).animate().slideY(begin: -0.2, duration: 400.ms).fadeIn();
  }
}

class _FilterChips extends GetView<TransactionsController> {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Obx(
        () => Row(
          children: [
            _FilterChip(
              label: 'Tout',
              isSelected: controller.currentFilter.value == FilterType.all,
              onTap: () => controller.setFilter(FilterType.all),
              icon: CupertinoIcons.square_stack_3d_up,
            ),
            SizedBox(width: 8.w),
            _FilterChip(
              label: 'Revenus',
              isSelected: controller.currentFilter.value == FilterType.income,
              onTap: () => controller.setFilter(FilterType.income),
              icon: CupertinoIcons.arrow_down_circle,
              color: KoalaColors.success,
            ),
            SizedBox(width: 8.w),
            _FilterChip(
              label: 'Dépenses',
              isSelected: controller.currentFilter.value == FilterType.expense,
              onTap: () => controller.setFilter(FilterType.expense),
              icon: CupertinoIcons.arrow_up_circle,
              color: KoalaColors.destructive,
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
    final activeColor = color ?? KoalaColors.primaryUi(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.1)
              : KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? activeColor : KoalaColors.border(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color:
                  isSelected ? activeColor : KoalaColors.textSecondary(context),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: KoalaTypography.bodyMedium(context).copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? activeColor
                    : KoalaColors.textSecondary(context),
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
    return Obx(() {
      if (!controller.hasActiveFilters) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: KoalaColors.primaryUi(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.checkmark_shield,
              size: 18.sp,
              color: KoalaColors.primaryUi(context),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Filtres actifs',
                style: KoalaTypography.bodySmall(context).copyWith(
                  color: KoalaColors.primaryUi(context),
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
                'Tout effacer',
                style: KoalaTypography.bodySmall(context).copyWith(
                  color: KoalaColors.primaryUi(context),
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
    final isExpense = transaction.type == TransactionType.expense;
    final amountString = isExpense
        ? '- ${NumberFormat.currency(locale: 'fr_FR', symbol: '', decimalDigits: 0).format(transaction.amount)}'
        : '+ ${NumberFormat.currency(locale: 'fr_FR', symbol: '', decimalDigits: 0).format(transaction.amount)}';

    final color = isExpense ? KoalaColors.destructive : KoalaColors.success;

    final icon = isExpense
        ? CupertinoIcons.arrow_up_circle_fill
        : CupertinoIcons.arrow_down_circle_fill;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: KoalaColors.border(context),
          width: 1,
        ),
        boxShadow: KoalaColors.shadowSubtle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
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
                        style: KoalaTypography.bodyLarge(context).copyWith(
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
                            size: 14.sp,
                            color: KoalaColors.textSecondary(context),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            transaction.category?.displayName ?? 'Non classé',
                            style: KoalaTypography.caption(context).copyWith(
                              color: KoalaColors.textSecondary(context),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            CupertinoIcons.calendar,
                            size: 14.sp,
                            color: KoalaColors.textSecondary(context),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            DateFormat('dd MMM, yyyy', 'fr_FR')
                                .format(transaction.date),
                            style: KoalaTypography.caption(context).copyWith(
                              color: KoalaColors.textSecondary(context),
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
                      style: KoalaTypography.heading3(context).copyWith(
                        color: color,
                        fontSize: 18.sp,
                      ),
                    ),
                    Text(
                      'FCFA',
                      style: KoalaTypography.caption(context).copyWith(
                        color: color.withOpacity(0.7),
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
    ).animate().fadeIn(duration: 400.ms, delay: (index * 30).ms).slideX(
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
      padding: EdgeInsets.all(24.w),
      child: Center(child: CupertinoActivityIndicator(radius: 14.r)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsController>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: KoalaColors.surface(context),
              shape: BoxShape.circle,
              boxShadow: KoalaColors.shadowSubtle,
            ),
            child: Icon(
              CupertinoIcons.search,
              size: 60.sp,
              color: KoalaColors.textSecondary(context),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            controller.hasActiveFilters
                ? 'Aucune transaction trouvée'
                : 'Aucune transaction pour le moment',
            style: KoalaTypography.heading3(context),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              controller.hasActiveFilters
                  ? 'Essayez d\'ajuster vos filtres'
                  : 'Ajoutez des transactions pour les voir ici',
              style: KoalaTypography.bodyMedium(context).copyWith(
                color: KoalaColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (controller.hasActiveFilters) ...[
            SizedBox(height: 24.h),
            SizedBox(
              width: 200.w,
              child: KoalaButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  controller.clearFilters();
                },
                text: 'Effacer les filtres',
              ),
            ),
          ],
        ],
      ).animate().fadeIn(duration: 400.ms).scale(
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
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filtrer & Trier', style: KoalaTypography.heading3(context)),
              IconButton(
                icon: Icon(CupertinoIcons.xmark_circle_fill,
                    color: KoalaColors.textSecondary(context)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  NavigationHelper.safeBack();
                },
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Sort Options
          Text('Trier par',
              style: KoalaTypography.bodyLarge(context)
                  .copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SortChip('Plus récents', SortOption.dateNewest),
                _SortChip('Plus anciens', SortOption.dateOldest),
                _SortChip('Montant le plus élevé', SortOption.amountHighest),
                _SortChip('Montant le plus bas', SortOption.amountLowest),
                _SortChip('A-Z', SortOption.description),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Date Range
          Text('Période',
              style: KoalaTypography.bodyLarge(context)
                  .copyWith(fontWeight: FontWeight.bold)),
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
                color: KoalaColors.primaryUi(context),
              ),
              label: Text(
                hasRange
                    ? '${DateFormat('dd MMM', 'fr_FR').format(range.start)} - ${DateFormat('dd MMM', 'fr_FR').format(range.end)}'
                    : 'Sélectionner une période',
                style: KoalaTypography.bodyMedium(context)
                    .copyWith(color: KoalaColors.primaryUi(context)),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                side: BorderSide(color: KoalaColors.primaryUi(context)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            );
          }),

          SizedBox(height: 32.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: KoalaButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    controller.clearFilters();
                    NavigationHelper.safeBack();
                  },
                  text: 'Tout effacer',
                  backgroundColor: KoalaColors.surface(context),
                  textColor: KoalaColors.text(context),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: KoalaButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    NavigationHelper.safeBack();
                  },
                  text: 'Appliquer',
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
      locale: const Locale('fr', 'FR'),
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
    final isSelected = controller.currentSort.value == option;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        HapticFeedback.selectionClick();
        controller.setSort(option);
      },
      selectedColor: KoalaColors.primaryUi(context).withOpacity(0.1),
      checkmarkColor: KoalaColors.primaryUi(context),
      backgroundColor: KoalaColors.surface(context),
      labelStyle: KoalaTypography.bodySmall(context).copyWith(
        color: isSelected
            ? KoalaColors.primaryUi(context)
            : KoalaColors.text(context),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? KoalaColors.primaryUi(context)
            : KoalaColors.border(context),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    );
  }
}


