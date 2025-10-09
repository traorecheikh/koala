// ignore_for_file: deprecated_member_use

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
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  Frequency _frequency = Frequency.monthly;
  final List<int> _selectedDays = [];
  int _dayOfMonth = 1;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  String _formatAmount(String value) {
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return '';
    final number = int.parse(digitsOnly);
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]} ',
    );
  }

  String _getNumericValue(String formattedValue) {
    return formattedValue.replaceAll(' ', '');
  }

  Future<void> _addRecurring() async {
    final numericAmount = _getNumericValue(_amountController.text.trim());
    final description = _descriptionController.text.trim();

    if (numericAmount.isEmpty ||
        double.tryParse(numericAmount) == null ||
        double.parse(numericAmount) <= 0) {
      HapticFeedback.lightImpact();
      setState(() => _error = 'Montant invalide');
      return;
    }

    if (description.isEmpty) {
      HapticFeedback.lightImpact();
      setState(() => _error = 'Description requise');
      return;
    }

    if (_frequency == Frequency.weekly && _selectedDays.isEmpty) {
      HapticFeedback.lightImpact();
      setState(() => _error = 'Sélectionnez au moins un jour');
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _loading = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final controller = Get.find<RecurringTransactionsController>();
    final transaction = RecurringTransaction(
      amount: double.parse(numericAmount),
      description: description,
      frequency: _frequency,
      daysOfWeek: _selectedDays,
      dayOfMonth: _dayOfMonth,
      lastGeneratedDate: DateTime.now(),
    );

    controller.addRecurringTransaction(transaction);

    if (mounted) {
      Navigator.pop(context);
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaction récurrente ajoutée'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
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
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    CupertinoIcons.repeat,
                    color: Colors.purple,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Transaction récurrente',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 24.h,
                bottom: keyboardHeight > 0 ? keyboardHeight + 24.h : 24.h,
                left: 24.w,
                right: 24.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount input
                  Column(
                    children: [
                      TextField(
                        controller: _amountController,
                        focusNode: _amountFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                          height: 1.1,
                          color: Colors.purple,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          final formatted = _formatAmount(value);
                          if (formatted != value) {
                            _amountController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                offset: formatted.length,
                              ),
                            );
                          }
                          if (_error != null) {
                            setState(() => _error = null);
                          }
                        },
                        onSubmitted: (_) =>
                            _descriptionFocusNode.requestFocus(),
                      ),
                      Text(
                        'FCFA',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 1.h,
                        width: 60.w,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ).animate().scale(
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),

                  SizedBox(height: 32.h),

                  // Description input
                  Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          focusNode: _descriptionFocusNode,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Description',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.h,
                            ),
                            prefixIcon: Icon(
                              CupertinoIcons.text_alignleft,
                              color: Colors.grey.shade500,
                              size: 20.sp,
                            ),
                          ),
                          onChanged: (_) {
                            if (_error != null) {
                              setState(() => _error = null);
                            }
                          },
                        ),
                      )
                      .animate()
                      .slideY(
                        begin: 0.2,
                        duration: 400.ms,
                        delay: 100.ms,
                        curve: Curves.easeOutQuart,
                      )
                      .fadeIn(),

                  SizedBox(height: 24.h),

                  // Frequency selector
                  Text(
                    'Fréquence',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                        children: [
                          _buildFrequencyChip('Quotidien', Frequency.daily),
                          SizedBox(width: 8.w),
                          _buildFrequencyChip('Hebdomadaire', Frequency.weekly),
                          SizedBox(width: 8.w),
                          _buildFrequencyChip('Mensuel', Frequency.monthly),
                        ],
                      )
                      .animate()
                      .slideY(
                        begin: 0.2,
                        duration: 400.ms,
                        delay: 200.ms,
                        curve: Curves.easeOutQuart,
                      )
                      .fadeIn(),

                  SizedBox(height: 24.h),

                  // Weekly days selector
                  if (_frequency == Frequency.weekly) ...[
                    Text(
                      'Jours de la semaine',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: List.generate(7, (index) {
                        final day = index + 1;
                        final dayName = [
                          'L',
                          'M',
                          'M',
                          'J',
                          'V',
                          'S',
                          'D',
                        ][index];
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
                              if (_error != null) _error = null;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.purple
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                dayName,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ).animate().fadeIn(delay: 300.ms),
                    SizedBox(height: 24.h),
                  ],

                  // Monthly day selector
                  if (_frequency == Frequency.monthly) ...[
                    Text(
                      'Jour du mois',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
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
                                  child: Text('Jour $day'),
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
                    ).animate().fadeIn(delay: 300.ms),
                    SizedBox(height: 24.h),
                  ],

                  if (_error != null) ...[
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.exclamationmark_circle,
                              color: Colors.red,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().shake(duration: 300.ms),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // Add button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: CupertinoButton(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16.r),
                      onPressed: _loading ? null : _addRecurring,
                      child: _loading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: const CupertinoActivityIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Ajout en cours...',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Ajouter',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ).animate().slideY(
                    begin: 0.3,
                    duration: 600.ms,
                    delay: 400.ms,
                    curve: Curves.easeOutQuart,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyChip(String label, Frequency frequency) {
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
            color: isSelected ? Colors.purple : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.grey.shade200,
            ),
          ),
          child: Text(
            label,
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
  }
}
