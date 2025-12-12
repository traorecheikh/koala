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
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/home/widgets/add_transaction_dialog.dart';
import 'package:koaa/app/modules/home/widgets/enhanced_balance_card.dart';
import 'package:koaa/app/modules/home/widgets/financial_health_widget.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import '../widgets/smart_insights_widget.dart';

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
      category = categoriesController.categories.firstWhereOrNull((c) => c.id == transaction.categoryId);
    }
    
    if (category != null) {
      iconKey = category.icon;
    } else if (transaction.category != null) {
      iconKey = transaction.category!.iconKey;
    }

    // Determine icon background color based on category color, with subtle opacity
    final categoryColor = category != null ? Color(category.colorValue) : (isExpense ? Colors.red : Colors.green);
    final containerColor = categoryColor.withOpacity(isDark ? 0.15 : 0.1);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: isDark ? theme.scaffoldBackgroundColor.withOpacity(0.8) : Colors.white,
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
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart);
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final controller = Get.find<HomeController>();
    final results = controller.transactions.where((tx) {
      final q = query.toLowerCase();
      
      final descriptionMatch = tx.description.toLowerCase().contains(q);
      final amountMatch = tx.amount.toString().contains(q);
      final categoryMatch = tx.category?.displayName.toLowerCase().contains(q) ?? false;
      
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    const _Header(),
                    const SizedBox(height: 24),
                    const EnhancedBalanceCard(),
                    const SizedBox(height: 32),
                    const _QuickActions(), 
                    const SizedBox(height: 24),
                    const SmartInsightsWidget(),
                    const SizedBox(height: 16),
                    const FinancialHealthWidget(),
                    const SizedBox(height: 32),
                    const _TransactionsHeader(),
                    const SizedBox(height: 12),
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
            _TransactionSliverList(), // Removed const as it builds dynamically
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<HomeController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
            icon: const Icon(CupertinoIcons.settings, size: 28),
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
          color: theme.colorScheme.secondary,
          onTap: () =>
              showAddTransactionDialog(context, TransactionType.income),
        ),

        _AnimatedActionButton(
          icon: CupertinoIcons.arrow_up,
          label: 'Dépense',
          color: theme.colorScheme.primary,
          onTap: () =>
              showAddTransactionDialog(context, TransactionType.expense),
        ),
        _AnimatedActionButton(
          icon: CupertinoIcons.star_fill,
          label: 'Objectifs',
          color: Colors.pinkAccent,
          onTap: () => Get.toNamed(Routes.analytics),
        ),
        _AnimatedActionButton(
          icon: CupertinoIcons.square_grid_2x2_fill,
          label: 'Plus',
          color: Colors.grey.shade600,
          onTap: () {
            Get.bottomSheet(
              const _MoreOptionsSheet(),
              backgroundColor: Theme.of(context).colorScheme.surface,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MoreOptionsSheet extends StatelessWidget {
  const _MoreOptionsSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.0.h),
            child: Text('Plus d’options', style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _AnimatedActionButton(
                icon: CupertinoIcons.chart_bar_alt_fill,
                label: 'Statistiques',
                color: theme.colorScheme.secondary,
                onTap: () => Get.toNamed(Routes.analytics),
              ),
              _AnimatedActionButton(
                icon: CupertinoIcons.chart_pie_fill,
                label: 'Budgets',
                color: Colors.orange,
                onTap: () => Get.toNamed(Routes.budget),
              ),
              _AnimatedActionButton(
                icon: CupertinoIcons.person_2_fill,
                label: 'Dettes',
                color: Colors.teal,
                onTap: () => Get.toNamed(Routes.debt),
              ),
              _AnimatedActionButton(
                icon: CupertinoIcons.wand_stars,
                label: 'Simulateur',
                color: Colors.purpleAccent,
                onTap: () => Get.toNamed(Routes.simulator),
              ),
              _AnimatedActionButton(
                icon: CupertinoIcons.archivebox_fill,
                label: 'Catégories',
                color: Colors.brown,
                onTap: () => Get.toNamed(Routes.categories),
              ),
              _AnimatedActionButton(
                icon: CupertinoIcons.settings_solid,
                label: 'Paramètres',
                color: Colors.black45,
                onTap: () => {Get.offAndToNamed(Routes.settings)},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Activité récente', style: theme.textTheme.titleLarge),
          GestureDetector(
            onTap: () => showSearch(
              context: context,
              delegate: TransactionSearchDelegate(),
            ),
            child: const Icon(CupertinoIcons.search, size: 28),
          ),
        ],
      ),
    );
  }
}

class _TransactionSliverList extends GetView<HomeController> {
  // Removed const here because SliverChildBuilderDelegate uses dynamic data
  _TransactionSliverList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final transactions = controller.transactions
          .where((t) => !t.isHidden)
          .take(5)
          .toList();
      
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
