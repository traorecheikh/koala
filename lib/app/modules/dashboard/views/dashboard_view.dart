import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koala/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:koala/app/shared/controllers/theme_controller.dart';

/// Modern dashboard with improved financial UX
/// - Clean balance card design
/// - Better quick actions layout
/// - Enhanced transaction list
/// - Proper data visualization
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            surfaceTintColor: theme.colorScheme.surface,
            title: FadeInDown(
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.dashboard_rounded,
                      size: 20.sp,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Tableau de bord',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              FadeInRight(
                child: IconButton(
                  onPressed: () => Get.toNamed('/settings'),
                  icon: Icon(
                    Icons.person_outline_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            backgroundColor: theme.colorScheme.surface,
            pinned: true,
            expandedHeight: 80.h,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: theme.colorScheme.surface),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  FadeInUp(child: _buildWelcomeSection(context)),
                  SizedBox(height: 24.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildBalanceCard(context),
                  ),
                  SizedBox(height: 24.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildQuickActions(context),
                  ),
                  SizedBox(height: 24.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: _buildRecentTransactions(context),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Welcome section with personalized greeting
  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    String greeting = hour < 12 
        ? 'Bonjour' 
        : hour < 17 
            ? 'Bon après-midi' 
            : 'Bonsoir';
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting ! 👋',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Voici un aperçu de vos finances',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solde Total',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.visibility_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              '${controller.totalBalance.value.toStringAsFixed(0)} XOF',
              style: GoogleFonts.poppins(
                textStyle: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildIncomeExpense(
                  context, 
                  'Revenus', 
                  controller.monthlyIncome, 
                  Icons.trending_up_rounded,
                  Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildIncomeExpense(
                  context, 
                  'Dépenses', 
                  controller.monthlyExpenses, 
                  Icons.trending_down_rounded,
                  Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpense(
    BuildContext context, 
    String title, 
    RxDouble amount, 
    IconData icon,
    Color textColor,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          icon,
          color: textColor.withOpacity(0.9),
          size: 20.sp,
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Obx(
          () => Text(
            '${amount.value.toStringAsFixed(0)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
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
        Text(
          'Actions Rapides',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                Icons.add_circle_outline_rounded,
                'Ajouter\nRevenu',
                theme.colorScheme.primary,
                () => _showAddTransactionDialog(context, 'income'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionCard(
                context,
                Icons.remove_circle_outline_rounded,
                'Ajouter\nDépense',
                theme.colorScheme.error,
                () => _showAddTransactionDialog(context, 'expense'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                Icons.account_balance_outlined,
                'Gérer\nPrêts',
                theme.colorScheme.secondary,
                () => Get.toNamed('/loans'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionCard(
                context,
                Icons.insights_rounded,
                'Analyses\nIA',
                theme.colorScheme.tertiary,
                () => Get.toNamed('/insights'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                size: 18.sp,
                color: color,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Show add transaction dialog
  void _showAddTransactionDialog(BuildContext context, String type) {
    // TODO: Implement transaction dialog
    Get.snackbar(
      'À venir',
      'La fonctionnalité d\'ajout de ${type == 'income' ? 'revenu' : type == 'expense' ? 'dépense' : 'transfert'} sera bientôt disponible',
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      colorText: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = [
      {
        'id': '1',
        'title': 'Auchan Dakar',
        'category': 'Alimentation',
        'amount': -12500.0,
        'time': 'Aujourd\'hui 14:32',
        'icon': Icons.shopping_cart_outlined,
        'type': 'expense',
      },
      {
        'id': '2',
        'title': 'Salaire Septembre',
        'category': 'Revenus',
        'amount': 350000.0,
        'time': 'Hier 09:00',
        'icon': Icons.work_outline_rounded,
        'type': 'income',
      },
      {
        'id': '3',
        'title': 'Transport BRT',
        'category': 'Transport',
        'amount': -500.0,
        'time': '15 Sept',
        'icon': Icons.directions_bus_filled_outlined,
        'type': 'expense',
      },
      {
        'id': '4',
        'title': 'Transfert Wave',
        'category': 'Transfert',
        'amount': -5000.0,
        'time': '14 Sept',
        'icon': Icons.send_outlined,
        'type': 'transfer',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions Récentes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: () => Get.toNamed('/transactions'),
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
              ),
              label: const Text('Voir tout'),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            return _ModernTransactionListItem(transaction: tx);
          },
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
        ),
      ],
    );
  }
}

/// Modern transaction list item with improved UX
class _ModernTransactionListItem extends StatelessWidget {
  const _ModernTransactionListItem({required this.transaction});

  final Map<String, dynamic> transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = transaction['amount'] as double;
    final isIncome = amount > 0;
    final type = transaction['type'] as String;
    
    Color getTransactionColor() {
      switch (type) {
        case 'income':
          return theme.colorScheme.primary;
        case 'expense':
          return theme.colorScheme.error;
        case 'transfer':
          return theme.colorScheme.secondary;
        default:
          return theme.colorScheme.onSurface;
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
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: getTransactionColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              transaction['icon'] as IconData,
              color: getTransactionColor(),
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
                    Text(
                      transaction['category'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      transaction['time'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : ''}${amount.toStringAsFixed(0)} XOF',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: getTransactionColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (type == 'transfer')
                Container(
                  margin: EdgeInsets.only(top: 4.h),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Transfert',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
