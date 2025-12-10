// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/modules/analytics/controllers/analytics_controller.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Revenus & Épargne', 
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add_circled_solid, color: Colors.black),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddJobDialog(context, theme);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          children: [
            _buildTimeRangeSelector(theme),
            SizedBox(height: 16.h),
            Obx(() => controller.selectedTimeRange.value != TimeRange.all 
                ? _buildMonthNavigator(theme) 
                : const SizedBox.shrink()),
            if (controller.selectedTimeRange.value != TimeRange.all) SizedBox(height: 24.h),
            Obx(() => _buildMonthlySummary(theme)),
            SizedBox(height: 20.h),
            Obx(() => _buildSavingsGoalCard(theme)),
            SizedBox(height: 20.h),
            Obx(() => _buildJobsSection(theme)),
            SizedBox(height: 20.h),
            Obx(() => _buildCategoryCard(theme)),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Obx(() => CupertinoSlidingSegmentedControl<TimeRange>(
        groupValue: controller.selectedTimeRange.value,
        children: {
          TimeRange.month: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text('Mois', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp)),
          ),
          TimeRange.year: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text('Année', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp)),
          ),
          TimeRange.all: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text('Tout', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp)),
          ),
        },
        onValueChanged: (value) {
          if (value != null) {
            HapticFeedback.lightImpact();
            controller.setTimeRange(value);
          }
        },
        thumbColor: Colors.white,
        backgroundColor: Colors.grey.shade100,
      )),
    );
  }

  Widget _buildMonthNavigator(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.chevron_left, size: 20.sp),
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.navigateToPreviousMonth();
            },
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.navigateToCurrentMonth();
            },
            child: Column(
              children: [
                Text(
                  controller.currentPeriodName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                if (controller.selectedTimeRange.value == TimeRange.month)
                Text(
                  '${controller.selectedYear.value}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(CupertinoIcons.chevron_right, size: 20.sp),
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.navigateToNextMonth();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
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
                    'Solde Net',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  Icon(CupertinoIcons.money_dollar_circle, color: Colors.white70, size: 20.sp),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'FCFA ${_formatAmount(controller.netBalance)}',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      controller.netBalance >= 0
                          ? 'Épargne positive ✨'
                          : 'Attention au budget ⚠️',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (controller.selectedTimeRange.value != TimeRange.all) ...[
                    SizedBox(width: 8.w),
                    _buildTrendBadge(),
                  ]
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                theme,
                'Revenus',
                controller.totalIncome,
                CupertinoIcons.arrow_down_left_circle_fill,
                Colors.green.shade400,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildSummaryCard(
                theme,
                'Dépenses',
                controller.totalExpenses,
                CupertinoIcons.arrow_up_right_circle_fill,
                Colors.orange.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTrendBadge() {
    final trend = controller.expenseTrendPercentage;
    if (trend == 0) return const SizedBox.shrink();
    
    final isUp = trend > 0;
    final color = isUp ? Colors.red.shade300 : Colors.green.shade300;
    final icon = isUp ? CupertinoIcons.arrow_up_right : CupertinoIcons.arrow_down_right;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12.sp, color: Colors.white),
          SizedBox(width: 2.w),
          Text(
            '${trend.abs().toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _formatAmount(amount),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalCard(ThemeData theme) {
    if (controller.selectedTimeRange.value != TimeRange.month) return const SizedBox.shrink();

    final goal = controller.currentSavingsGoal.value;
    final progress = controller.savingsProgress;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.flag_fill, color: Colors.amber, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Objectif d\'épargne',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(CupertinoIcons.pencil_circle_fill, color: Colors.grey.shade200, size: 24.sp),
                onPressed: () {
                  final ctx = Get.context!;
                  final thm = Theme.of(ctx);
                  _showSetGoalDialog(ctx, thm);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (goal != null) ...[
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cible',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                ),
                Text(
                  'FCFA ${_formatAmount(goal.targetAmount)}',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Stack(
              children: [
                Container(
                  height: 8.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 500),
                  widthFactor: (progress / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: progress >= 100 ? Colors.green : Colors.amber,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '${progress.toStringAsFixed(1)}% atteint',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
            ),
          ] else ...[
            SizedBox(height: 16.h),
            Text(
              'Définissez un objectif pour suivre vos progrès',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJobsSection(ThemeData theme) {
    final jobs = controller.jobs;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mes Emplois', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              Text(
                '${jobs.length}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (jobs.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'Aucun revenu ajouté',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
                ),
              ),
            )
          else
            ...jobs.map((job) => _buildJobTile(theme, job)),
        ],
      ),
    );
  }

  Widget _buildJobTile(ThemeData theme, Job job) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(CupertinoIcons.briefcase_fill, color: Colors.black, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.name,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${job.frequency.displayName}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            '${_formatAmount(job.monthlyIncome)}',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.green.shade700),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _showJobOptions(Get.context!, theme, job),
            child: Icon(Icons.more_vert, size: 18.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ThemeData theme) {
    final chartData = controller.chartData;
    if (chartData.isEmpty) {
      return _buildEmptyCard(theme, 'Aucune dépense sur cette période');
    }

    final total = chartData.fold(0.0, (sum, e) => sum + e.value);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dépenses par catégorie', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 24.h),
          
          SizedBox(
            height: 200.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40.r,
                sections: chartData.map((data) {
                  final percentage = (data.value / total * 100).toStringAsFixed(0);
                  return PieChartSectionData(
                    color: Color(data.colorValue),
                    value: data.value,
                    title: '$percentage%',
                    radius: 50.r,
                    titleStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          SizedBox(height: 24.h),
          
          ...chartData.map((data) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: Color(data.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        data.name,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Text(
                    'FCFA ${_formatAmount(data.value)}',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme, String message) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              CupertinoIcons.chart_bar_alt_fill,
              size: 48.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,###', 'fr_FR').format(amount.round());
  }

  // Dialogs implementation
  void _showAddJobDialog(BuildContext context, ThemeData theme) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final selectedFrequency = PaymentFrequency.monthly.obs;
    final paymentDate = DateTime.now().obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ajouter un emploi', style: theme.textTheme.titleLarge),
              SizedBox(height: 24.h),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du job',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  suffixText: 'FCFA',
                ),
              ),
              SizedBox(height: 16.h),
              Obx(() => DropdownButtonFormField<PaymentFrequency>(
                value: selectedFrequency.value,
                decoration: InputDecoration(
                  labelText: 'Fréquence',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                items: PaymentFrequency.values.map((freq) => DropdownMenuItem(
                  value: freq,
                  child: Text(freq.displayName),
                )).toList(),
                onChanged: (value) { if (value != null) selectedFrequency.value = value; },
              )),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: const Text('Annuler'))),
                  SizedBox(width: 12.w),
                  Expanded(child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                        await controller.addJob(
                          name: nameController.text,
                          amount: double.parse(amountController.text),
                          frequency: selectedFrequency.value,
                          paymentDate: paymentDate.value,
                        );
                        Get.back();
                      }
                    },
                    child: const Text('Ajouter'),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showSetGoalDialog(BuildContext context, ThemeData theme) {
    final goalController = TextEditingController(
      text: controller.currentSavingsGoal.value?.targetAmount.toString() ?? '',
    );
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Objectif d\'épargne', style: theme.textTheme.titleLarge),
              SizedBox(height: 24.h),
              TextField(
                controller: goalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant cible',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  suffixText: 'FCFA',
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: const Text('Annuler'))),
                  SizedBox(width: 12.w),
                  Expanded(child: ElevatedButton(
                    onPressed: () async {
                      if (goalController.text.isNotEmpty) {
                        await controller.setSavingsGoal(double.parse(goalController.text));
                        Get.back();
                      }
                    },
                    child: const Text('Enregistrer'),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showJobOptions(BuildContext context, ThemeData theme, Job job) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(CupertinoIcons.pencil, color: Colors.blue),
              title: const Text('Modifier'),
              onTap: () { Get.back(); _showEditJobDialog(context, theme, job); },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.trash, color: Colors.red),
              title: const Text('Supprimer'),
              onTap: () { 
                Get.back(); 
                Get.dialog(AlertDialog(
                  title: const Text('Confirmer'),
                  content: Text('Supprimer "${job.name}" ?'),
                  actions: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
                    TextButton(onPressed: () async { await controller.deleteJob(job.id); Get.back(); }, child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                  ],
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEditJobDialog(BuildContext context, ThemeData theme, Job job) {
    final nameController = TextEditingController(text: job.name);
    final amountController = TextEditingController(text: job.amount.toString());
    final selectedFrequency = job.frequency.obs;
    final paymentDate = job.paymentDate.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Modifier', style: theme.textTheme.titleLarge),
              SizedBox(height: 24.h),
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nom', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
              SizedBox(height: 16.h),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Montant', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back(), child: const Text('Annuler'))),
                  SizedBox(width: 12.w),
                  Expanded(child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                        final updated = job.copyWith(name: nameController.text, amount: double.parse(amountController.text));
                        await controller.updateJob(updated);
                        Get.back();
                      }
                    },
                    child: const Text('Enregistrer'),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}