import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/design_system.dart'; // Import Design System
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/modules/budget/controllers/budget_controller.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/routes/app_pages.dart';

class BudgetView extends GetView<BudgetController> {
  const BudgetView({super.key});

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
                child: _Header(onAddTap: () => _showAddBudgetSheet(context)),
              ),
            ),

            // Global Budget Health Ring
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  final budgetsList = controller.budgets.toList();
                  if (budgetsList.isEmpty) return const SizedBox.shrink();

                  double totalBudget = 0;
                  double totalSpent = 0;
                  for (var b in budgetsList) {
                    totalBudget += b.amount;
                    totalSpent += controller.getSpentAmount(b.categoryId);
                  }

                  return _GlobalBudgetCard(
                      totalBudget: totalBudget, totalSpent: totalSpent);
                }),
              ),
            ),

            Obx(() {
              final budgetsList = controller.budgets.toList();
              if (budgetsList.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: KoalaEmptyState(
                    icon: CupertinoIcons.chart_pie,
                    title: 'Aucun budget défini',
                    message:
                        'Commencez par créer un budget pour mieux gérer vos dépenses.',
                    buttonText: 'Créer un budget',
                    onButtonPressed: () => _showAddBudgetSheet(context),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final budget = budgetsList[index];
                      final category =
                          controller.getCategory(budget.categoryId);
                      return _BudgetCard(budget: budget, category: category)
                          .animate(delay: (50 * index).ms) // Stagger
                          .fadeIn(duration: KoalaAnim.medium)
                          .slideY(begin: 0.1, curve: KoalaAnim.entryCurve);
                    },
                    childCount: budgetsList.length,
                  ),
                ),
              );
            }),

            const SliverToBoxAdapter(
                child: SizedBox(height: 80)), // Bottom padding
          ],
        ),
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    Rx<Category?> selectedCategory = Rx<Category?>(null);

    Get.bottomSheet(
      KoalaBottomSheet(
        title: 'Nouveau Budget',
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              24.w, 0, 24.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Text('Catégorie', style: KoalaTypography.caption(context)),
                SizedBox(height: 8.h),
                Obx(() => DropdownButtonFormField<Category>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: KoalaColors.inputBackground(context),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                      ),
                      hint: Text('Choisir une catégorie',
                          style: KoalaTypography.bodyMedium(context)),
                      initialValue: selectedCategory.value,
                      onChanged: (Category? newValue) {
                        selectedCategory.value = newValue;
                        if (newValue != null) {
                          final suggested =
                              controller.getSuggestedBudget(newValue.id);
                          amountController.text = suggested.toStringAsFixed(0);
                        }
                      },
                      items: controller.categories
                          .where((c) => c.type == TransactionType.expense)
                          .map<DropdownMenuItem<Category>>((Category cat) {
                        return DropdownMenuItem<Category>(
                          value: cat,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: Color(cat.colorValue).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: CategoryIcon(
                                    iconKey: cat.icon, size: 18.sp),
                              ),
                              SizedBox(width: 12.w),
                              Text(cat.name,
                                  style: KoalaTypography.bodyMedium(context)),
                            ],
                          ),
                        );
                      }).toList(),
                      validator: (value) => value == null ? 'Requis' : null,
                    )),
                SizedBox(height: 24.h),
                Text('Limite mensuelle',
                    style: KoalaTypography.caption(context)),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: KoalaTypography.heading2(context),
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: 'FCFA',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: KoalaColors.inputBackground(context),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requis';
                    if (double.tryParse(value) == null) return 'Invalide';
                    return null;
                  },
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: KoalaButton(
                    text: 'Sauvegarder',
                    onPressed: () {
                      if (formKey.currentState!.validate() &&
                          selectedCategory.value != null) {
                        controller.addBudget(
                          selectedCategory.value!.id,
                          double.parse(amountController.text),
                        );
                        NavigationHelper.safeBack();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _GlobalBudgetCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;

  const _GlobalBudgetCard({
    required this.totalBudget,
    required this.totalSpent,
  });

  // Get gradient based on budget status
  LinearGradient _getStatusGradient(double percent) {
    if (percent >= 1.0) {
      return const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (percent >= 0.8) {
      return const LinearGradient(
        colors: [Color(0xFFFFAB5E), Color(0xFFFF8C42)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF56AB91), Color(0xFF3E8E7E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent =
        totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final remaining = totalBudget - totalSpent;

    String statusMessage;
    IconData statusIcon;

    if (totalBudget == 0) {
      statusMessage = 'Aucun budget défini';
      statusIcon = CupertinoIcons.chart_pie;
    } else if (percent >= 1.0) {
      statusMessage = 'Budget dépassé';
      statusIcon = CupertinoIcons.exclamationmark_triangle_fill;
    } else if (percent >= 0.8) {
      statusMessage = 'Attention requise';
      statusIcon = CupertinoIcons.exclamationmark_circle_fill;
    } else {
      statusMessage = 'Tout va bien';
      statusIcon = CupertinoIcons.checkmark_seal_fill;
    }

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: _getStatusGradient(percent),
        boxShadow: KoalaColors.shadowMedium,
      ),
      child: Stack(
        children: [
          // Animated floating particles
          ...List.generate(5, (index) {
            return Positioned(
              left: (index * 70.0).w,
              top: (index * 35.0).h,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  CupertinoIcons.sparkles,
                  size: 28.sp,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: 2000.ms, delay: (index * 400).ms)
                  .fadeOut(duration: 2000.ms, delay: (2000 + index * 400).ms),
            );
          }),

          // Main content
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Row(
              children: [
                // Left side: Circular progress indicator
                SizedBox(
                  width: 120.w,
                  height: 120.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      SizedBox(
                        width: 100.w,
                        height: 100.w,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 10.w,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(
                              Colors.white.withOpacity(0.2)),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      // Progress circle
                      SizedBox(
                        width: 100.w,
                        height: 100.w,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: percent),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 10.w,
                              backgroundColor: Colors.transparent,
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                              strokeCap: StrokeCap.round,
                            );
                          },
                        ),
                      ),
                      // Percentage text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<int>(
                            tween: IntTween(
                                begin: 0, end: (percent * 100).toInt()),
                            duration: const Duration(milliseconds: 1000),
                            builder: (context, value, _) {
                              return Text(
                                '$value%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          Text(
                            'utilisé',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 20.w),

                // Right side: Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status row
                      Row(
                        children: [
                          Icon(statusIcon, color: Colors.white, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            statusMessage,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Remaining amount (big)
                      Text(
                        remaining >= 0 ? 'Reste' : 'Dépassement',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: remaining.abs()),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOut,
                        builder: (context, value, _) {
                          return Text(
                            '${NumberFormat.compact(locale: 'fr_FR').format(value)} FCFA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 12.h),

                      // Spent / Budget row with glassmorphic background
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              NumberFormat.compact(locale: 'fr_FR').format(totalSpent),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' / ${NumberFormat.compact(locale: 'fr_FR').format(totalBudget)} F',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: KoalaAnim.medium).scale(
        delay: 100.ms, duration: KoalaAnim.medium, curve: KoalaAnim.entryCurve);
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
            'Mes Enveloppes',
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
          ).animate().fadeIn().slideX(begin: 0.1), // Add button
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final Category? category;

  const _BudgetCard({required this.budget, this.category});

  String _formatAmount(double amount) {
    return NumberFormat.compact(locale: 'fr_FR').format(amount.round());
  }

  @override
  Widget build(BuildContext context) {
    final budgetController = Get.find<BudgetController>();
    final spent = budgetController.getSpentAmount(budget.categoryId);
    final percent =
        budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;
    final remaining = budget.amount - spent;
    final budgetStatus = budgetController.getBudgetStatus(
        budget.categoryId, budget.year, budget.month);

    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (budgetStatus) {
      case BudgetStatus.safe:
        statusColor = KoalaColors.success;
        statusBgColor = KoalaColors.success.withOpacity(0.1);
        statusIcon = CupertinoIcons.checkmark_circle_fill;
        break;
      case BudgetStatus.warning:
        statusColor = KoalaColors.warning;
        statusBgColor = KoalaColors.warning.withOpacity(0.1);
        statusIcon = CupertinoIcons.exclamationmark_circle_fill;
        break;
      case BudgetStatus.exceeded:
      case BudgetStatus.critical:
        statusColor = KoalaColors.destructive;
        statusBgColor = KoalaColors.destructive.withOpacity(0.1);
        statusIcon = CupertinoIcons.exclamationmark_triangle_fill;
        break;
    }

    final categoryColor = Color(category?.colorValue ?? Colors.grey.value);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: KoalaColors.border(context)),
        boxShadow: KoalaColors.shadowSubtle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Top row: Category + Amount
                Row(
                  children: [
                    // Category icon
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Center(
                        child: CategoryIcon(
                          iconKey: category?.icon ?? 'other',
                          size: 22.sp,
                          useOriginalColor: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Category name + status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category?.name ?? 'Inconnu',
                            style: KoalaTypography.heading4(context),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(statusIcon, size: 12.sp, color: statusColor),
                              SizedBox(width: 4.w),
                              Text(
                                '${(percent * 100).toInt()}% utilisé',
                                style: KoalaTypography.bodySmall(context)
                                    .copyWith(color: statusColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Amount remaining
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        remaining >= 0
                            ? '${_formatAmount(remaining)} F'
                            : '-${_formatAmount(remaining.abs())} F',
                        style: KoalaTypography.bodyMedium(context).copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Progress bar
                Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: KoalaColors.background(context),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: percent.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                // Bottom row: Spent / Budget
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dépensé: ${_formatAmount(spent)} F',
                      style: KoalaTypography.caption(context),
                    ),
                    Text(
                      'Budget: ${_formatAmount(budget.amount)} F',
                      style: KoalaTypography.caption(context),
                    ),
                  ],
                ),

                // Action link for exceeded budgets
                if (budgetStatus == BudgetStatus.exceeded ||
                    budgetStatus == BudgetStatus.critical)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: InkWell(
                      onTap: () => Get.toNamed(Routes.goals),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.h, horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.lightbulb_fill,
                                size: 14.sp, color: statusColor),
                            SizedBox(width: 6.w),
                            Text(
                              'Créer un objectif de réduction',
                              style: KoalaTypography.caption(context).copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, curve: Curves.easeOutQuart);
  }
}
