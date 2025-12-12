import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/modules/simulator/controllers/simulator_controller.dart';
import 'package:koaa/app/services/ml/models/simulator_engine.dart';

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
          onPressed: () => Get.back(),
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
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    controller.simulate();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Obx(() => controller.isLoading.value
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Text(
                          'Analyser l\'impact',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        )),
                ),
              ),

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
  final SimulationResult result;

  const _SimulationResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSafe = result.isSafe;
    final color = isSafe ? Colors.green : Colors.red;

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
                  isSafe ? CupertinoIcons.checkmark_alt : CupertinoIcons.exclamationmark,
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
                      isSafe ? 'Achat Sécurisé' : 'Risque Financier',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      result.explanation.mainImpact,
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
          'Analyse Détaillée',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 100.ms),
        
        SizedBox(height: 16.h),

        // Metrics Grid
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Solde min. prévu',
                value: NumberFormat.compact().format(result.lowestBalance),
                icon: CupertinoIcons.graph_square_fill,
                color: Colors.blue,
                delay: 200,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _MetricCard(
                label: 'Dépenses / jour',
                value: NumberFormat.compact().format(result.dailyBurnRate),
                icon: CupertinoIcons.flame_fill,
                color: Colors.orange,
                delay: 300,
              ),
            ),
          ],
        ),
        
        if (result.upcomingBills.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _MetricCard(
            label: 'Factures à venir (30j)',
            value: '${result.upcomingBills.length} factures',
            icon: CupertinoIcons.calendar_today,
            color: Colors.purple,
            delay: 400,
            fullWidth: true,
          ),
        ],

        SizedBox(height: 24.h),

        // Explanation Text
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            result.explanation.details,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
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
