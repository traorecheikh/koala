// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';

void showAddTransactionDialog(BuildContext context, TransactionType type) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddTransactionSheet(type: type),
  );
}

class _AddTransactionSheet extends StatefulWidget {
  final TransactionType type;

  const _AddTransactionSheet({required this.type});

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  TransactionCategory? _selectedCategory;
  bool _loading = false;
  String? _error;
  bool _buttonPressed = false;

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

  Future<void> _addTransaction() async {
    final numericAmount = _getNumericValue(_amountController.text.trim());

    if (numericAmount.isEmpty ||
        double.tryParse(numericAmount) == null ||
        double.parse(numericAmount) <= 0) {
      HapticFeedback.lightImpact();
      setState(() => _error = 'Montant invalide');
      return;
    }

    if (_selectedCategory == null) {
      HapticFeedback.lightImpact();
      setState(() => _error = 'Sélectionnez une catégorie');
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _loading = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final homeController = Get.find<HomeController>();
    final transaction = LocalTransaction(
      amount: double.parse(numericAmount),
      description: _descriptionController.text.trim().isEmpty
          ? _selectedCategory!.displayName
          : _descriptionController.text.trim(),
      date: DateTime.now(),
      type: widget.type,
      category: _selectedCategory!,
    );

    homeController.addTransaction(transaction);

    if (mounted) {
      Navigator.pop(context);
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.type == TransactionType.income
                ? 'Revenu ajouté avec succès'
                : 'Dépense ajoutée avec succès',
          ),
          backgroundColor: widget.type == TransactionType.income
              ? Colors.green
              : Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCategoryPicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryPickerSheet(
        type: widget.type,
        onSelect: (category) {
          setState(() => _selectedCategory = category);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

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
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: widget.type == TransactionType.income
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    widget.type == TransactionType.income
                        ? CupertinoIcons.arrow_down_left
                        : CupertinoIcons.arrow_up_right,
                    color: widget.type == TransactionType.income
                        ? Colors.green
                        : Colors.orange,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  widget.type == TransactionType.income
                      ? 'Ajouter un revenu'
                      : 'Ajouter une dépense',
                  style: theme.textTheme.headlineSmall?.copyWith(
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
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: isKeyboardVisible ? 24.h : 48.h,
                bottom: isKeyboardVisible ? keyboardHeight + 24.h : 48.h,
                left: 24.w,
                right: 24.w,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                          color: widget.type == TransactionType.income
                              ? Colors.green
                              : Colors.orange,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                          ),
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

                  // Category selector
                  GestureDetector(
                    onTap: _showCategoryPicker,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade200),
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
                              _selectedCategory?.displayName ?? 'Sélectionner une catégorie',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w500,
                                color: _selectedCategory != null
                                    ? Colors.black
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
                  ).animate().slideY(
                    begin: 0.2,
                    duration: 400.ms,
                    delay: 100.ms,
                    curve: Curves.easeOutQuart,
                  ).fadeIn(),

                  SizedBox(height: 16.h),

                  // Optional description
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Note (optionnel)',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.h),
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
                  ).animate().slideY(
                    begin: 0.2,
                    duration: 400.ms,
                    delay: 200.ms,
                    curve: Curves.easeOutQuart,
                  ).fadeIn(),

                  if (_error != null) ...[
                    SizedBox(height: 24.h),
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().shake(duration: 300.ms),
                    ),
                  ],

                  SizedBox(height: isKeyboardVisible ? 24.h : 48.h),

                  // Add button
                  AnimatedScale(
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
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );
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
                      ),
                    ),
                  ).animate().slideY(
                    begin: 0.3,
                    duration: 600.ms,
                    delay: 300.ms,
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
}

class _CategoryPickerSheet extends StatelessWidget {
  final TransactionType type;
  final Function(TransactionCategory) onSelect;

  const _CategoryPickerSheet({
    required this.type,
    required this.onSelect,
  });

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
                  child: Container(
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
