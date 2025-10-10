
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';

void showAddRecurringTransactionDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AddRecurringTransactionSheet(),
  );
}

class _AddRecurringTransactionSheet extends StatefulWidget {
  const _AddRecurringTransactionSheet();

  @override
  State<_AddRecurringTransactionSheet> createState() =>
      _AddRecurringTransactionSheetState();
}

class _AddRecurringTransactionSheetState
    extends State<_AddRecurringTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<RecurringTransactionsController>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  Frequency _frequency = Frequency.monthly;
  final List<int> _selectedDays = [];
  int _dayOfMonth = 1;
  bool _loading = false;
  bool _buttonPressed = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      setState(() => _loading = true);

      await Future.delayed(const Duration(milliseconds: 800));

      final newTransaction = RecurringTransaction(
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        frequency: _frequency,
        daysOfWeek: _selectedDays,
        dayOfMonth: _dayOfMonth,
        lastGeneratedDate: DateTime.now(),
      );
      _controller.addRecurringTransaction(newTransaction);

      if (mounted) {
        Navigator.pop(context);
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recurring transaction added successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 36.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0.h),
            child: Row(
              children: [
                Text('Add Recurring Transaction', style: theme.textTheme.headlineSmall),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Icon(
                    CupertinoIcons.xmark,
                    color: Colors.grey.shade600,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, keyboardHeight + 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFormField(
                      controller: _amountController,
                      label: 'Amount',
                      icon: CupertinoIcons.money_dollar,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildTextFormField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: CupertinoIcons.text_bubble,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
                    Text('Frequency', style: theme.textTheme.titleMedium),
                    SizedBox(height: 12.h),
                    _buildFrequencySelector(),
                    if (_frequency == Frequency.weekly)
                      _buildWeeklyDaySelector(),
                    if (_frequency == Frequency.monthly)
                      _buildMonthlyDaySelector(),
                    SizedBox(height: 48.h),
                    _buildSaveButton(),
                  ].animate(interval: 100.ms).slideY(
                        begin: 0.2,
                        duration: 400.ms,
                        curve: Curves.easeOutQuart,
                      ).fadeIn(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
          prefixIcon: Icon(
            icon,
            color: Colors.grey.shade500,
            size: 20.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Row(
      children: Frequency.values.map((frequency) {
        final isSelected = _frequency == frequency;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _frequency = frequency);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
                ),
              ),
              child: Text(
                frequency.toString().split('.').last.capitalizeFirst!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyDaySelector() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: List.generate(7, (index) {
          final day = index + 1;
          final dayName = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index];
          final isSelected = _selectedDays.contains(day);

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                if (isSelected) {
                  _selectedDays.remove(day);
                } else {
                  _selectedDays.add(day);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthlyDaySelector() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.calendar,
              color: Colors.grey.shade500,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: DropdownButton<int>(
                value: _dayOfMonth,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: List.generate(31, (index) {
                  final day = index + 1;
                  return DropdownMenuItem(
                    value: day,
                    child: Text('Day $day'),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    HapticFeedback.lightImpact();
                    setState(() => _dayOfMonth = value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedScale(
      scale: _buttonPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedOpacity(
        opacity: _loading ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: CupertinoButton(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16.r),
            onPressed: _loading
                ? null
                : () async {
                    setState(() => _buttonPressed = true);
                    await Future.delayed(const Duration(milliseconds: 100));
                    setState(() => _buttonPressed = false);
                    _addTransaction();
                  },
            child: _loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CupertinoActivityIndicator(color: Colors.white),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Saving...',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Save Transaction',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

