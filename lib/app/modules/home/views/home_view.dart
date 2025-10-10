import 'package:countup/countup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/home/widgets/add_transaction_dialog.dart';
import 'package:koaa/app/modules/home/widgets/enhanced_balance_card.dart';

import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Animate(
          effects: const [FadeEffect(duration: Duration(milliseconds: 300))],
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            children:
                [
                      const _Header(),
                      const SizedBox(height: 24),
                      const EnhancedBalanceCard(),
                      const SizedBox(height: 32),
                      const _QuickActions(),
                      const SizedBox(height: 32),
                      const _TransactionsHeader(),
                      const SizedBox(height: 12),
                      const _TransactionList(),
                    ]
                    .animate(interval: 100.ms)
                    .slideY(
                      begin: 0.2,
                      duration: 400.ms,
                      curve: Curves.easeOutQuart,
                    )
                    .fadeIn(),
          ),
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

class _WalletCard extends StatelessWidget {
  const _WalletCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 215.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1E),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1B1E),
            const Color(0xFF1A1B1E).withAlpha((0.95 * 255).round()),
          ],
        ),
      ),
      child: const _BalanceView(),
    );
  }
}

class _BalanceView extends StatelessWidget {
  const _BalanceView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<HomeController>();
    return Padding(
      key: const ValueKey('balanceView'),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Votre solde',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              GestureDetector(
                onTap: () => controller.toggleBalanceVisibility(),
                child: Obx(
                  () => Icon(
                    controller.balanceVisible.value
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye_fill,
                    size: 24,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          const _BalanceDisplay(),
          const Spacer(),
        ],
      ),
    );
  }
}

class _BalanceDisplay extends GetView<HomeController> {
  const _BalanceDisplay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(
      () => controller.balanceVisible.value
          ? Countup(
              begin: 0,
              end: controller.balance.value,
              duration: const Duration(milliseconds: 800),
              separator: ' ',
              style: theme.textTheme.headlineMedium!.copyWith(
                fontSize: 42,
                color: Colors.white,
              ),
              curve: Curves.easeOut,
              prefix: 'FCFA ',
            )
          : Text(
              '••••••••',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 42,
                color: Colors.white,
              ),
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
          onTap: () => {
            // Get.toNamed(Routes.goals)
          },
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
                icon: CupertinoIcons.archivebox_fill,
                label: 'Categorie',
                color: Colors.brown,
                onTap: () => Get.toNamed(Routes.analytics),
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

// --- Flowy, smooth search page for transactions ---
class TransactionSearchDelegate extends SearchDelegate<LocalTransaction?> {
  TransactionSearchDelegate();

  @override
  String get searchFieldLabel => 'Rechercher un transfert...';

  @override
  TextStyle? get searchFieldStyle =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w400);

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
        hintStyle: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
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
    final controller = Get.find<HomeController>();
    final results = controller.transactions.where((tx) {
      final q = query.toLowerCase();
      return tx.description.toLowerCase().contains(q) ||
          NumberFormat.currency(
            locale: 'fr_FR',
            symbol: 'FCFA',
          ).format(tx.amount).contains(q);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'Aucun transfert trouvé',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      itemCount: results.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final tx = results[index];
        final isExpense = tx.type == TransactionType.expense;
        final color = isExpense
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary;
        final icon = isExpense
            ? CupertinoIcons.arrow_up
            : CupertinoIcons.arrow_down;
        return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuart,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.08),
                    blurRadius: 12.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withAlpha(30),
                  child: Icon(icon, color: color, size: 22.sp),
                ),
                title: Text(
                  tx.description,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  DateFormat('dd MMM, yyyy').format(tx.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Text(
                  (isExpense ? '- ' : '+ ') +
                      NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: 'FCFA',
                      ).format(tx.amount),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: color),
                ),
                onTap: () => close(context, tx),
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, curve: Curves.easeOutQuart);
      },
    );
  }
}

class _TransactionList extends GetView<HomeController> {
  const _TransactionList();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () =>
          Column(
            children: controller.transactions
                .map((tx) => _TransactionListItem(transaction: tx))
                .toList(),
          ).animate().slideY(
            begin: 0.5,
            duration: 500.ms,
            curve: Curves.easeOutQuart,
          ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final LocalTransaction transaction;

  const _TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.expense;
    final amountString = isExpense
        ? '- ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(transaction.amount)}'
        : ' ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(transaction.amount)}';

    final iconData = {
      TransactionType.income: {
        'icon': CupertinoIcons.arrow_down,
        'color': theme.colorScheme.secondary,
      },
      TransactionType.expense: {
        'icon': CupertinoIcons.arrow_up,
        'color': theme.colorScheme.primary,
      },
    };

    final IconData displayIcon =
        iconData[transaction.type]!['icon']! as IconData;
    final Color color = iconData[transaction.type]!['color']! as Color;

    return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          leading: CircleAvatar(
            radius: 25.r,
            backgroundColor: color.withAlpha(25),
            child: Icon(displayIcon, color: color, size: 24.sp),
          ),
          title: Text(
            transaction.description,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            DateFormat('dd MMM, yyyy').format(transaction.date),
            style: theme.textTheme.bodySmall,
          ),
          trailing: Text(
            amountString,
            style: theme.textTheme.titleMedium?.copyWith(color: null),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideX(begin: -0.2, curve: Curves.easeOutQuart);
  }
}
