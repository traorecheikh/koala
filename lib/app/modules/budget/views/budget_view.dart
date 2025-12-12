import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/budget/controllers/budget_controller.dart';

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
                  if (controller.budgets.isEmpty) return const SizedBox.shrink();
                  
                  double totalBudget = 0;
                  double totalSpent = 0;
                  for (var b in controller.budgets) {
                    totalBudget += b.amount;
                    totalSpent += controller.getSpentAmount(b.categoryId);
                  }
                  
                  return _GlobalBudgetCard(totalBudget: totalBudget, totalSpent: totalSpent);
                }),
              ),
            ),

            Obx(() {
              if (controller.budgets.isEmpty) {
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
                      final budget = controller.budgets[index];
                      final category = controller.getCategory(budget.categoryId);
                      return _BudgetCard(budget: budget, category: category);
                    },
                    childCount: controller.budgets.length,
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
                      Get.back();
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

  const _GlobalBudgetCard({required this.totalBudget, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percent = (totalSpent / (totalBudget > 0 ? totalBudget : 1)).clamp(0.0, 1.0);
    final remaining = totalBudget - totalSpent;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF1A1B1E), const Color(0xFF2C3E50)] 
              : [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
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
                        percent > 1.0 ? Colors.redAccent : Colors.white,
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
                  'Budget Global',
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
            icon: Icon(CupertinoIcons.back, size: 28, color: theme.textTheme.bodyLarge?.color),
            onPressed: () => Get.back(),
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

class _BudgetCard extends StatelessWidget { // Changed to StatelessWidget
  final Budget budget;
  final Category? category; // Pass category directly

  const _BudgetCard({required this.budget, this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // final category = controller.getCategory(budget.categoryId); // No longer needed
    final spent = Get.find<BudgetController>().getSpentAmount(budget.categoryId); // Access controller method
    final percent = (spent / budget.amount).clamp(0.0, 1.0);
    final remaining = budget.amount - spent;

    // Logic: Status Colors
    Color statusColor;
    if (percent >= 1.0) {
      statusColor = Colors.red;
    } else if (percent > 0.8) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
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
                          Text(
                            '${(percent * 100).toStringAsFixed(0)}% utilisé',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          remaining >= 0
                              ? 'Reste: ${NumberFormat.compact().format(remaining)} F'
                              : 'Dépassement',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0).format(budget.amount),
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
                // Progress Bar (simple, elegant)
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
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart);
  }
}