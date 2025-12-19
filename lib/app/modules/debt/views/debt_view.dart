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
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
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
                    totalMonthlyPayments:
                        debtImpact['totalMonthlyDebtPayments'] ?? 0.0,
                  );
                }),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              sliver: SliverToBoxAdapter(
                child: Obx(() => _SegmentedDebtControl(
                      selectedIndex: controller.selectedTab.value,
                      onChanged: (index) =>
                          controller.selectedTab.value = index,
                    )),
              ),
            ),

            Obx(() {
              final isLentTab = controller.selectedTab.value == 0;
              final isLent = isLentTab;

              final debts = controller.debts
                  .where((d) =>
                      d.type == (isLentTab ? DebtType.lent : DebtType.borrowed))
                  .toList();

              if (debts.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: KoalaEmptyState(
                    icon: isLent
                        ? CupertinoIcons.hand_thumbsup_fill
                        : CupertinoIcons.hand_thumbsdown_fill,
                    title: isLent ? 'Aucun prêt' : 'Aucune dette',
                    message: isLent
                        ? 'Vous n\'avez prêté d\'argent à personne pour le moment.'
                        : 'Vous n\'avez aucune dette en cours. Bravo !',
                    buttonText:
                        isLent ? 'Ajouter un prêt' : 'Ajouter une dette',
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
    final selectedType =
        (controller.selectedTab.value == 0 ? DebtType.lent : DebtType.borrowed)
            .obs;

    Get.bottomSheet(
      KoalaBottomSheet(
        title: 'Ajouter une dette/prêt',
        // icon: CupertinoIcons.money_dollar_circle_fill, // Optional if allowed by constructor, checking usage
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              24.w, 0, 24.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: KoalaColors.inputBackground(context),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    _buildTypeOption(context, 'Prêt (On me doit)',
                        DebtType.lent, KoalaColors.success, selectedType),
                    _buildTypeOption(
                        context,
                        'Dette (Je dois)',
                        DebtType.borrowed,
                        KoalaColors.destructive,
                        selectedType),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text('Personne', style: KoalaTypography.caption(context)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: nameController,
                style: KoalaTypography.bodyLarge(context),
                decoration: InputDecoration(
                  prefixIcon: Icon(CupertinoIcons.person_fill,
                      color: KoalaColors.textSecondary(context)),
                  filled: true,
                  fillColor: KoalaColors.inputBackground(context),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 16.h),
              Text('Montant', style: KoalaTypography.caption(context)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: KoalaTypography.heading2(context),
                decoration: InputDecoration(
                  prefixIcon: Icon(CupertinoIcons.money_dollar,
                      color: KoalaColors.textSecondary(context)),
                  suffixText: 'FCFA',
                  filled: true,
                  fillColor: KoalaColors.inputBackground(context),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 16.h),
              Text('Paiement mensuel min.',
                  style: KoalaTypography.caption(context)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: minPaymentController,
                keyboardType: TextInputType.number,
                style: KoalaTypography.bodyLarge(context),
                decoration: InputDecoration(
                  prefixIcon: Icon(CupertinoIcons.calendar_badge_minus,
                      color: KoalaColors.textSecondary(context)),
                  suffixText: 'FCFA',
                  filled: true,
                  fillColor: KoalaColors.inputBackground(context),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: KoalaButton(
                      text: 'Annuler',
                      backgroundColor: KoalaColors.inputBackground(context),
                      textColor: KoalaColors.textSecondary(context),
                      onPressed: () => NavigationHelper.safeBack(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: KoalaButton(
                      text: 'Ajouter',
                      // Use success or destructive based on type? Or just primary black. Primary black is safe.
                      onPressed: () {
                        if (nameController.text.isEmpty ||
                            amountController.text.isEmpty) {
                          Get.snackbar('Erreur',
                              'Veuillez remplir tous les champs obligatoires');
                          return;
                        }

                        controller.addDebt(
                          personName: nameController.text,
                          amount: double.tryParse(amountController.text) ?? 0,
                          type: selectedType.value,
                          dueDate: dueDate.value,
                          minPayment:
                              double.tryParse(minPaymentController.text) ?? 0,
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
      isScrollControlled: true,
    );
  }

  Widget _buildTypeOption(BuildContext context, String label, DebtType type,
      Color color, Rx<DebtType> selectedType) {
    return Expanded(
      child: GestureDetector(
        onTap: () => selectedType.value = type,
        child: Obx(() {
          final isSelected = selectedType.value == type;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? KoalaColors.surface(context)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: isSelected ? KoalaColors.shadowSubtle : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : KoalaColors.textSecondary(context),
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
  final double totalMonthlyPayments;

  const _DebtSummaryCard({
    required this.totalLent,
    required this.totalBorrowed,
    required this.totalMonthlyPayments,
  });

  @override
  Widget build(BuildContext context) {
    final net = totalLent - totalBorrowed;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: KoalaColors.shadowMedium,
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Column(
        children: [
          Text(
            'Position Nette',
            style: KoalaTypography.caption(context),
          ),
          SizedBox(height: 8.h),
          Text(
            NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(net),
            style: KoalaTypography.heading2(context).copyWith(
              color: net >= 0 ? KoalaColors.success : KoalaColors.destructive,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Paiements Mensuels Totaux: ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA').format(totalMonthlyPayments)}',
            style: KoalaTypography.bodySmall(context),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'À recevoir',
                  amount: totalLent,
                  color: KoalaColors.success,
                  icon: CupertinoIcons.arrow_down_left,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: KoalaColors.border(context),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'À payer',
                  amount: totalBorrowed,
                  color: KoalaColors.destructive,
                  icon: CupertinoIcons.arrow_up_right,
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

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
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
              style: KoalaTypography.caption(context),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          NumberFormat.compact(locale: 'fr_FR').format(amount),
          style: KoalaTypography.heading4(context),
        ),
      ],
    );
  }
}

class _SegmentedDebtControl extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const _SegmentedDebtControl(
      {required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: KoalaColors.inputBackground(context),
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

  const _SegmentButton(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color:
                isSelected ? KoalaColors.surface(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isSelected ? KoalaColors.shadowSubtle : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: isSelected
                ? KoalaTypography.bodyMedium(context)
                    .copyWith(fontWeight: FontWeight.bold)
                : KoalaTypography.bodyMedium(context)
                    .copyWith(color: KoalaColors.textSecondary(context)),
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
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.back,
                size: 28, color: KoalaColors.text(context)),
            onPressed: () => NavigationHelper.safeBack(),
            padding: EdgeInsets.zero,
          ).animate().fadeIn().slideX(begin: -0.1),
          Text(
            'Dettes & Prêts',
            style: KoalaTypography.heading3(context),
          ).animate().fadeIn(),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: KoalaColors.surface(context),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: KoalaColors.shadowSubtle,
              ),
              child: Icon(CupertinoIcons.add,
                  size: 20.sp, color: KoalaColors.text(context)),
            ),
          ).animate().fadeIn().slideX(begin: 0.1),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final Debt debt;

  const _DebtCard({required this.debt});

  @override
  Widget build(BuildContext context) {
    final isLent = debt.type == DebtType.lent;
    final accentColor = isLent ? KoalaColors.success : KoalaColors.destructive;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: KoalaColors.shadowSubtle,
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
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
          style: KoalaTypography.heading4(context),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (debt.dueDate != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  'Échéance: ${DateFormat('dd MMM').format(debt.dueDate ?? DateTime.now())}',
                  style: KoalaTypography.caption(context),
                ),
              ),
            if (debt.minPayment > 0)
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  'Mensualité: ${NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0).format(debt.minPayment)}',
                  style: KoalaTypography.caption(context),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormat.currency(
                      locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0)
                  .format(debt.remainingAmount),
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            if (debt.remainingAmount < debt.originalAmount)
              Text(
                'sur ${NumberFormat.compact(locale: 'fr_FR').format(debt.originalAmount)}',
                style:
                    KoalaTypography.caption(context).copyWith(fontSize: 10.sp),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutQuart);
  }
}


