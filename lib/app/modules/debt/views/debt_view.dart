import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/modules/debt/controllers/debt_controller.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

class DebtView extends GetView<DebtController> {
  const DebtView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              sliver: SliverToBoxAdapter(
                child: _Header(onAddTap: () => _showAddDebtSheet(context)),
              ),
            ),
            
            // Summary Card
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  final debtImpact = controller.getDebtImpact();
                  final totalLent = controller.debts
                      .where((d) => d.type == DebtType.lent)
                      .fold(0.0, (sum, d) => sum + d.remainingAmount);
                  final totalBorrowed = controller.debts
                      .where((d) => d.type == DebtType.borrowed)
                      .fold(0.0, (sum, d) => sum + d.remainingAmount);
                  
                  return _DebtSummaryCard(
                    totalLent: totalLent,
                    totalBorrowed: totalBorrowed,
                    totalMonthlyPayments: debtImpact['totalMonthlyDebtPayments'] ?? 0.0,
                  );
                }),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              sliver: SliverToBoxAdapter(
                child: Obx(() => _SegmentedDebtControl(
                  selectedIndex: controller.selectedTab.value,
                  onChanged: (index) => controller.selectedTab.value = index,
                )),
              ),
            ),

            Obx(() {
              final isLentTab = controller.selectedTab.value == 0;
              final isLent = isLentTab; // Define isLent here

              final debts = controller.debts
                  .where((d) => d.type == (isLentTab ? DebtType.lent : DebtType.borrowed))
                  .toList();

              if (debts.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: KoalaEmptyState(
                    icon: isLent ? CupertinoIcons.hand_thumbsup_fill : CupertinoIcons.hand_thumbsdown_fill,
                    title: isLent ? 'Aucun prêt' : 'Aucune dette',
                    message: isLent 
                        ? 'Vous n\'avez prêté d\'argent à personne pour le moment.'
                        : 'Vous n\'avez aucune dette en cours. Bravo !',
                    buttonText: isLent ? 'Ajouter un prêt' : 'Ajouter une dette',
                    onButtonPressed: () => _showAddDebtSheet(context),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _DebtCard(debt: debts[index]),
                    childCount: debts.length,
                  ),
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  void _showAddDebtSheet(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final minPaymentController = TextEditingController();
    final dueDate = DateTime.now().add(const Duration(days: 30)).obs;
    final selectedType = (controller.selectedTab.value == 0 ? DebtType.lent : DebtType.borrowed).obs;

    Get.bottomSheet(
      KoalaBottomSheet(
        title: 'Ajouter une dette/prêt',
        icon: CupertinoIcons.money_dollar_circle_fill,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      _buildTypeOption(context, 'Prêt (On me doit)', DebtType.lent, Colors.green, selectedType),
                      _buildTypeOption(context, 'Dette (Je dois)', DebtType.borrowed, Colors.red, selectedType),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                KoalaTextField(
                  controller: nameController,
                  label: 'Personne',
                  icon: CupertinoIcons.person_fill,
                ),
                SizedBox(height: 16.h),
                KoalaTextField(
                  controller: amountController,
                  label: 'Montant',
                  icon: CupertinoIcons.money_dollar,
                  keyboardType: TextInputType.number,
                  isAmount: true,
                ),
                SizedBox(height: 16.h),
                KoalaTextField(
                  controller: minPaymentController,
                  label: 'Paiement mensuel min.',
                  icon: CupertinoIcons.calendar_badge_minus,
                  keyboardType: TextInputType.number,
                  isAmount: true,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: KoalaButton(
                        text: 'Annuler',
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        textColor: Colors.grey,
                        onPressed: () => NavigationHelper.safeBack(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: KoalaButton(
                        text: 'Ajouter',
                        onPressed: () {
                           if (nameController.text.isEmpty || amountController.text.isEmpty) {
                             Get.snackbar('Erreur', 'Veuillez remplir tous les champs obligatoires');
                             return;
                           }
                           
                           controller.addDebt(
                             personName: nameController.text,
                             amount: double.tryParse(amountController.text) ?? 0,
                             type: selectedType.value,
                             dueDate: dueDate.value,
                             minPayment: double.tryParse(minPaymentController.text) ?? 0,
                           );
                           NavigationHelper.safeBack();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTypeOption(BuildContext context, String label, DebtType type, Color color, Rx<DebtType> selectedType) {
    return Expanded(
      child: GestureDetector(
        onTap: () => selectedType.value = type,
        child: Obx(() {
          final isSelected = selectedType.value == type;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: isSelected ? [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
              ] : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DebtSummaryCard extends StatelessWidget {
  final double totalLent;
  final double totalBorrowed;
  final double totalMonthlyPayments; // New parameter

  const _DebtSummaryCard({
    required this.totalLent,
    required this.totalBorrowed,
    required this.totalMonthlyPayments,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final net = totalLent - totalBorrowed;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Position Nette',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(net),
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF2D3250),
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 16.h),
          // Display total monthly payments
          Text(
            'Paiements Mensuels Totaux: ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(totalMonthlyPayments)}',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'À recevoir',
                  amount: totalLent,
                  color: Colors.green,
                  icon: CupertinoIcons.arrow_down_left,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: isDark ? Colors.white10 : Colors.grey.shade200,
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'À payer',
                  amount: totalBorrowed,
                  color: Colors.red,
                  icon: CupertinoIcons.arrow_up_right,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          NumberFormat.compact().format(amount),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2D3250),
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }
}

class _SegmentedDebtControl extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const _SegmentedDebtControl({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _SegmentButton(
            label: 'On me doit',
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _SegmentButton(
            label: 'Je dois',
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAddTap;

  const _Header({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.back, size: 28, color: theme.textTheme.bodyLarge?.color),
            onPressed: () => NavigationHelper.safeBack(),
            padding: EdgeInsets.zero,
          ).animate().fadeIn().slideX(begin: -0.1),
          Text(
            'Dettes & Prêts',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ).animate().fadeIn(),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(CupertinoIcons.add, size: 20.sp, color: theme.textTheme.bodyLarge?.color),
            ),
          ).animate().fadeIn().slideX(begin: 0.1),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 1.5,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final Debt debt;

  const _DebtCard({required this.debt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLent = debt.type == DebtType.lent;
    
    final accentColor = isLent ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
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
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: Text(
              debt.personName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
          ),
        ),
        title: Text(
          debt.personName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (debt.dueDate != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  'Échéance: ${DateFormat('dd MMM').format(debt.dueDate ?? DateTime.now())}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.sp),
                ),
              ),
            if (debt.minPayment > 0)
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  'Mensualité: ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0).format(debt.minPayment)}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.sp),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0).format(debt.remainingAmount),
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            if (debt.remainingAmount < debt.originalAmount)
              Text(
                'sur ${NumberFormat.compact().format(debt.originalAmount)}',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart);
  }
}
