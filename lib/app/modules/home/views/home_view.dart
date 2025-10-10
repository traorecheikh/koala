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
              'Hi, ${controller.userName.value}',
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
                'Your Balance',
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
          label: 'Income',
          color: theme.colorScheme.secondary,
          onTap: () =>
              showAddTransactionDialog(context, TransactionType.income),
        ),
        _AnimatedActionButton(
          icon: CupertinoIcons.arrow_up,
          label: 'Expense',
          color: theme.colorScheme.primary,
          onTap: () =>
              showAddTransactionDialog(context, TransactionType.expense),
        ),
        _AnimatedActionButton(
          icon: CupertinoIcons.square_grid_2x2_fill,
          label: 'More',
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
            child: Text('More Options', style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _AnimatedActionButton(
                icon: CupertinoIcons.chart_bar_alt_fill,
                label: 'Analytics',
                color: theme.colorScheme.secondary,
                onTap: () => Get.toNamed(Routes.analytics),
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
          Text('Recent Activity', style: theme.textTheme.titleLarge),
          const Icon(CupertinoIcons.search, size: 28),
        ],
      ),
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
        : '+ ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(transaction.amount)}';

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
            style: theme.textTheme.titleMedium?.copyWith(
              color: isExpense ? null : theme.colorScheme.secondary,
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideX(begin: -0.2, curve: Curves.easeOutQuart);
  }
}
