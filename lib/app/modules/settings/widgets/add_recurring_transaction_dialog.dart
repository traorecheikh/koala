import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

void showAddRecurringTransactionDialog(BuildContext context,
    {RecurringTransaction? transaction}) {
  Get.bottomSheet(
    KoalaBottomSheet(
      title: transaction != null
          ? 'Modifier la récurrence'
          : 'Nouvelle récurrence',
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
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    if (t != null) {
      _amountController =
          TextEditingController(text: t.amount.toStringAsFixed(0));
      _descriptionController = TextEditingController(text: t.description);
      _frequency = t.frequency;
      _selectedDays.addAll(t.daysOfWeek);
      _dayOfMonth = t.dayOfMonth;
      _selectedType = t.type;
      _selectedCategory = t.category;
      _endDate = t.endDate;
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
          SnackBar(
            content: const Text('Veuillez sélectionner une catégorie'),
            backgroundColor: KoalaColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_frequency == Frequency.weekly && _selectedDays.isEmpty) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Veuillez sélectionner au moins un jour'),
            backgroundColor: KoalaColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Validate day of month for monthly frequency
      if (_frequency == Frequency.monthly && _dayOfMonth > 28) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Jour $_dayOfMonth peut ne pas exister dans tous les mois (ex: février)'),
            backgroundColor: KoalaColors.warning,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Continuer',
              textColor: Colors.white,
              onPressed: () => _proceedWithTransaction(),
            ),
          ),
        );
        return;
      }

      await _proceedWithTransaction();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _proceedWithTransaction() async {
    HapticFeedback.heavyImpact();
    setState(() => _loading = true);

    try {
      final cleanAmount =
          _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
      final amount = double.parse(cleanAmount);

      // Validate amount bounds
      if (amount <= 0) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Le montant doit être supérieur à zéro'),
              backgroundColor: KoalaColors.destructive,
            ),
          );
        }
        return;
      }

      if (amount > 1000000000) {
        // 1 billion max
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Le montant est trop élevé'),
              backgroundColor: KoalaColors.warning,
            ),
          );
        }
        return;
      }

      if (widget.transaction != null) {
        // Edit existing with error handling
        final t = widget.transaction!;
        t.amount = amount;
        t.description = _descriptionController.text.trim();
        t.frequency = _frequency;
        t.daysOfWeek = List.from(_selectedDays);
        t.dayOfMonth = _dayOfMonth;
        t.category = _selectedCategory!;
        t.type = _selectedType;
        t.endDate = _endDate;
        await _controller.updateRecurringTransaction(t);
      } else {
        // Create new with error handling
        final newTransaction = RecurringTransaction(
          amount: amount,
          description: _descriptionController.text.trim(),
          frequency: _frequency,
          daysOfWeek: _selectedDays,
          dayOfMonth: _dayOfMonth,
          lastGeneratedDate: DateTime.now(),
          category: _selectedCategory!,
          type: _selectedType,
          endDate: _endDate,
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
            backgroundColor: KoalaColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Error handling for database operations
      if (mounted) {
        setState(() => _loading = false);
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: KoalaColors.destructive,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
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
    final screenHeight = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.9, // Responsive height with max constraint
        minHeight: screenHeight * 0.5, // Minimum height
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            KoalaSpacing.xxl,
            0,
            KoalaSpacing.xxl,
            keyboardHeight + KoalaSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Selector (Income/Expense)
              Container(
                padding: EdgeInsets.all(KoalaSpacing.xs),
                decoration: BoxDecoration(
                  color: KoalaColors.border(context),
                  borderRadius: BorderRadius.circular(KoalaRadius.sm),
                ),
                child: Row(
                  children: [
                    _buildTypeOption(
                        'Dépense', TransactionType.expense, Colors.orange),
                    _buildTypeOption(
                        'Revenu', TransactionType.income, Colors.green),
                  ],
                ),
              ),
              SizedBox(height: KoalaSpacing.xxl),

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
              SizedBox(height: KoalaSpacing.lg),

              // Category Selector
              GestureDetector(
                onTap: _showCategoryPicker,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: KoalaColors.inputBackground(context),
                    borderRadius: BorderRadius.circular(KoalaRadius.md),
                    border: Border.all(color: KoalaColors.border(context)),
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
                      SizedBox(width: KoalaSpacing.md),
                      Expanded(
                        child: Text(
                          _selectedCategory?.displayName ??
                              'Sélectionner une catégorie',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                            color: _selectedCategory != null
                                ? KoalaColors.text(context)
                                : KoalaColors.textSecondary(context),
                          ),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: KoalaColors.textSecondary(context),
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: KoalaSpacing.lg),

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
              SizedBox(height: KoalaSpacing.xxl),

              Text(
                'Fréquence',
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: KoalaSpacing.md),
              _buildFrequencySelector(),
              if (_frequency == Frequency.weekly) _buildWeeklyDaySelector(),
              if (_frequency == Frequency.monthly) _buildMonthlyDaySelector(),
              _buildEndDateSelector(),
              SizedBox(height: KoalaSpacing.huge),

              KoalaButton(
                text: isEditing ? 'Modifier' : 'Enregistrer',
                onPressed: _loading
                    ? () {}
                    : () async {
                        setState(() => _buttonPressed = true);
                        await Future.delayed(const Duration(milliseconds: 100));
                        setState(() => _buttonPressed = false);
                        _addTransaction();
                      },
                isLoading: _loading,
                backgroundColor: KoalaColors.primaryUi(context),
              ),
            ], // End of Column children
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(
      String label, TransactionType type, Color activeColor) {
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
            color:
                isSelected ? KoalaColors.surface(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(KoalaRadius.sm),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: KoalaColors.shadowSubtle[0].color,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color:
                  isSelected ? activeColor : KoalaColors.textSecondary(context),
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
        switch (frequency) {
          case Frequency.daily:
            label = 'Quotidien';
            break;
          case Frequency.weekly:
            label = 'Hebdo';
            break;
          case Frequency.monthly:
            label = 'Mensuel';
            break;
          case Frequency.biWeekly:
            label = 'Bi-Hebdo';
            break;
          case Frequency.yearly:
            label = 'Annuel';
            break;
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
                    ? KoalaColors.primaryUi(context)
                    : KoalaColors.border(context),
                borderRadius: BorderRadius.circular(KoalaRadius.sm),
                border: Border.all(
                  color: isSelected
                      ? KoalaColors.primaryUi(context)
                      : KoalaColors.border(context),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : KoalaColors.text(context),
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
            style: TextStyle(
                fontSize: 14.sp, color: KoalaColors.textSecondary(context)),
          ),
          SizedBox(height: KoalaSpacing.sm),
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
                        ? KoalaColors.primaryUi(context)
                        : KoalaColors.border(context),
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
                            : KoalaColors.text(context),
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
          color: KoalaColors.inputBackground(context),
          borderRadius: BorderRadius.circular(KoalaRadius.md),
          border: Border.all(color: KoalaColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.calendar,
              color: KoalaColors.textSecondary(context),
              size: 20.sp,
            ),
            SizedBox(width: KoalaSpacing.md),
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

  Widget _buildEndDateSelector() {
    return Padding(
      padding: EdgeInsets.only(top: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date de fin (Optionnel)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_endDate != null)
                GestureDetector(
                  onTap: () => setState(() => _endDate = null),
                  child: Text(
                    'Effacer',
                    style: TextStyle(
                      color: KoalaColors.destructive,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: KoalaSpacing.md),
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              final date = await showDatePicker(
                context: context,
                initialDate:
                    _endDate ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: KoalaColors.primaryUi(context),
                        onPrimary: Colors.white,
                        surface: KoalaColors.surface(context),
                        onSurface: KoalaColors.text(context),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() => _endDate = date);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: KoalaColors.inputBackground(context),
                borderRadius: BorderRadius.circular(KoalaRadius.md),
                border: Border.all(color: KoalaColors.border(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.calendar_today,
                    color: _endDate != null
                        ? KoalaColors.primaryUi(context)
                        : KoalaColors.textSecondary(context),
                    size: 20.sp,
                  ),
                  SizedBox(width: KoalaSpacing.md),
                  Text(
                    _endDate != null
                        ? 'Se termine le : ${DateFormat('dd MMM yyyy', 'fr_FR').format(_endDate!)}'
                        : 'Pas de date de fin (Indéfini)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _endDate != null
                          ? KoalaColors.text(context)
                          : KoalaColors.textSecondary(context),
                      fontWeight: _endDate != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        color: KoalaColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          const KoalaDragHandle(),

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
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(KoalaRadius.md),
                      border: Border.all(color: KoalaColors.border(context)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.icon,
                          style: TextStyle(fontSize: 32.sp),
                        ),
                        SizedBox(height: KoalaSpacing.sm),
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
