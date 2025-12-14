import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

void showAddRecurringTransactionDialog(BuildContext context, {RecurringTransaction? transaction}) {
  Get.bottomSheet(
    KoalaBottomSheet(
      title: transaction != null ? 'Modifier la récurrence' : 'Nouvelle récurrence',
      icon: CupertinoIcons.repeat,
      child: _AddRecurringTransactionSheet(transaction: transaction),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _AddRecurringTransactionSheet extends StatefulWidget {
  final RecurringTransaction? transaction;
  const _AddRecurringTransactionSheet({this.transaction});

  @override
  State<_AddRecurringTransactionSheet> createState() =>
      _AddRecurringTransactionSheetState();
}

class _AddRecurringTransactionSheetState
    extends State<_AddRecurringTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<RecurringTransactionsController>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  Frequency _frequency = Frequency.monthly;
  final List<int> _selectedDays = [];
  int _dayOfMonth = 1;
  bool _loading = false;
  bool _buttonPressed = false;
  
  // New fields
  TransactionType _selectedType = TransactionType.expense;
  TransactionCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    if (t != null) {
      _amountController = TextEditingController(text: t.amount.toStringAsFixed(0));
      _descriptionController = TextEditingController(text: t.description);
      _frequency = t.frequency;
      _selectedDays.addAll(t.daysOfWeek);
      _dayOfMonth = t.dayOfMonth;
      _selectedType = t.type;
      _selectedCategory = t.category;
    } else {
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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

  Future<void> _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une catégorie'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_frequency == Frequency.weekly && _selectedDays.isEmpty) {
         HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner au moins un jour'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      HapticFeedback.heavyImpact();
      setState(() => _loading = true);

      // Removed artificial delay

      final cleanAmount = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
      final amount = double.parse(cleanAmount);
      
      if (widget.transaction != null) {
        // Edit existing
        final t = widget.transaction!;
        t.amount = amount;
        t.description = _descriptionController.text;
        t.frequency = _frequency;
        t.daysOfWeek = List.from(_selectedDays);
        t.dayOfMonth = _dayOfMonth;
        t.category = _selectedCategory!;
        t.type = _selectedType;
        await _controller.updateRecurringTransaction(t);
      } else {
        // Create new
        final newTransaction = RecurringTransaction(
          amount: amount,
          description: _descriptionController.text,
          frequency: _frequency,
          daysOfWeek: _selectedDays,
          dayOfMonth: _dayOfMonth,
          lastGeneratedDate: DateTime.now(),
          category: _selectedCategory!,
          type: _selectedType,
        );
        _controller.addRecurringTransaction(newTransaction);
      }

      if (mounted) {
        NavigationHelper.safeBack();
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.transaction != null 
              ? 'Transaction modifiée avec succès'
              : 'Transaction récurrente ajoutée avec succès'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _showCategoryPicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryPickerSheet(
        type: _selectedType,
        onSelect: (category) {
          setState(() => _selectedCategory = category);
          NavigationHelper.safeBack();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.transaction != null;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75, // Explicit height constraint
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24.w,
            0,
            24.w,
            keyboardHeight + 24.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                [     
                      // Type Selector (Income/Expense)
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            _buildTypeOption(
                              'Dépense', 
                              TransactionType.expense, 
                              Colors.orange
                            ),
                            _buildTypeOption(
                              'Revenu', 
                              TransactionType.income, 
                              Colors.green
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Amount Field
                      KoalaTextField(
                        controller: _amountController,
                        label: 'Montant',
                        icon: CupertinoIcons.money_dollar,
                        keyboardType: TextInputType.number,
                        isAmount: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un montant';
                          }
                          final cleanAmount = value.replaceAll(RegExp(r'[^\d]'), '');
                          final amount = double.tryParse(cleanAmount);
                          if (amount == null || amount <= 0) {
                            return 'Le montant doit être supérieur à 0';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      
                      // Category Selector
                      GestureDetector(
                        onTap: _showCategoryPicker,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark ? const Color(0xFF2C2C2E) : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                                color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade200
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedCategory?.icon ?? '📦',
                                style: TextStyle(fontSize: 24.sp),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  _selectedCategory?.displayName ??
                                      'Sélectionner une catégorie',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedCategory != null
                                        ? (theme.brightness == Brightness.dark ? Colors.white : Colors.black)
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ),
                              Icon(
                                CupertinoIcons.chevron_right,
                                color: Colors.grey.shade400,
                                size: 20.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Description Field
                      KoalaTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        icon: CupertinoIcons.text_bubble,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      
                      Text(
                        'Fréquence',
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: 12.h),
                      _buildFrequencySelector(),
                      if (_frequency == Frequency.weekly)
                        _buildWeeklyDaySelector(),
                      if (_frequency == Frequency.monthly)
                        _buildMonthlyDaySelector(),
                      SizedBox(height: 48.h),
                      
                      KoalaButton(
                        text: isEditing ? 'Modifier' : 'Enregistrer',
                        onPressed: _loading ? () {} : () async {
                           setState(() => _buttonPressed = true);
                           await Future.delayed(const Duration(milliseconds: 100));
                           setState(() => _buttonPressed = false);
                           _addTransaction();
                        },
                        isLoading: _loading,
                        backgroundColor: Colors.black,
                      ),
                    ], // End of Column children
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(String label, TransactionType type, Color activeColor) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
           HapticFeedback.lightImpact();
           setState(() {
             _selectedType = type;
             _selectedCategory = null; // Reset category when type changes
           });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? activeColor : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Row(
      children: Frequency.values.map((frequency) {
        final isSelected = _frequency == frequency;
        String label;
        switch(frequency) {
          case Frequency.daily: label = 'Quotidien'; break;
          case Frequency.weekly: label = 'Hebdo'; break;
          case Frequency.monthly: label = 'Mensuel'; break;
        }
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _frequency = frequency);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade200,
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
      }).toList(),
    );
  }

  Widget _buildWeeklyDaySelector() {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jours de la semaine',
             style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(7, (index) {
              final day = index + 1;
              final dayName = days[index];
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
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade100,
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
        ],
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
                style: const TextStyle(color: Colors.black),
                underline: const SizedBox.shrink(),
                items: List.generate(31, (index) {
                  final day = index + 1;
                  return DropdownMenuItem(value: day, child: Text('Jour $day'));
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
}

class _CategoryPickerSheet extends StatelessWidget {
  final TransactionType type;
  final Function(TransactionCategory) onSelect;

  const _CategoryPickerSheet({required this.type, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = TransactionCategoryExtension.getByType(type);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
            child: Text(
              'Choisir une catégorie',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Categories grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSelect(category);
                  },
                  child:
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category.icon,
                              style: TextStyle(fontSize: 32.sp),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              category.displayName,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ).animate().scale(
                        delay: (index * 30).ms,
                        duration: 300.ms,
                        curve: Curves.easeOutBack,
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}