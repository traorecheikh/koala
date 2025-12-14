// ignore_for_file: deprecated_member_use

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
import 'package:koaa/app/modules/goals/controllers/goals_controller.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import '../widgets/smart_insights_widget.dart';
import '../../goals/views/widgets/goal_card.dart';

import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

// --- Global Widgets (Accessible across the file for reuse) ---

class _TransactionListItem extends StatelessWidget {
  final LocalTransaction transaction;

  const _TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
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
        : (isExpense ? KoalaColors.destructive : KoalaColors.success);
    final containerColor = categoryColor.withOpacity(0.12);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: KoalaColors.shadowSubtle,
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to details if needed
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: CategoryIcon(
                      iconKey: iconKey,
                      size: 24.sp,
                      useOriginalColor: true,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KoalaTypography.bodyLarge(context)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat('dd MMM, HH:mm', 'fr_FR')
                            .format(transaction.date),
                        style: KoalaTypography.caption(context),
                      ),
                    ],
                  ),
                ),
                Text(
                  amountString,
                  style: KoalaTypography.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: isExpense
                        ? KoalaColors.text(context)
                        : KoalaColors.success,
                  ),
                ),
              ],
            ),
          ),
        ),
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
    final isDark = theme.brightness == Brightness.dark;

    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: KoalaColors.background(context),
        elevation: 0,
        iconTheme: IconThemeData(color: KoalaColors.text(context)),
        titleTextStyle: KoalaTypography.heading3(context),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: KoalaTypography.bodyMedium(context)
            .copyWith(color: KoalaColors.textSecondary(context)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: KoalaColors.primary,
        selectionColor: KoalaColors.primary.withOpacity(0.2),
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: KoalaTypography.bodyLarge(context),
      ),
      scaffoldBackgroundColor: KoalaColors.background(context),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(CupertinoIcons.clear, color: KoalaColors.text(context)),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(CupertinoIcons.back, color: KoalaColors.text(context)),
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
          style: KoalaTypography.bodyMedium(context)
              .copyWith(color: KoalaColors.textSecondary(context)),
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        padding: EdgeInsets.only(top: 16.h),
        itemCount: results.length,
        itemBuilder: (context, index) {
          return _TransactionListItem(transaction: results[index]);
        },
      ),
    );
  }
}

// --- Main HomeView and its Private Widgets ---

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
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
                            color: KoalaColors.surface(context),
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24.r)),
                            boxShadow: KoalaColors.shadowMedium,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              'Bonjour, ${controller.userName.value}',
              style: KoalaTypography.heading2(context),
            ),
          ),
          IconButton(
            icon: Icon(CupertinoIcons.settings,
                size: 28.sp, color: KoalaColors.text(context)),
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
          color: KoalaColors.success,
          onTap: () =>
              showAddTransactionDialog(context, TransactionType.income),
        ),

        _AnimatedActionButton(
          icon: CupertinoIcons.arrow_up,
          label: 'Dépense',
          color: KoalaColors.text(context),
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
              final actionToShow = isHovered
                  ? (candidateData.firstOrNull ?? currentAction)
                  : currentAction;

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
                  color: _getColor(actionToShow, context),
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
          color: KoalaColors.textSecondary(context),
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
      case QuickActionType.intelligence:
        return CupertinoIcons.sparkles;
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
      case QuickActionType.intelligence:
        return 'IA';
    }
  }

  Color _getColor(QuickActionType type, BuildContext context) {
    // Standardize colors using KoalaColors where possible, or semantic colors that fit the premium theme
    switch (type) {
      case QuickActionType.goals:
        return const Color(0xFFFF2D55); // Pink
      case QuickActionType.analytics:
        return const Color(0xFF5E5CE6); // Indigo
      case QuickActionType.budget:
        return const Color(0xFFFF9F0A); // Orange
      case QuickActionType.debt:
        return const Color(0xFF30B0C7); // Teal
      case QuickActionType.simulator:
        return const Color(0xFFBF5AF2); // Purple
      case QuickActionType.categories:
        return const Color(0xFFA2845E); // Brown
      case QuickActionType.settings:
        return KoalaColors.textSecondary(context);
      case QuickActionType.intelligence:
        return const Color(0xFF64D2FF); // Cyan/Blue
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
      case QuickActionType.intelligence:
        Get.toNamed(Routes.intelligence);
        break;
    }
  }

  void _showSelectionSheet(BuildContext context) {
    Get.bottomSheet(
      KoalaBottomSheet(
        title: 'Choisir un raccourci',
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Wrap(
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
                        color: _getColor(type, context).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getIcon(type),
                          color: _getColor(type, context), size: 28.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(_getLabel(type),
                        style: KoalaTypography.caption(context)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _MoreOptionsSheet extends GetView<HomeController> {
  const _MoreOptionsSheet();

  @override
  Widget build(BuildContext context) {
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
            child: Text('Plus d’options',
                style: KoalaTypography.heading3(context)),
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
                              context: context,
                              type: type,
                              icon: _getIcon(type),
                              label: _getLabel(type),
                              color: _getColor(type, context),
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
    required BuildContext context,
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
      case QuickActionType.intelligence:
        return CupertinoIcons.sparkles;
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
      case QuickActionType.intelligence:
        return 'IA';
    }
  }

  Color _getColor(QuickActionType type, BuildContext context) {
    switch (type) {
      case QuickActionType.goals:
        return const Color(0xFFFF2D55);
      case QuickActionType.analytics:
        return const Color(0xFF5E5CE6);
      case QuickActionType.budget:
        return const Color(0xFFFF9F0A);
      case QuickActionType.debt:
        return const Color(0xFF30B0C7);
      case QuickActionType.simulator:
        return const Color(0xFFBF5AF2);
      case QuickActionType.categories:
        return const Color(0xFFA2845E);
      case QuickActionType.settings:
        return KoalaColors.textSecondary(context);
      case QuickActionType.intelligence:
        return const Color(0xFF64D2FF);
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
      case QuickActionType.intelligence:
        Get.toNamed(Routes.intelligence);
        break;
    }
  }
}

class _AnimatedActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _AnimatedActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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
                color: KoalaColors.surface(context),
                shape: BoxShape.circle,
                boxShadow: KoalaColors.shadowSubtle,
              ),
              child: Icon(icon, size: 28.sp, color: color),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: KoalaTypography.caption(context),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Activité récente', style: KoalaTypography.heading3(context)),
          GestureDetector(
            onTap: () => showSearch(
              context: context,
              delegate: TransactionSearchDelegate(),
            ),
            child: Icon(CupertinoIcons.search,
                size: 24.sp, color: KoalaColors.text(context)),
          ),
        ],
      ),
    );
  }
}

class _TransactionSliverList extends GetView<HomeController> {
  const _TransactionSliverList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final transactions = controller.transactions.take(5).toList();

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
    return NumberFormat.compact(locale: 'fr_FR').format(amount.round());
  }

  @override
  Widget build(BuildContext context) {
    final FinancialContextService financialContextService =
        Get.find<FinancialContextService>();

    return Obx(() {
      final budgetsInAlert = financialContextService.allBudgets.where((budget) {
        final spent = financialContextService.getSpentAmountForCategory(
            budget.categoryId, DateTime.now().year, DateTime.now().month);
        final percentage = (spent / (budget.amount == 0 ? 1 : budget.amount));
        return percentage >= 0.8;
      }).toList();

      if (budgetsInAlert.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.bell_fill,
                    color: KoalaColors.warning,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Alertes budget',
                    style: KoalaTypography.heading4(context),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: KoalaColors.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${budgetsInAlert.length}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: KoalaColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: budgetsInAlert.length,
                itemBuilder: (context, index) {
                  final budget = budgetsInAlert[index];
                  final spent =
                      financialContextService.getSpentAmountForCategory(
                          budget.categoryId,
                          DateTime.now().year,
                          DateTime.now().month);
                  final remaining = budget.amount - spent;
                  final percent =
                      spent / (budget.amount == 0 ? 1 : budget.amount);
                  final category = financialContextService
                      .getCategoryById(budget.categoryId);

                  final isExceeded = percent >= 1.0;
                  final alertColor = isExceeded
                      ? KoalaColors.destructive
                      : KoalaColors.warning;

                  return GestureDetector(
                    onTap: () => Get.toNamed(Routes.budget),
                    child: Container(
                      width: 220.w,
                      margin:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isExceeded
                              ? [
                                  const Color(0xFFFF6B6B),
                                  const Color(0xFFEE5A5A)
                                ]
                              : [
                                  const Color(0xFFFFAB5E),
                                  const Color(0xFFFF8C42)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: alertColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -10.w,
                            top: -10.h,
                            child: Opacity(
                              opacity: 0.1,
                              child: Icon(
                                CupertinoIcons.chart_pie_fill,
                                size: 60.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(14.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isExceeded
                                          ? CupertinoIcons
                                              .exclamationmark_triangle_fill
                                          : CupertinoIcons
                                              .exclamationmark_circle_fill,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        category?.name ?? 'Inconnu',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isExceeded
                                          ? 'Dépassement: ${_formatAmount(remaining.abs())} F'
                                          : 'Reste: ${_formatAmount(remaining)} F',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        '${(percent * 100).toInt()}% utilisé',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate(delay: (index * 100).ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.1);
                },
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1);
    });
  }
}

class _GoalProgressMiniCards extends GetView<GoalsController> {
  const _GoalProgressMiniCards();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeGoals = controller.activeGoals;
      if (activeGoals.isEmpty) {
        return const SizedBox.shrink();
      }

      final goalsToShow = activeGoals.take(3).toList();

      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mes Objectifs',
                    style: KoalaTypography.heading3(context),
                  ),
                  if (activeGoals.length > 3)
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.goals),
                      child: Text('Voir tout',
                          style: KoalaTypography.bodySmall(context)
                              .copyWith(color: KoalaColors.primary)),
                    ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goalsToShow.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final goal = goalsToShow[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: GoalCard(goal: goal),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _UpcomingBillsWidget extends GetView<HomeController> {
  const _UpcomingBillsWidget();

  String _formatAmount(double amount) {
    return NumberFormat('#,###', 'fr_FR').format(amount.round());
  }

  @override
  Widget build(BuildContext context) {
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

      final upcomingDebts = financialContextService.allDebts.where((debt) {
        final dueDate = debt.dueDate;
        return dueDate != null &&
            dueDate.isAfter(now) &&
            dueDate.isBefore(now.add(const Duration(days: 7)));
      }).toList();

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
                style: KoalaTypography.heading3(context),
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
                      ? KoalaColors.destructive
                      : KoalaColors.success);

              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: KoalaColors.surface(context),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: KoalaColors.shadowSubtle,
                  border: Border.all(color: KoalaColors.border(context)),
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
                            style: KoalaTypography.bodyMedium(context)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Due: ${DateFormat('dd MMM').format(rt.nextDueDate)}',
                            style: KoalaTypography.caption(context),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatAmount(rt.amount),
                      style: KoalaTypography.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: rt.type == TransactionType.expense
                            ? KoalaColors.destructive
                            : KoalaColors.success,
                      ),
                    ),
                  ],
                ),
              );
            }),
            ...upcomingDebts.map((debt) {
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: KoalaColors.surface(context),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: KoalaColors.shadowSubtle,
                  border: Border.all(color: KoalaColors.border(context)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: KoalaColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Icon(CupertinoIcons.person_2_fill,
                            size: 20.sp, color: KoalaColors.primary),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dette: ${debt.personName}',
                            style: KoalaTypography.bodyMedium(context)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Due: ${DateFormat('dd MMM').format(debt.dueDate ?? DateTime.now())}',
                            style: KoalaTypography.caption(context),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatAmount(debt.minPayment),
                      style: KoalaTypography.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: KoalaColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}


