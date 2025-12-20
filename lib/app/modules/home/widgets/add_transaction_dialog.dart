// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/modules/settings/controllers/settings_controller.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/services/ml/contextual_brain.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:intl/intl.dart';

void showAddTransactionDialog(BuildContext context, TransactionType type,
    {TransactionCategory? initialCategory}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _AddTransactionSheet(type: type, initialCategory: initialCategory),
  );
}

class _AddTransactionSheet extends StatefulWidget {
  final TransactionType type;
  final TransactionCategory? initialCategory;

  const _AddTransactionSheet({
    required this.type,
    this.initialCategory,
  });

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
  bool _isSubmitting = false;

  // Contextual Prediction
  ContextualPrediction? _prediction;
  bool _showSparkle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
      _checkContextualPrediction();
      _applyInitialCategory();
    });
  }

  void _applyInitialCategory() {
    if (widget.initialCategory != null) {
      final financialContext = Get.find<FinancialContextService>();
      final category = financialContext.allCategories.firstWhereOrNull(
        (c) => c.icon == widget.initialCategory!.iconKey,
      );
      // Fallback: Try match by name if iconKey match fails (or if we want a more robust match)
      // Ideally we should match by ID, but ContextualAction gives us the Enum.
      // The Enum -> Category mapping is via `icon` usually.

      if (category != null) {
        setState(() {
          _selectedCategory = category;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkContextualPrediction() async {
    if (widget.type != TransactionType.expense) return;

    try {
      final brain = Get.find<ContextualBrain>();
      final prediction = brain.predict(DateTime.now());

      if (prediction != null && prediction.confidence > 0.4) {
        setState(() {
          _prediction = prediction;
          _showSparkle = true;
        });

        if (prediction.confidence > 0.7) {
          _applyPrediction(prediction);
        }
      }
    } catch (e) {
      debugPrint('Error getting contextual prediction: $e');
    }
  }

  void _applyPrediction(ContextualPrediction prediction) {
    final financialContext = Get.find<FinancialContextService>();
    final category = financialContext.allCategories
        .firstWhereOrNull((c) => c.id == prediction.categoryId);

    if (category != null) {
      setState(() {
        _selectedCategory = category;
        _amountController.text =
            _formatAmount(prediction.amount.toInt().toString());
      });
      HapticFeedback.mediumImpact();
    }
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

  /// Validates that the selected category matches the transaction type
  bool _validateCategoryType() {
    if (_selectedCategory == null) return false;
    return _selectedCategory!.type == widget.type;
  }

  Future<void> _addTransaction() async {
    // Prevent double submission
    if (_isSubmitting || _loading) {
      return;
    }

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

    // Mark as submitting
    setState(() {
      _isSubmitting = true;
      _loading = true;
    });

    // Validate category type matches transaction type
    if (!_validateCategoryType()) {
      HapticFeedback.lightImpact();
      setState(() => _error = 'La catégorie ne correspond pas au type');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.type == TransactionType.income
                ? 'Veuillez sélectionner une catégorie de revenu'
                : 'Veuillez sélectionner une catégorie de dépense',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final amount = double.parse(numericAmount);
    final homeController = Get.find<HomeController>();

    // Check if this transaction will exceed the budget
    if (widget.type == TransactionType.expense) {
      final financialContext = Get.find<FinancialContextService>();
      final categoryBudgets = financialContext.allBudgets
          .where((b) => b.categoryId == _selectedCategory!.id)
          .toList();

      if (categoryBudgets.isNotEmpty && mounted) {
        final budget = categoryBudgets.first;
        final currentSpent = financialContext.getSpentAmountForCategory(
          _selectedCategory!.id,
          DateTime.now().year,
          DateTime.now().month,
        );
        final newTotal = currentSpent + amount;

        if (newTotal > budget.amount) {
          final overage = newTotal - budget.amount;
          final proceed = await _showBudgetWarningDialog(
            categoryName: _selectedCategory!.name,
            budgetAmount: budget.amount,
            currentSpent: currentSpent,
            transactionAmount: amount,
            overage: overage,
          );

          if (!proceed) {
            if (mounted) {
              setState(() {
                _loading = false;
                _isSubmitting = false;
              });
            }
            return;
          }
        }
      }
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _error = null;
    });

    final transaction = LocalTransaction.create(
      amount: amount,
      description: _descriptionController.text.trim().isEmpty
          ? _selectedCategory!.name
          : _descriptionController.text.trim(),
      date: DateTime.now(),
      type: widget.type,
      categoryId: _selectedCategory!.id,
    );

    try {
      homeController.addTransaction(transaction);

      if (mounted) {
        // Delay pop to allow UI to settle
        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted) {
          NavigationHelper.safeBack();
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _isSubmitting = false;
          _error = 'Erreur: ${e.toString()}';
        });
        HapticFeedback.heavyImpact();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
          setState(() {
            _selectedCategory = category;
            _showSparkle = false; // Clear AI state
          });
          NavigationHelper.safeBack();
        },
      ),
    );
  }

  Future<bool> _showBudgetWarningDialog({
    required String categoryName,
    required double budgetAmount,
    required double currentSpent,
    required double transactionAmount,
    required double overage,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentUsed =
        ((currentSpent + transactionAmount) / budgetAmount * 100).clamp(0, 999);

    String formatAmount(double amount) {
      return NumberFormat.compact(locale: 'fr_FR').format(amount.round());
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 12.h),
                decoration: BoxDecoration(
                  color:
                      KoalaColors.textSecondary(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Warning header with gradient
              Container(
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: KoalaColors.destructive,
                  borderRadius: BorderRadius.circular(KoalaRadius.xl),
                  boxShadow: KoalaShadows.md,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dépassement de budget',
                            style: KoalaTypography.heading4(context).copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            categoryName,
                            style: KoalaTypography.bodyMedium(context).copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stats cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    // Progress bar
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: KoalaColors.surface(context),
                        borderRadius: BorderRadius.circular(KoalaRadius.lg),
                        border: Border.all(color: KoalaColors.border(context)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Utilisation du budget',
                                style: KoalaTypography.bodyMedium(context),
                              ),
                              Text(
                                '${percentUsed.toStringAsFixed(0)}%',
                                style:
                                    KoalaTypography.heading4(context).copyWith(
                                  color: KoalaColors.destructive,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(KoalaRadius.sm),
                            child: LinearProgressIndicator(
                              value: (percentUsed / 100).clamp(0, 1),
                              minHeight: 10.h,
                              backgroundColor: KoalaColors.background(context),
                              valueColor: AlwaysStoppedAnimation(
                                percentUsed > 100
                                    ? KoalaColors.destructive
                                    : KoalaColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Amount breakdown
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: KoalaColors.surface(context),
                        borderRadius: BorderRadius.circular(KoalaRadius.lg),
                        border: Border.all(color: KoalaColors.border(context)),
                      ),
                      child: Column(
                        children: [
                          _PremiumBudgetRow(
                            icon: CupertinoIcons.chart_pie,
                            iconColor: Colors.blue,
                            label: 'Budget alloué',
                            value: '${formatAmount(budgetAmount)} F',
                            isDark: isDark,
                          ),
                          Divider(
                              height: 20.h, color: KoalaColors.border(context)),
                          _PremiumBudgetRow(
                            icon: CupertinoIcons.money_dollar_circle,
                            iconColor: Colors.orange,
                            label: 'Déjà dépensé',
                            value: '${formatAmount(currentSpent)} F',
                            isDark: isDark,
                          ),
                          Divider(
                              height: 20.h, color: KoalaColors.border(context)),
                          _PremiumBudgetRow(
                            icon: CupertinoIcons.plus_circle,
                            iconColor: Colors.purple,
                            label: 'Cette transaction',
                            value: '${formatAmount(transactionAmount)} F',
                            isDark: isDark,
                          ),
                          Divider(
                              height: 20.h, color: KoalaColors.border(context)),
                          _PremiumBudgetRow(
                            icon: CupertinoIcons.exclamationmark_circle,
                            iconColor: KoalaColors.destructive,
                            label: 'Dépassement',
                            value: '+${formatAmount(overage)} F',
                            isDark: isDark,
                            isWarning: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Action buttons
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16.w, 0, 16.w, 32.h), // Added bottom padding
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        color: KoalaColors.surface(context),
                        borderRadius: BorderRadius.circular(KoalaRadius.md),
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Annuler',
                          style: KoalaTypography.label(context).copyWith(
                            color: KoalaColors.text(context),
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        color: KoalaColors.destructive,
                        borderRadius: BorderRadius.circular(KoalaRadius.md),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Confirmer',
                          style: KoalaTypography.label(context).copyWith(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    // Expand to 85% when keyboard visible, otherwise 50%
    final dialogHeight = isKeyboardVisible
        ? MediaQuery.of(context).size.height * 0.85
        : MediaQuery.of(context).size.height * 0.55;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: dialogHeight,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const KoalaDragHandle(),

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: widget.type == TransactionType.income
                        ? KoalaColors.success.withValues(alpha: 0.1)
                        : KoalaColors.destructive.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(KoalaRadius.lg),
                  ),
                  child: Icon(
                    widget.type == TransactionType.income
                        ? CupertinoIcons.arrow_down_left
                        : CupertinoIcons.arrow_up_right,
                    color: widget.type == TransactionType.income
                        ? KoalaColors.success
                        : KoalaColors.destructive,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.type == TransactionType.income
                              ? 'Ajouter un revenu'
                              : 'Ajouter une dépense',
                          style: KoalaTypography.heading3(context),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    NavigationHelper.safeBack();
                  },
                  icon: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: KoalaColors.textSecondary(context),
                    size: 28.sp,
                  ),
                ),
              ],
            ),
          ),

          // Content - scrollable to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  children: [
                    // Amount input
                    Column(
                      children: [
                        TextField(
                          controller: _amountController,
                          focusNode: _amountFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: false),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w300,
                            fontSize: 48.sp,
                            height: 1.1,
                            color: (_showSparkle && _prediction != null)
                                ? const Color(0xFFB8860B) // Dark Golden Rod
                                : (widget.type == TransactionType.income
                                    ? Colors.green
                                    : Colors.orange),
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            // Clear AI state on manual edit
                            if (_showSparkle) {
                              setState(() => _showSparkle = false);
                            }

                            final formatted = _formatAmount(value);
                            if (formatted != value) {
                              _amountController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                    offset: formatted.length),
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
                      ],
                    ).animate().scale(
                          duration: 500.ms,
                          curve: Curves.easeOutBack,
                        ),

                    if (_showSparkle && _prediction != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.sparkles,
                              size: 14.sp,
                              color: const Color(0xFFFFD700), // Gold
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              _prediction!.reason,
                              style: TextStyle(
                                color:
                                    const Color(0xFFB8860B), // Dark Golden Rod
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ).animate().fadeIn().slideY(begin: -0.5),
                      ),

                    SizedBox(height: 20.h),

                    // Category selector
                    GestureDetector(
                      onTap: _showCategoryPicker,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: (_showSparkle && _prediction != null)
                              ? const Color(0xFFFFFDF5) // Light Gold Tint
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: (_showSparkle && _prediction != null)
                                ? const Color(0xFFFFD700) // Gold
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: _selectedCategory != null
                                    ? Color(_selectedCategory!.colorValue)
                                        .withValues(alpha: 0.2)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: _selectedCategory != null
                                    ? CategoryIcon(
                                        iconKey: _selectedCategory!.icon,
                                        size: 24.sp,
                                        color: Color(
                                            _selectedCategory!.colorValue),
                                      )
                                    : Icon(
                                        CupertinoIcons.cube_box,
                                        size: 24.sp,
                                        color: Colors.grey.shade400,
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

                    SizedBox(height: 30.h),

                    if (_error != null) ...[
                      SizedBox(height: 16.h),
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Obx(() {
                          final settingsController =
                              Get.find<SettingsController>();
                          final errorWidget = Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          );

                          // Only apply shake animation if reduce motion is not enabled
                          if (settingsController.reduceMotion.value) {
                            return errorWidget;
                          }
                          return errorWidget.animate().shake(duration: 300.ms);
                        }),
                      ),
                    ],

                    // Add button with Safe Area protection
                    AnimatedScale(
                      scale: _buttonPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: AnimatedOpacity(
                        opacity: _loading ? 0.7 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: double.infinity,
                          height: 56.h,
                          margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).padding.bottom +
                                  16.h), // Safe area + padding
                          child: CupertinoButton(
                            color: (_showSparkle && _prediction != null)
                                ? const Color(0xFFDAA520) // Goldenrod
                                : Colors.black,
                            borderRadius: BorderRadius.circular(16.r),
                            onPressed: (_loading || _isSubmitting)
                                ? null
                                : () async {
                                    setState(() => _buttonPressed = true);
                                    await Future.delayed(
                                      const Duration(milliseconds: 100),
                                    );
                                    if (mounted) {
                                      setState(() => _buttonPressed = false);
                                      _addTransaction();
                                    }
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
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    (_showSparkle && _prediction != null)
                                        ? 'Confirmer la suggestion'
                                        : 'Ajouter',
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
                    icon: const Icon(Icons.settings, color: Colors.grey),
                    onPressed: () {
                      Get.toNamed('/categories');
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CategoryIcon(
                            iconKey: category.icon,
                            size: 32.sp,
                            color: Color(category.colorValue),
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

/// Premium helper widget for displaying budget warning rows
class _PremiumBudgetRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isDark;
  final bool isWarning;

  const _PremiumBudgetRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isDark,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14.sp,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isWarning
                ? const Color(0xFFFF3B30)
                : (isDark ? Colors.white : Colors.black87),
            fontSize: 15.sp,
            fontWeight: isWarning ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
