import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koala/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:koala/app/shared/controllers/theme_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            surfaceTintColor: theme.colorScheme.background,
            title: FadeInDown(
              child: Text('Bonjour Cheikh! 👋',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            actions: [
              FadeInRight(
                child: IconButton(
                  onPressed: () => Get.toNamed('/settings'),
                  icon: const Icon(Icons.person_2_outlined),
                ),
              ),
            ],
            backgroundColor: theme.colorScheme.background,
            pinned: true,
            expandedHeight: 100.h,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: theme.colorScheme.background),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  FadeInUp(child: _buildBalanceCard(context)),
                  SizedBox(height: 32.h),
                  FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: _buildQuickActions(context)),
                  SizedBox(height: 32.h),
                  FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: _buildRecentTransactions(context)),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solde Total',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => Text(
                '${controller.totalBalance.value.toStringAsFixed(0)} XOF',
                style: GoogleFonts.poppins(
                  textStyle: theme.textTheme.displaySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            const Divider(),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIncomeExpense(
                    context, 'Revenus', controller.monthlyIncome, Colors.green),
                const SizedBox(
                    height: 40, child: VerticalDivider(thickness: 1)),
                _buildIncomeExpense(context, 'Dépenses',
                    controller.monthlyExpenses, Colors.red),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpense(
      BuildContext context, String title, RxDouble amount, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: 4.h),
        Obx(
          () => Text(
            '${amount.value.toStringAsFixed(0)}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions Rapides',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(context, Icons.add_rounded, 'Revenu', () {}),
            _buildActionItem(context, Icons.remove_rounded, 'Dépense', () {}),
            _buildActionItem(
                context, Icons.receipt_long_rounded, 'Facture', () {}),
            _buildActionItem(
                context, Icons.insights_rounded, 'Statistiques', () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28.sp, color: theme.colorScheme.primary),
          ),
          SizedBox(height: 8.h),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = [
      {
        'title': 'Achat Auchan',
        'category': 'Alimentation',
        'amount': -12500.0,
        'time': '14:32',
        'icon': Icons.shopping_cart_outlined,
      },
      {
        'title': 'Salaire',
        'category': 'Revenus',
        'amount': 150000.0,
        'time': 'Hier',
        'icon': Icons.work_outline_rounded,
      },
      {
        'title': 'Transport BRT',
        'category': 'Transport',
        'amount': -500.0,
        'time': '15 Sept',
        'icon': Icons.directions_bus_filled_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Transactions Récentes',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {},
              child: const Text('Voir tout'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            return _TransactionListItem(transaction: tx);
          },
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
        ),
      ],
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  const _TransactionListItem({required this.transaction});

  final Map<String, dynamic> transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isIncome = (transaction['amount'] as double) > 0;
    final Color amountColor = isIncome ? Colors.green.shade600 : colorScheme.onSurface;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
          child: Icon(
            transaction['icon'] as IconData,
            color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
            size: 24.sp,
          ),
        ),
        title: Text(transaction['title'] as String,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(transaction['category'] as String,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${ (transaction['amount'] as double).abs().toStringAsFixed(0)} XOF',
              style: theme.textTheme.titleMedium?.copyWith(
                  color: amountColor, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 2.h),
            Text(transaction['time'] as String,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
