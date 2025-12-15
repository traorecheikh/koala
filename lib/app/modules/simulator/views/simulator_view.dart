// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/modules/simulator/controllers/simulator_controller.dart';
import 'package:koaa/app/services/ml/models/simulator_engine.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

class SimulatorView extends GetView<SimulatorController> {
  const SimulatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: KoalaColors.text(context)),
          onPressed: () => NavigationHelper.safeBack(),
        ),
        title: Text(
          'Simulateur',
          style: KoalaTypography.heading3(context),
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
                style: KoalaTypography.bodyLarge(context).copyWith(
                  color: KoalaColors.textSecondary(context),
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
                      backgroundColor: isValid
                          ? KoalaColors.primaryUi(context)
                          : KoalaColors.surface(context),
                      foregroundColor: isValid
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white)
                          : KoalaColors.textSecondary(context),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? CupertinoActivityIndicator(
                            color: isValid
                                ? (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.white)
                                : KoalaColors.textSecondary(context))
                        : Text(
                            'Analyser l\'impact',
                            style: KoalaTypography.bodyLarge(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: isValid
                                  ? (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black
                                      : Colors.white)
                                  : KoalaColors.textSecondary(context),
                            ),
                          ),
                  ),
                );
              }),

              SizedBox(height: 40.h),

              // Results
              Obx(() {
                if (controller.result.value == null) {
                  return const SizedBox.shrink();
                }
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
    return IntrinsicWidth(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: KoalaTypography.heading1(context).copyWith(
          fontSize: 48.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(
              color: KoalaColors.textSecondary(context).withOpacity(0.3)),
          border: InputBorder.none,
          suffixText: 'F',
          suffixStyle: KoalaTypography.heading2(context).copyWith(
            color: KoalaColors.textSecondary(context),
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
    final isSolvent = result.isSolvent;
    final color = isSolvent ? KoalaColors.success : KoalaColors.destructive;

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
                  color: KoalaColors.surface(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSolvent
                      ? CupertinoIcons.checkmark_alt
                      : CupertinoIcons.exclamationmark,
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
                      style: KoalaTypography.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      result.summary,
                      style: KoalaTypography.bodyMedium(context).copyWith(
                        color: KoalaColors.textSecondary(context),
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
          style: KoalaTypography.heading3(context),
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
                color: Colors.blue, // Keep blue for neutral/info
                delay: 200,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _MetricCard(
                label: 'Solde Final',
                value: 'FCFA ${_formatAmount(result.finalBalance)}',
                icon: CupertinoIcons.graph_square_fill,
                color: Colors.purple, // Keep purple for neutral/info
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
                icon: CupertinoIcons.arrow_down_circle_fill,
                color:
                    isSolvent ? KoalaColors.success : KoalaColors.destructive,
                delay: 400,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _MetricCard(
                label: '1ère Date Négative',
                value: result.firstNegativeBalanceDate != null
                    ? DateFormat('dd MMM yyyy')
                        .format(result.firstNegativeBalanceDate!)
                    : 'N/A',
                icon: CupertinoIcons.calendar_badge_minus,
                color: KoalaColors.destructive,
                delay: 500,
              ),
            ),
          ],
        ),

        if (result.cashFlowTimeline.isNotEmpty) ...[
          SizedBox(height: 24.h),
          Text(
            'Événements Clés',
            style: KoalaTypography.heading3(context),
          ).animate().fadeIn(delay: 600.ms),
          SizedBox(height: 16.h),
          _CashFlowTimelineWidget(timeline: result.cashFlowTimeline),
        ],

        if (result.budgetImpact.isNotEmpty ||
            result.goalProgressImpact.isNotEmpty) ...[
          SizedBox(height: 24.h),
          Text(
            'Impacts Détaillés',
            style: KoalaTypography.heading3(context),
          ).animate().fadeIn(delay: 700.ms),
          SizedBox(height: 16.h),
          // Budget impacts
          if (result.budgetImpact.isNotEmpty)
            ...result.budgetImpact.entries.map((entry) {
              final spent = entry.value;
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: KoalaColors.surface(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: KoalaColors.border(context)),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.chart_pie,
                        color: Colors.blue, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Budget catégorie',
                        style: KoalaTypography.bodyMedium(context),
                      ),
                    ),
                    Text(
                      '${NumberFormat.compact(locale: 'fr_FR').format(spent)} F dépensé',
                      style: KoalaTypography.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: KoalaColors.warning),
                    ),
                  ],
                ),
              );
            }).toList(),
          // Goal impacts
          if (result.goalProgressImpact.isNotEmpty)
            ...result.goalProgressImpact.entries.map((entry) {
              final progress = entry.value;
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: KoalaColors.surface(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: KoalaColors.border(context)),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.flag,
                        color: KoalaColors.success, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Objectif',
                        style: KoalaTypography.bodyMedium(context),
                      ),
                    ),
                    Text(
                      '${NumberFormat.compact(locale: 'fr_FR').format(progress)} F épargné',
                      style: KoalaTypography.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: KoalaColors.success),
                    ),
                  ],
                ),
              );
            }).toList(),
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
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: KoalaColors.shadowSubtle,
        border: Border.all(
          color: KoalaColors.border(context),
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
                        style: KoalaTypography.caption(context).copyWith(
                          color: KoalaColors.textSecondary(context),
                        ),
                      ),
                      Text(
                        event.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KoalaTypography.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${event.amount > 0 ? '+' : '-'} FCFA ${_formatAmount(event.amount.abs())}',
                  style: KoalaTypography.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: event.amount > 0
                        ? KoalaColors.success
                        : KoalaColors.destructive,
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

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: KoalaColors.border(context)),
        boxShadow: KoalaColors.shadowSubtle,
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
            style: KoalaTypography.bodyMedium(context)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: KoalaTypography.caption(context).copyWith(
              color: KoalaColors.textSecondary(context),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1);
  }
}
