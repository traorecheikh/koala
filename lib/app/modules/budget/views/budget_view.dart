import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/modules/budget/controllers/budget_controller.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/data/models/local_transaction.dart'; // Added for TransactionType
import 'package:koaa/app/routes/app_pages.dart'; // Added for Routes

class BudgetView extends GetView<BudgetController> {
  const BudgetView({super.key});

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
                child: _Header(onAddTap: () => _showAddBudgetSheet(context)),
              ),
            ),
            
            // Global Budget Health Ring
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  // FIX: Create immutable snapshot to prevent concurrent modification
                  final budgetsList = controller.budgets.toList();
                  if (budgetsList.isEmpty) return const SizedBox.shrink();

                  double totalBudget = 0;
                  double totalSpent = 0;
                  // Iterate over snapshot, not reactive list
                  for (var b in budgetsList) {
                    totalBudget += b.amount;
                    totalSpent += controller.getSpentAmount(b.categoryId);
                  }

                  return _GlobalBudgetCard(totalBudget: totalBudget, totalSpent: totalSpent);
                }),
              ),
            ),

            Obx(() {
              // FIX: Create immutable snapshot to prevent concurrent modification
              final budgetsList = controller.budgets.toList();
              if (budgetsList.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.chart_pie_fill, size: 48.sp, color: Colors.grey.withOpacity(0.5)),
                        SizedBox(height: 16.h),
                        Text(
                          'Aucun budget défini',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: 24.h),
                        CupertinoButton.filled(
                          onPressed: () => _showAddBudgetSheet(context),
                          child: const Text('Créer un budget'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Use snapshot instead of reactive list
                      final budget = budgetsList[index];
                      final category = controller.getCategory(budget.categoryId);
                      return _BudgetCard(budget: budget, category: category);
                    },
                    childCount: budgetsList.length,
                  ),
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding
          ],
        ),
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    Rx<Category?> selectedCategory = Rx<Category?>(null);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Nouveau Budget',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Catégorie',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Obx(() => DropdownButtonFormField<Category>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF2F2F7),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                ),
                hint: const Text('Choisir une catégorie'),
                value: selectedCategory.value,
                onChanged: (Category? newValue) {
                  selectedCategory.value = newValue;
                  if (newValue != null) {
                    final suggested = controller.getSuggestedBudget(newValue.id);
                    amountController.text = suggested.toStringAsFixed(0);
                  }
                },
                items: controller.categories
                    .where((c) => c.type == TransactionType.expense) // Budgets typically for expenses
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
                          child: CategoryIcon(iconKey: cat.icon, size: 18.sp),
                        ),
                        SizedBox(width: 12.w),
                        Text(cat.name),
                      ],
                    ),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Requis' : null,
              )),
              SizedBox(height: 24.h),
              Text(
                'Limite mensuelle',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF2F2F7),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                child: CupertinoButton.filled(
                  onPressed: () {
                    if (formKey.currentState!.validate() && selectedCategory.value != null) {
                      controller.addBudget(
                        selectedCategory.value!.id,
                        double.parse(amountController.text),
                      );
                      NavigationHelper.safeBack();
                    }
                  },
                  child: const Text('Sauvegarder'),
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

class _GlobalBudgetCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;

  const _GlobalBudgetCard({
    required this.totalBudget,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Logic using passed parameters - handle zero budget specially
    final percent = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final remaining = totalBudget - totalSpent;

    Color gradientStartColor = isDark ? const Color(0xFF1A1B1E) : const Color(0xFF6C5CE7);
    Color gradientEndColor = isDark ? const Color(0xFF2C3E50) : const Color(0xFFA29BFE);
    Color progressColor = Colors.white;
    String statusMessage = totalBudget == 0 ? 'Aucun budget' : 'Budget mensuel';

    if (totalBudget == 0) {
      // No budget set - neutral state
      gradientStartColor = isDark ? const Color(0xFF1A1B1E) : Colors.grey.shade600;
      gradientEndColor = isDark ? const Color(0xFF2C3E50) : Colors.grey.shade400;
      progressColor = Colors.grey;
    } else if (percent >= 1.0) {
      gradientStartColor = Colors.red.shade700;
      gradientEndColor = Colors.red.shade400;
      progressColor = Colors.redAccent;
      statusMessage = 'Dépassement Budgétaire';
    } else if (percent >= 0.8) {
      gradientStartColor = Colors.orange.shade700;
      gradientEndColor = Colors.orange.shade400;
      progressColor = Colors.orangeAccent;
      statusMessage = 'Proche de la limite';
    }

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStartColor, gradientEndColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 80.w,
            width: 80.w,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    height: 80.w,
                    width: 80.w,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 8.w,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation(
                        progressColor,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${(percent * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusMessage,
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  remaining >= 0
                      ? 'Reste: ${NumberFormat.compact().format(remaining)} F'
                      : 'Dépassement: ${NumberFormat.compact().format(remaining.abs())} F',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'sur ${NumberFormat.compact().format(totalBudget)} F prévus',
                  style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
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
            icon: Icon(CupertinoIcons.back, size: 28, color: theme.iconTheme.color),
            onPressed: () => NavigationHelper.safeBack(),
            padding: EdgeInsets.zero,
          ).animate().fadeIn().slideX(begin: -0.1),
          Text(
            'Mes Enveloppes',
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
    return NumberFormat('#,###', 'fr_FR').format(amount.round());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final budgetController = Get.find<BudgetController>();

    final spent = budgetController.getSpentAmount(budget.categoryId);
    // FIX: Handle division by zero - if budget is 0, percent should be 0
    final percent = budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;
    final remaining = budget.amount - spent;

    // Get budget status and trend with null safety
    final budgetStatus = budgetController.getBudgetStatus(budget.categoryId, budget.year, budget.month);
    final budgetTrend = budgetController.getBudgetTrend(budget.categoryId);

    Color statusColor;
    String statusText;
    switch (budgetStatus) {
      case BudgetStatus.safe:
        statusColor = Colors.green;
        statusText = 'En sécurité';
        break;
      case BudgetStatus.warning:
        statusColor = Colors.orange;
        statusText = 'Attention';
        break;
      case BudgetStatus.exceeded:
      case BudgetStatus.critical: // Assuming critical is similar to exceeded for display
        statusColor = Colors.red;
        statusText = 'Dépassement';
        break;
    }

    String trendText;
    IconData trendIcon;
    switch (budgetTrend) {
      case Trend.improving:
        trendText = 'Amélioration';
        trendIcon = CupertinoIcons.arrow_up;
        break;
      case Trend.worsening:
        trendText = 'Détérioration';
        trendIcon = CupertinoIcons.arrow_down;
        break;
      case Trend.stable:
      default:
        trendText = 'Stable';
        trendIcon = CupertinoIcons.minus;
        break;
    }

    final categoryColor = Color(category?.colorValue ?? Colors.grey.value);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? theme.scaffoldBackgroundColor.withOpacity(0.8) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // Detail view could go here
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: CategoryIcon(
                          iconKey: category?.icon ?? 'other',
                          size: 24.sp,
                          useOriginalColor: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category?.name ?? 'Inconnu',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(trendIcon, size: 13.sp, color: statusColor),
                              Text(
                                trendText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
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
                          remaining >= 0
                              ? 'Reste: ${_formatAmount(remaining)} F'
                              : 'Dépassement: ${_formatAmount(remaining.abs())} F',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'sur ${_formatAmount(budget.amount)} F prévus',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Progress Bar
                Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: percent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
                if (budgetStatus == BudgetStatus.exceeded || budgetStatus == BudgetStatus.critical)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: InkWell(
                      onTap: () {
                        // In a real app, pass categoryId to pre-fill the goal
                        Get.toNamed(Routes.goals); 
                      },
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.arrow_right_circle_fill, size: 16.sp, color: statusColor),
                          SizedBox(width: 4.w),
                          Text(
                            'Créer un objectif de réduction',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart);
  }
}