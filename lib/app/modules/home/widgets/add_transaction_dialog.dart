// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/services/intelligence/intelligence_service.dart';
import 'package:koaa/app/services/intelligence/koala_brain.dart';

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
  Category? _selectedCategory;
  bool _loading = false;
  String? _error;
  bool _buttonPressed = false;

  // Smart categorization
  CategorySuggestion? _categorySuggestion;
  Timer? _debounceTimer;
  bool _showSuggestion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
    // Listen to description changes for smart categorization
    _descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _descriptionController.removeListener(_onDescriptionChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _onDescriptionChanged() {
    _debounceTimer?.cancel();
    final description = _descriptionController.text.trim();

    if (description.length < 3) {
      setState(() {
        _categorySuggestion = null;
        _showSuggestion = false;
      });
      return;
    }

    // Debounce to avoid too many calls
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _getSuggestion(description);
    });
  }

  void _getSuggestion(String description) {
    try {
      final intelligenceService = Get.find<IntelligenceService>();
      final suggestion = intelligenceService.suggestCategory(description, widget.type);

      // Only show if confidence is reasonable and no category selected yet
      if (suggestion.confidence >= 0.5 && _selectedCategory == null) {
        setState(() {
          _categorySuggestion = suggestion;
          _showSuggestion = true;
        });
      } else {
        setState(() {
          _showSuggestion = false;
        });
      }
    } catch (e) {
      // Intelligence service not available, silently ignore
    }
  }

  void _acceptSuggestion() {
    if (_categorySuggestion == null) return;

    final categoriesController = Get.find<CategoriesController>();
    final categories = widget.type == TransactionType.income
        ? categoriesController.incomeCategories
        : categoriesController.expenseCategories;

    // Find matching category by name
    final suggestedCategoryName = _categorySuggestion!.category?.displayName;
    final matchingCategory = categories.firstWhereOrNull(
      (c) => c.name.toLowerCase() == suggestedCategoryName?.toLowerCase(),
    );

    if (matchingCategory != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedCategory = matchingCategory;
        _showSuggestion = false;
      });

      // Learn from the accepted suggestion
      try {
        final intelligenceService = Get.find<IntelligenceService>();
        if (_categorySuggestion!.category != null) {
          intelligenceService.learnFromCategoryChoice(
            _descriptionController.text.trim(),
            _categorySuggestion!.category!,
            matchingCategory.id,
            widget.type,
          );
        }
      } catch (e) {
        // Ignore
      }
    }
  }

  void _dismissSuggestion() {
    HapticFeedback.lightImpact();
    setState(() {
      _showSuggestion = false;
    });
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

    // Artificial delay removed

    final homeController = Get.find<HomeController>();
    final transaction = LocalTransaction(
      amount: double.parse(numericAmount),
      description: _descriptionController.text.trim().isEmpty
          ? _selectedCategory!.name
          : _descriptionController.text.trim(),
      date: DateTime.now(),
      type: widget.type,
      categoryId: _selectedCategory!.id,
      // Fallback for old enum if needed by other parts of app
      category: null, 
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
      height: MediaQuery.of(context).size.height * 0.65,
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
                    fontSize: 23.sp,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: _selectedCategory != null 
                                    ? Color(_selectedCategory!.colorValue).withOpacity(0.2)
                                    : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _selectedCategory?.icon ?? '📦',
                                    style: TextStyle(fontSize: 24.sp),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  _selectedCategory?.name ??
                                      'Sélectionner une catégorie',
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
                      )
                      .animate()
                      .slideY(
                        begin: 0.2,
                        duration: 400.ms,
                        delay: 100.ms,
                        curve: Curves.easeOutQuart,
                      )
                      .fadeIn(),

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
                            hintText: 'Description (suggestion auto)',
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
                        delay: 200.ms,
                        curve: Curves.easeOutQuart,
                      )
                      .fadeIn(),

                  // Smart Category Suggestion
                  if (_showSuggestion && _categorySuggestion != null) ...[
                    SizedBox(height: 12.h),
                    _SmartSuggestionChip(
                      suggestion: _categorySuggestion!,
                      onAccept: _acceptSuggestion,
                      onDismiss: _dismissSuggestion,
                    ),
                  ],

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
  final Function(Category) onSelect;

  const _CategoryPickerSheet({required this.type, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<CategoriesController>();
    
    return Obx(() {
      final categories = type == TransactionType.income 
          ? controller.incomeCategories 
          : controller.expenseCategories;

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Choisir une catégorie',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.grey),
                    onPressed: () {
                      // Navigate to Category Settings
                      Get.toNamed('/categories'); // Need to register this route
                    },
                  )
                ],
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
                                category.name,
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
    });
  }
}

/// Smart suggestion chip that appears when AI detects a category
class _SmartSuggestionChip extends StatelessWidget {
  final CategorySuggestion suggestion;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const _SmartSuggestionChip({
    required this.suggestion,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final categoryName = suggestion.category?.displayName ?? 'Autre';
    final categoryIcon = suggestion.category?.icon ?? '📦';
    final confidence = (suggestion.confidence * 100).toInt();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // AI Icon
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.sparkles,
              color: Colors.blue,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 10.w),

          // Suggestion text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      categoryIcon,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: confidence > 70 ? Colors.green.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '$confidence%',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: confidence > 70 ? Colors.green.shade700 : Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  suggestion.reason,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Accept button
          GestureDetector(
            onTap: onAccept,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Utiliser',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Dismiss button
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              CupertinoIcons.xmark,
              color: Colors.grey.shade400,
              size: 18.sp,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1);
  }
}