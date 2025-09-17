import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koala/app/modules/loans/controllers/loans_controller.dart';

/// Modern loans management view
/// - Overview of all loans
/// - Payment tracking
/// - Loan creation
class LoansView extends GetView<LoansController> {
  const LoansView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Prêts',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.showAddLoanDialog,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loans.isEmpty) {
          return _buildEmptyState(context);
        }
        return _buildLoansList(context);
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeIn(
            child: Icon(
              Icons.account_balance_outlined,
              size: 64.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 16.h),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Aucun prêt enregistré',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Ajoutez votre premier prêt\nen appuyant sur le bouton +',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoansList(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLoansOverview(context),
          SizedBox(height: 24.h),
          Text(
            'Mes Prêts',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.loans.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final loan = controller.loans[index];
              return FadeInUp(
                delay: Duration(milliseconds: index * 100),
                child: _buildLoanCard(context, loan),
              );
            },
          )),
        ],
      ),
    );
  }

  Widget _buildLoansOverview(BuildContext context) {
    final theme = Theme.of(context);
    final activeLoans = controller.loans.where((loan) => loan['status'] == 'active').toList();
    final totalDebt = activeLoans.fold<double>(0, (sum, loan) => sum + (loan['remainingBalance'] as double));
    final monthlyPayments = activeLoans.fold<double>(0, (sum, loan) => sum + (loan['monthlyDue'] as double));

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aperçu des Prêts',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  context,
                  'Dette totale',
                  '${totalDebt.toStringAsFixed(0)} XOF',
                  Icons.account_balance_wallet_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildOverviewItem(
                  context,
                  'Paiements mensuels',
                  '${monthlyPayments.toStringAsFixed(0)} XOF',
                  Icons.calendar_month_outlined,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  context,
                  'Prêts actifs',
                  '${activeLoans.length}',
                  Icons.trending_up_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildOverviewItem(
                  context,
                  'Prêts terminés',
                  '${controller.loans.where((loan) => loan['status'] == 'completed').length}',
                  Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 20.sp,
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoanCard(BuildContext context, Map<String, dynamic> loan) {
    final theme = Theme.of(context);
    final status = loan['status'] as String;
    final isActive = status == 'active';
    final remainingBalance = loan['remainingBalance'] as double;
    final principal = loan['principal'] as double;
    final progress = isActive ? (principal - remainingBalance) / principal : 1.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActive 
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan['notes'] as String? ?? 'Prêt sans titre',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${principal.toStringAsFixed(0)} XOF à ${loan['interestRate']}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive 
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  isActive ? 'Actif' : 'Terminé',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isActive 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Progress bar
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: isActive 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solde restant',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${remainingBalance.toStringAsFixed(0)} XOF',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isActive 
                            ? theme.colorScheme.error
                            : theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive) ...[
                ElevatedButton.icon(
                  onPressed: () => _showPaymentDialog(context, loan),
                  icon: const Icon(Icons.payment_rounded, size: 16),
                  label: const Text('Payer'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                ),
              ],
            ],
          ),
          
          if (isActive && loan['nextPaymentDate'] != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Prochain paiement: ${_formatDate(loan['nextPaymentDate'] as DateTime)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, Map<String, dynamic> loan) {
    final paymentController = TextEditingController();
    final remainingBalance = loan['remainingBalance'] as double;
    final monthlyDue = loan['monthlyDue'] as double;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Effectuer un paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Solde restant: ${remainingBalance.toStringAsFixed(0)} XOF',
              style: Get.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant à payer',
                hintText: 'Montant mensuel: ${monthlyDue.toStringAsFixed(0)} XOF',
                suffixText: 'XOF',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(paymentController.text);
              if (amount != null && amount > 0) {
                controller.makePayment(loan['id'] as String, amount);
                Get.back();
              }
            },
            child: const Text('Payer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Aujourd\'hui';
    } else if (difference == 1) {
      return 'Demain';
    } else if (difference > 0) {
      return 'Dans $difference jours';
    } else {
      return 'Il y a ${-difference} jours';
    }
  }
}