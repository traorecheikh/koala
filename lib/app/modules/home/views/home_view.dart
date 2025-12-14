// ignore_for_file: deprecated_member_use

import 'package:countup/countup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/home/widgets/add_transaction_dialog.dart';
import 'package:koaa/app/modules/home/widgets/enhanced_balance_card.dart';
import 'package:koaa/app/modules/home/widgets/financial_health_widget.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/modules/goals/controllers/goals_controller.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart'; // New Import
import 'package:koaa/app/core/utils/navigation_helper.dart';
import '../widgets/smart_insights_widget.dart';
import '../../goals/views/widgets/goal_card.dart'; // Reusing goal card from goals module

import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

// --- Global Widgets (Accessible across the file for reuse) ---

class _TransactionListItem extends StatelessWidget {
  final LocalTransaction transaction;

  const _TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isExpense = transaction.type == TransactionType.expense;

    // Amount formatting with +/- symbol
    final amountString = isExpense
        ? '- ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(transaction.amount)}'
        : '+ ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(transaction.amount)}';

    // Resolve Category & Color
    final categoriesController = Get.find<CategoriesController>();
    Category? category;
    String iconKey = 'other';

    if (transaction.categoryId != null) {
      category = categoriesController.categories
          .firstWhereOrNull((c) => c.id == transaction.categoryId);
    }

    if (category != null) {
      iconKey = category.icon;
    } else if (transaction.category != null) {
      iconKey = transaction.category!.iconKey;
    }

    // Determine icon background color based on category color, with subtle opacity
    final categoryColor = category != null
        ? Color(category.colorValue)
        : (isExpense ? Colors.red : Colors.green);
    final containerColor = categoryColor.withOpacity(isDark ? 0.15 : 0.1);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: isDark
            ? theme.scaffoldBackgroundColor.withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(10.w),
          child: CategoryIcon(
            iconKey: iconKey,
            size: 24.sp,
            useOriginalColor: true,
          ),
        ),
        title: Text(
          transaction.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white : const Color(0xFF2D3250),
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            DateFormat('dd MMM, HH:mm', 'fr_FR').format(transaction.date),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white38 : Colors.grey.shade500,
              fontSize: 12.sp,
            ),
          ),
        ),
        trailing: Text(
          amountString,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white : const Color(0xFF2D3250),
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        onTap: () {
          // Navigate to details if needed
        },
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutQuart);
  }
}

class TransactionSearchDelegate extends SearchDelegate<LocalTransaction?> {
  TransactionSearchDelegate();

  @override
  String get searchFieldLabel => 'Rechercher...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
        titleTextStyle: theme.textTheme.titleLarge,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(CupertinoIcons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(CupertinoIcons.back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultsList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResultsList(context);
  }

  Widget _buildResultsList(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Commencez à taper pour rechercher des transactions.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final controller = Get.find<HomeController>();
    final results = controller.transactions.where((tx) {
      final q = query.toLowerCase();

      final descriptionMatch = tx.description.toLowerCase().contains(q);
      final amountMatch = tx.amount.toString().contains(q);
      final categoryMatch =
          tx.category?.displayName.toLowerCase().contains(q) ?? false;

      return descriptionMatch || amountMatch || categoryMatch;
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _TransactionListItem(transaction: results[index]);
      },
    );
  }
}

// --- Main HomeView and its Private Widgets ---

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const _Header(),
                        SizedBox(height: 24.h),
                        Padding(
                            padding: EdgeInsets.only(bottom: 32.h),
                            child: const EnhancedBalanceCard()),
                        const _BudgetAlertsBanner(),
                        const _GoalProgressMiniCards(),
                        const _UpcomingBillsWidget(),
                        Padding(
                            padding: EdgeInsets.only(bottom: 24.h),
                            child: const _QuickActions()),
                        Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: const SmartInsightsWidget()),
                        Padding(
                            padding: EdgeInsets.only(bottom: 32.h),
                            child: const FinancialHealthWidget()),
                        const _TransactionsHeader(),
                        SizedBox(height: 12.h),
                      ]
                          .animate(interval: 50.ms)
                          .slideY(
                            begin: 0.1,
                            duration: 400.ms,
                            curve: Curves.easeOutQuart,
                          )
                          .fadeIn(),
                    ),
                  ),
                ),
                _TransactionSliverList(),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              ],
            ),
          ),

          // Custom Overlay for "More Options" - OPTIMIZED: Single Obx instead of nested
          Obx(() {
            final isOpen = controller.isMoreOptionsOpen.value;
            final isHidden = controller.isSheetHidden.value;

            if (!isOpen) return const SizedBox.shrink();

            return IgnorePointer(
              ignoring: isHidden,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isHidden ? 0.0 : 1.0,
                child: Stack(
                  children: [
                    // Backdrop
                    GestureDetector(
                      onTap: () => controller.isMoreOptionsOpen.value = false,
                      child: Container(color: Colors.black54),
                    ),
                    // Sheet
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24.r)),
                          ),
                          child: const _MoreOptionsSheet()),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Header extends GetView<HomeController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              'Bonjour, ${controller.userName.value}',
              style: theme.textTheme.titleLarge,
            ),
          ),
          IconButton(
            icon: Icon(CupertinoIcons.settings, size: 28.sp),
            onPressed: () => Get.toNamed(Routes.settings),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends GetView<HomeController> {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8.w,
      mainAxisSpacing: 4.h,
      children: [
        _AnimatedActionButton(
          icon: CupertinoIcons.arrow_down,
          label: 'Revenu',
          color: Colors.green,
          onTap: () =>
              showAddTransactionDialog(context, TransactionType.income),
        ),

        _AnimatedActionButton(
          icon: CupertinoIcons.arrow_up,
          label: 'Dépense',
          color: Colors.black,
          onTap: () =>
              showAddTransactionDialog(context, TransactionType.expense),
        ),

        // Dynamic Slot 3
        Obx(() {
          final currentAction = controller.thirdAction.value;
          return DragTarget<QuickActionType>(
            onAccept: (data) {
              controller.setThirdAction(data);
              HapticFeedback.heavyImpact();
            },
            onWillAccept: (data) => data != null && data != currentAction,
            builder: (context, candidateData, rejectedData) {
              final isHovered = candidateData.isNotEmpty;
              final actionToShow =
                  isHovered ? (candidateData.firstOrNull ?? currentAction) : currentAction;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: _AnimatedActionButton(
                  key: ValueKey(actionToShow),
                  icon: _getIcon(actionToShow),
                  label: _getLabel(actionToShow),
                  color: _getColor(actionToShow, theme),
                  onTap: () => isHovered ? {} : _handleTap(actionToShow),
                  onLongPress: () => _showSelectionSheet(context),
                ),
              );
            },
          );
        }),

        _AnimatedActionButton(
          icon: CupertinoIcons.square_grid_2x2_fill,
          label: 'Plus',
          color: Colors.grey.shade600,
          onTap: () {
            controller.isMoreOptionsOpen.value = true;
          },
        ),
      ],
    );
  }

  IconData _getIcon(QuickActionType type) {
    switch (type) {
      case QuickActionType.goals:
        return CupertinoIcons.star_fill;
      case QuickActionType.analytics:
        return CupertinoIcons.chart_bar_alt_fill;
      case QuickActionType.budget:
        return CupertinoIcons.chart_pie_fill;
      case QuickActionType.debt:
        return CupertinoIcons.person_2_fill;
      case QuickActionType.simulator:
        return CupertinoIcons.wand_stars;
      case QuickActionType.categories:
        return CupertinoIcons.archivebox_fill;
      case QuickActionType.settings:
        return CupertinoIcons.settings_solid;
    }
  }

  String _getLabel(QuickActionType type) {
    switch (type) {
      case QuickActionType.goals:
        return 'Objectifs';
      case QuickActionType.analytics:
        return 'Stats';
      case QuickActionType.budget:
        return 'Budgets';
      case QuickActionType.debt:
        return 'Dettes';
      case QuickActionType.simulator:
        return 'Simul.';
      case QuickActionType.categories:
        return 'Catég.';
      case QuickActionType.settings:
        return 'Param.';
    }
  }

  Color _getColor(QuickActionType type, ThemeData theme) {
    switch (type) {
      case QuickActionType.goals:
        return Colors.pinkAccent;
      case QuickActionType.analytics:
        return theme.colorScheme.secondary;
      case QuickActionType.budget:
        return Colors.orange;
      case QuickActionType.debt:
        return Colors.teal;
      case QuickActionType.simulator:
        return Colors.purpleAccent;
      case QuickActionType.categories:
        return Colors.brown;
      case QuickActionType.settings:
        return Colors.black45;
    }
  }

  void _handleTap(QuickActionType type) {
    switch (type) {
      case QuickActionType.goals:
        Get.toNamed(Routes.goals);
        break;
      case QuickActionType.analytics:
        Get.toNamed(Routes.analytics);
        break;
      case QuickActionType.budget:
        Get.toNamed(Routes.budget);
        break;
      case QuickActionType.debt:
        Get.toNamed(Routes.debt);
        break;
      case QuickActionType.simulator:
        Get.toNamed(Routes.simulator);
        break;
      case QuickActionType.categories:
        Get.toNamed(Routes.categories);
        break;
      case QuickActionType.settings:
        Get.offAndToNamed(Routes.settings);
        break;
    }
  }

  void _showSelectionSheet(BuildContext context) {
    final theme = Theme.of(context);
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choisir un raccourci', style: theme.textTheme.titleLarge),
            SizedBox(height: 24.h),
            Wrap(
              spacing: 24.w,
              runSpacing: 24.h,
              alignment: WrapAlignment.center,
              children: QuickActionType.values.map((type) {
                return GestureDetector(
                  onTap: () {
                    controller.setThirdAction(type);
                    NavigationHelper.safeBack();
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: _getColor(type, theme).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIcon(type),
                            color: _getColor(type, theme), size: 28.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(_getLabel(type), style: TextStyle(fontSize: 12.sp)),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _MoreOptionsSheet extends GetView<HomeController> {
  const _MoreOptionsSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 16.w;
    final availableWidth = screenWidth - (padding * 2);
    final columns = 4;
    final itemWidth = availableWidth / columns;
    final itemHeight = 100.h; // Estimated height for button + label

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 16.h, padding, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.0.h),
            child: Text('Plus d’options', style: theme.textTheme.titleLarge),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            final actions = controller.sheetActions;
            final rows = (actions.length / columns).ceil();
            final height = rows * itemHeight;

            return SizedBox(
              height: height,
              child: Stack(
                children: actions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final type = entry.value;

                  final row = index ~/ columns;
                  final col = index % columns;

                  final top = row * itemHeight;
                  final left = col * itemWidth;

                  return AnimatedPositioned(
                    key: ValueKey(type), // Crucial for animation
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut, // Bouncy flow
                    top: top,
                    left: left,
                    width: itemWidth,
                    height: itemHeight,
                    child: Center(
                      child: DragTarget<QuickActionType>(
                        onWillAccept: (data) => data != null && data != type,
                        onAccept: (data) {
                          controller.reorderSheetAction(data, type);
                          HapticFeedback.mediumImpact();
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isHovered = candidateData.isNotEmpty;
                          return Transform.scale(
                            scale: isHovered ? 1.1 : 1.0, // Pop effect on hover
                            child: _buildDraggableOption(
                              type: type,
                              icon: _getIcon(type),
                              label: _getLabel(type),
                              color: _getColor(type, theme),
                              onTap: () => _handleTap(type),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDraggableOption({
    required QuickActionType type,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return LongPressDraggable<QuickActionType>(
      data: type,
      delay: const Duration(milliseconds: 200),
      onDragUpdate: (details) {
        // Dynamic hiding: Hide sheet if dragging UP (out of sheet area)
        // Show sheet if dragging DOWN (inside sheet area)
        // Threshold: Approx 65% of screen height (assuming sheet is bottom 35%)
        if (details.globalPosition.dy < Get.height * 0.65) {
          controller.isSheetHidden.value = true;
        } else {
          controller.isSheetHidden.value = false;
        }
      },
      onDragEnd: (_) => controller.isSheetHidden.value = false,
      onDraggableCanceled: (_, __) => controller.isSheetHidden.value = false,
      onDragCompleted: () {
        controller.isSheetHidden.value = false;
        controller.isMoreOptionsOpen.value = false;
      },
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: SizedBox(
            width: 80.w,
            child: _AnimatedActionButton(
              icon: icon,
              label: label,
              color: color,
              onTap: () {},
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _AnimatedActionButton(
          icon: icon,
          label: label,
          color: color,
          onTap: onTap,
        ),
      ),
      child: _AnimatedActionButton(
        icon: icon,
        label: label,
        color: color,
        onTap: onTap,
      ),
    );
  }

  // Helpers duplicated from _QuickActions for self-containment
  IconData _getIcon(QuickActionType type) {
    switch (type) {
      case QuickActionType.goals:
        return CupertinoIcons.star_fill;
      case QuickActionType.analytics:
        return CupertinoIcons.chart_bar_alt_fill;
      case QuickActionType.budget:
        return CupertinoIcons.chart_pie_fill;
      case QuickActionType.debt:
        return CupertinoIcons.person_2_fill;
      case QuickActionType.simulator:
        return CupertinoIcons.wand_stars;
      case QuickActionType.categories:
        return CupertinoIcons.archivebox_fill;
      case QuickActionType.settings:
        return CupertinoIcons.settings_solid;
    }
  }

  String _getLabel(QuickActionType type) {
    switch (type) {
      case QuickActionType.goals:
        return 'Objectifs';
      case QuickActionType.analytics:
        return 'Stats';
      case QuickActionType.budget:
        return 'Budgets';
      case QuickActionType.debt:
        return 'Dettes';
      case QuickActionType.simulator:
        return 'Simul.';
      case QuickActionType.categories:
        return 'Catég.';
      case QuickActionType.settings:
        return 'Param.';
    }
  }

  Color _getColor(QuickActionType type, ThemeData theme) {
    switch (type) {
      case QuickActionType.goals:
        return Colors.pinkAccent;
      case QuickActionType.analytics:
        return theme.colorScheme.secondary;
      case QuickActionType.budget:
        return Colors.orange;
      case QuickActionType.debt:
        return Colors.teal;
      case QuickActionType.simulator:
        return Colors.purpleAccent;
      case QuickActionType.categories:
        return Colors.brown;
      case QuickActionType.settings:
        return Colors.black45;
    }
  }

  void _handleTap(QuickActionType type) {
    switch (type) {
      case QuickActionType.goals:
        Get.toNamed(Routes.goals);
        break;
      case QuickActionType.analytics:
        Get.toNamed(Routes.analytics);
        break;
      case QuickActionType.budget:
        Get.toNamed(Routes.budget);
        break;
      case QuickActionType.debt:
        Get.toNamed(Routes.debt);
        break;
      case QuickActionType.simulator:
        Get.toNamed(Routes.simulator);
        break;
      case QuickActionType.categories:
        Get.toNamed(Routes.categories);
        break;
      case QuickActionType.settings:
        Get.offAndToNamed(Routes.settings);
        break;
    }
  }
}

class _AnimatedActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress; // Added

  const _AnimatedActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.onLongPress, // Added
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress, // Wired up
      child: Animate(
        effects: const [
          ScaleEffect(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32.sp, color: color),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsHeader extends StatelessWidget {
  const _TransactionsHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Activité récente', style: theme.textTheme.titleLarge),
          GestureDetector(
            onTap: () => showSearch(
              context: context,
              delegate: TransactionSearchDelegate(),
            ),
            child: Icon(CupertinoIcons.search, size: 28.sp),
          ),
        ],
      ),
    );
  }
}

class _TransactionSliverList extends GetView<HomeController> {
  // Cannot be const because SliverChildBuilderDelegate uses dynamic data
  const _TransactionSliverList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final transactions = controller.transactions.take(5).toList();

      // Show empty state if no transactions
      if (transactions.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: KoalaEmptyState(
            icon: Icons.inbox_outlined,
            title: 'Aucune transaction',
            message:
                'Ajoutez votre première transaction pour commencer à suivre vos finances.',
            buttonText: 'Ajouter une dépense',
            onButtonPressed: () =>
                showAddTransactionDialog(context, TransactionType.expense),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tx = transactions[index];
            return _TransactionListItem(transaction: tx);
          },
          childCount: transactions.length,
        ),
      );
    });
  }
}

class _BudgetAlertsBanner extends GetView<HomeController> {
  const _BudgetAlertsBanner();

  String _formatAmount(double amount) {
    return NumberFormat('#,###', 'fr_FR').format(amount.round());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FinancialContextService financialContextService =
        Get.find<FinancialContextService>();

    return Obx(() {
      // Find any budget that is nearing or exceeded
      final budgetsInAlert = financialContextService.allBudgets.where((budget) {
        final spent = financialContextService.getSpentAmountForCategory(
            budget.categoryId, DateTime.now().year, DateTime.now().month);
        final percentage = (spent / (budget.amount == 0 ? 1 : budget.amount));
        return percentage >= 0.8; // Nearing or exceeded 80%
      }).toList();

      if (budgetsInAlert.isEmpty) {
        return const SizedBox.shrink();
      }

      // Display all budget alerts
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Column(
          children: budgetsInAlert.map((budget) {
            final spent = financialContextService.getSpentAmountForCategory(
                budget.categoryId, DateTime.now().year, DateTime.now().month);
            final remaining = budget.amount - spent;
            final category =
                financialContextService.getCategoryById(budget.categoryId);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.exclamationmark_triangle_fill,
                      color: Colors.orange, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Alerte: ${category?.name ?? 'Inconnu'}',
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          remaining >= 0
                              ? 'Il vous reste ${_formatAmount(remaining)} F'
                              : 'Vous avez dépassé de ${_formatAmount(remaining.abs())} F',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_right,
                      color: Colors.orange, size: 20.sp),
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _GoalProgressMiniCards extends GetView<GoalsController> {
  const _GoalProgressMiniCards({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final activeGoals = controller.activeGoals;
      if (activeGoals.isEmpty) {
        return const SizedBox.shrink();
      }

      // Display up to 3 active goals
      final goalsToShow = activeGoals.take(3).toList();

      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                'Mes Objectifs',
                style: theme.textTheme.titleLarge,
              ),
            ),
            SizedBox(height: 12.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goalsToShow.length,
              itemBuilder: (context, index) {
                final goal = goalsToShow[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: GoalCard(goal: goal),
                );
              },
            ),
            if (activeGoals.length > 3)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed(Routes.goals),
                  child: const Text('Voir tous les objectifs'),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _UpcomingBillsWidget extends GetView<HomeController> {
  const _UpcomingBillsWidget({super.key});

  String _formatAmount(double amount) {
    return NumberFormat('#,###', 'fr_FR').format(amount.round());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final FinancialContextService financialContextService =
        Get.find<FinancialContextService>();

    return Obx(() {
      final now = DateTime.now();
      final upcomingRecurringTransactions = financialContextService
          .allRecurringTransactions
          .where((rt) =>
              rt.nextDueDate.isAfter(now) &&
              rt.nextDueDate.isBefore(now.add(const Duration(days: 7))))
          .toList();

      final upcomingDebts = financialContextService.allDebts
          .where((debt) {
            final dueDate = debt.dueDate;
            return dueDate != null &&
                dueDate.isAfter(now) &&
                dueDate.isBefore(now.add(const Duration(days: 7)));
          })
          .toList();

      if (upcomingRecurringTransactions.isEmpty && upcomingDebts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                'Factures à venir',
                style: theme.textTheme.titleLarge,
              ),
            ),
            SizedBox(height: 12.h),
            ...upcomingRecurringTransactions.map((rt) {
              final category =
                  financialContextService.getCategoryById(rt.categoryId ?? '');
              final iconKey = category?.icon ??
                  (rt.type == TransactionType.expense
                      ? 'other'
                      : 'otherIncome');
              final color = category != null
                  ? Color(category.colorValue)
                  : (rt.type == TransactionType.expense
                      ? Colors.red
                      : Colors.green);

              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: CategoryIcon(
                            iconKey: iconKey,
                            size: 20.sp,
                            useOriginalColor: true),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rt.description,
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            'Due: ${DateFormat('dd MMM').format(rt.nextDueDate)}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_formatAmount(rt.amount)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: rt.type == TransactionType.expense
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            ...upcomingDebts.map((debt) {
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Icon(CupertinoIcons.person_2_fill,
                            size: 20.sp, color: Colors.blue),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dette: ${debt.personName}',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            'Due: ${DateFormat('dd MMM').format(debt.dueDate ?? DateTime.now())}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_formatAmount(debt.minPayment)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }
}
