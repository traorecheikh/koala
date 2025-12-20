import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/ml/financial_pattern.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';
import 'package:koaa/app/data/models/local_transaction.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SUGGESTION WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class DetectedSubscriptionsSection
    extends GetView<RecurringTransactionsController> {
  const DetectedSubscriptionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final suggestions = controller.detectedSubscriptions;
      if (suggestions.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(CupertinoIcons.sparkles,
                    color: KoalaColors.primaryUi(context), size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  'SUGGESTIONS',
                  style: KoalaTypography.caption(context).copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: KoalaColors.primaryUi(context),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 150.h,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: _SuggestionCard(suggestion: suggestions[index]),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _SuggestionCard extends GetView<RecurringTransactionsController> {
  final FinancialPattern suggestion;

  const _SuggestionCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    // Parse potential amount
    final amount = double.tryParse(suggestion.parameters['amount'] ?? '0') ?? 0;
    final name =
        suggestion.description.replaceAll('Paiement mensuel probable: ', '');

    return Container(
      width: 200.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.lg),
        border: Border.all(
            color: KoalaColors.primaryUi(context).withValues(alpha: 0.3)),
        boxShadow: KoalaShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: KoalaColors.primaryUi(context).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(CupertinoIcons.question,
                    color: KoalaColors.primaryUi(context), size: 18.sp),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => controller.ignoreSubscription(suggestion),
                child: Icon(CupertinoIcons.xmark,
                    color: KoalaColors.textSecondary(context), size: 18.sp),
              ),
            ],
          ),
          const Spacer(),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KoalaTypography.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '~${NumberFormat('#,###', 'fr_FR').format(amount)} FCFA/mois',
            style: KoalaTypography.caption(context).copyWith(
              color: KoalaColors.textSecondary(context),
            ),
          ),
          SizedBox(height: 12.h),
          KoalaButton(
            text: 'Ajouter',
            onPressed: () {
              // Open form pre-filled
              final day =
                  int.tryParse(suggestion.parameters['avgDay'] ?? '1') ?? 1;
              _showAddForm(context, name, amount, day);
            },
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  void _showAddForm(BuildContext context, String name, double amount, int day) {
    final amountController =
        TextEditingController(text: amount.toStringAsFixed(0));
    final dayController = TextEditingController(text: day.toString());
    final nameController = TextEditingController(text: name);

    Get.bottomSheet(
      KoalaBottomSheet(
        title: 'Confirmer l\'abonnement',
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Input
              TextField(
                controller: nameController,
                style: KoalaTypography.bodyMedium(context),
                decoration: InputDecoration(
                  labelText: 'Nom du service',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KoalaRadius.md),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Amount Input
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: KoalaTypography.bodyMedium(context),
                decoration: InputDecoration(
                  labelText: 'Montant mensuel (FCFA)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KoalaRadius.md),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Day of Month
              TextField(
                controller: dayController,
                keyboardType: TextInputType.number,
                style: KoalaTypography.bodyMedium(context),
                decoration: InputDecoration(
                  labelText: 'Jour de prelevement (1-28)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KoalaRadius.md),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              KoalaButton(
                text: 'Confirmer',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final finalAmount =
                      double.tryParse(amountController.text) ?? 0;
                  final finalDay = int.tryParse(dayController.text) ?? 1;
                  final finalName = nameController.text.trim();

                  if (finalAmount > 0 && finalName.isNotEmpty) {
                    controller.addRecurringTransaction(
                      RecurringTransaction.create(
                        amount: finalAmount,
                        description: finalName,
                        frequency: Frequency.monthly,
                        dayOfMonth: finalDay.clamp(1, 28),
                        lastGeneratedDate:
                            DateTime.now().subtract(const Duration(days: 1)),
                        category: TransactionCategory.entertainment,
                        type: TransactionType.expense,
                        categoryId: 'subscription_custom', // Use custom ID
                      ),
                    );
                    // Also ignore the suggestion so it doesn't show up again
                    controller.ignoreSubscription(suggestion);

                    NavigationHelper.safeBack();
                    Get.snackbar(
                      'Abonnement ajouté',
                      '$finalName - ${NumberFormat('#,###', 'fr_FR').format(finalAmount)} FCFA/mois',
                      backgroundColor: KoalaColors.success,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      margin: EdgeInsets.all(16.w),
                    );
                  }
                },
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => NavigationHelper.safeBack(),
                child: Text(
                  'Annuler',
                  style: KoalaTypography.bodyMedium(context).copyWith(
                    color: KoalaColors.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
