import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/modules/simulator/controllers/simulator_controller.dart';
import 'package:koaa/app/services/ml/models/simulator_engine.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

class SimulatorView extends GetView<SimulatorController> {
  const SimulatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: theme.iconTheme.color),
          onPressed: () => NavigationHelper.safeBack(),
        ),
        title: Text(
          'Simulateur',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              Text(
                'Quel achat envisagez-vous ?',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 24.h),
              
              // Clean Input
              _AmountInput(controller: controller.amountController),
              
              SizedBox(height: 40.h),
              
              // Action Button
              Obx(() {
                final isValid = controller.isAmountValid.value;

                return SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: isValid && !controller.isLoading.value
                        ? () {
                            HapticFeedback.mediumImpact();
                            controller.simulate();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isValid ? theme.primaryColor : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : Text(
                            'Analyser l\'impact',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                  ),
                );
              }),

              SizedBox(height: 40.h),

              // Results
              Obx(() {
                if (controller.result.value == null) return const SizedBox.shrink();
                return _SimulationResultView(result: controller.result.value!);
              }),
              
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;

  const _AmountInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return IntrinsicWidth(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 48.sp,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : const Color(0xFF2D3250),
          letterSpacing: -1,
        ),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.3)),
          border: InputBorder.none,
          suffixText: 'F',
          suffixStyle: TextStyle(
            fontSize: 24.sp,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            height: 2,
          ),
        ),
      ),
    );
  }
}

class _SimulationResultView extends StatelessWidget {
  final SimulationReport result;

  const _SimulationResultView({required this.result});

  String _formatAmount(double amount) {
    return NumberFormat('#,###', 'fr_FR').format(amount.round());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSolvent = result.isSolvent;
    final color = isSolvent ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verdict Card
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSolvent ? CupertinoIcons.checkmark_alt : CupertinoIcons.exclamationmark,
                  color: color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSolvent ? 'Simulation Positive' : 'Risque Financier',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      result.summary,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1),

        SizedBox(height: 24.h),

        Text(
          'Aperçu de la simulation',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 100.ms),
        
        SizedBox(height: 16.h),

        // Metrics Grid
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Solde Initial',
                value: 'FCFA ${_formatAmount(result.initialBalance)}',
                icon: CupertinoIcons.money_dollar_circle_fill,
                color: Colors.blue,
                delay: 200,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _MetricCard(
                label: 'Solde Final',
                value: 'FCFA ${_formatAmount(result.finalBalance)}',
                icon: CupertinoIcons.graph_square_fill,
                color: Colors.purple,
                delay: 300,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Solde Min. Atteint',
                value: 'FCFA ${_formatAmount(result.lowestBalance)}',
                icon: CupertinoIcons.arrow_down_circle_fill, // Fixed icon
                color: isSolvent ? Colors.green : Colors.red,
                delay: 400,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _MetricCard(
                label: '1ère Date Négative',
                value: result.firstNegativeBalanceDate != null
                    ? DateFormat('dd MMM yyyy').format(result.firstNegativeBalanceDate!)
                    : 'N/A',
                icon: CupertinoIcons.calendar_badge_minus,
                color: Colors.redAccent,
                delay: 500,
              ),
            ),
          ],
        ),

        if (result.cashFlowTimeline.isNotEmpty) ...[
          SizedBox(height: 24.h),
          Text(
            'Événements Clés',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 600.ms),
          SizedBox(height: 16.h),
          _CashFlowTimelineWidget(timeline: result.cashFlowTimeline),
        ],

        if (result.budgetImpact.isNotEmpty || result.goalProgressImpact.isNotEmpty) ...[
          SizedBox(height: 24.h),
          Text(
            'Impacts Détaillés',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 700.ms),
          SizedBox(height: 16.h),
          // TODO: Implement dedicated widgets for budget and goal impacts
          Text(
            'Impact sur les budgets et objectifs (à implémenter)',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
        ],
        SizedBox(height: 40.h),
      ],
    );
  }
}

class _CashFlowTimelineWidget extends StatelessWidget {
  final List<CashFlowEvent> timeline;

  const _CashFlowTimelineWidget({required this.timeline});

  String _formatAmount(double amount) {
    return NumberFormat('#,###', 'fr_FR').format(amount.round());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: timeline.length,
        itemBuilder: (context, index) {
          final event = timeline[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMM').format(event.date),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        event.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${event.amount > 0 ? '+' : '-'} FCFA ${_formatAmount(event.amount.abs())}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: event.amount > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;
  final bool fullWidth;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1);
  }
}