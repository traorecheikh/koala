// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';

void showUserSetupDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (context) => const _UserSetupSheet(),
  );
}

class _UserSetupSheet extends StatefulWidget {
  const _UserSetupSheet();

  @override
  State<_UserSetupSheet> createState() => _UserSetupSheetState();
}

class _UserSetupSheetState extends State<_UserSetupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _salaryController = TextEditingController();
  final _paydayController = TextEditingController();
  final _ageController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _salaryFocusNode = FocusNode();
  final _paydayFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();

  String _budgetingType = '50/30/20';
  bool _loading = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _salaryController.dispose();
    _paydayController.dispose();
    _ageController.dispose();
    _nameFocusNode.dispose();
    _salaryFocusNode.dispose();
    _paydayFocusNode.dispose();
    _ageFocusNode.dispose();
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

  bool get _canContinue {
    switch (_currentStep) {
      case 0:
        return _fullNameController.text.trim().isNotEmpty;
      case 1:
        return _salaryController.text.trim().isNotEmpty;
      case 2:
        final day = int.tryParse(_paydayController.text);
        return day != null && day >= 1 && day <= 31;
      case 3:
        final age = int.tryParse(_ageController.text);
        return age != null && age > 0;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (!_canContinue) return;

    HapticFeedback.lightImpact();
    setState(() {
      if (_currentStep < 4) {
        _currentStep++;
        // Focus management
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (_currentStep) {
            case 1:
              _salaryFocusNode.requestFocus();
              break;
            case 2:
              _paydayFocusNode.requestFocus();
              break;
            case 3:
              _ageFocusNode.requestFocus();
              break;
          }
        });
      }
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep--);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.heavyImpact();
    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    final homeController = Get.find<HomeController>();
    final newUser = LocalUser(
      fullName: _fullNameController.text.trim(),
      salary: double.parse(_getNumericValue(_salaryController.text)),
      payday: int.parse(_paydayController.text),
      age: int.parse(_ageController.text),
      budgetingType: _budgetingType,
    );

    homeController.user.value = newUser;

    if (mounted) {
      Navigator.pop(context);
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
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
                child: Column(
                  children: [
                    Text(
                      'Bienvenue sur Koaa',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Configurons votre profil',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Progress indicator
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: Container(
                        height: 3.h,
                        margin: EdgeInsets.only(right: index < 4 ? 8.w : 0),
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? Colors.black
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ).animate().fadeIn(duration: 300.ms),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: 32.h,
                    bottom: keyboardHeight > 0 ? keyboardHeight + 24.h : 24.h,
                    left: 24.w,
                    right: 24.w,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildStepContent(),
                  ),
                ),
              ),

              // Navigation buttons
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      SizedBox(
                        width: 56.w,
                        height: 56.h,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16.r),
                          onPressed: _previousStep,
                          child: Icon(
                            CupertinoIcons.back,
                            color: Colors.black,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    if (_currentStep > 0) SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 56.h,
                        child: CupertinoButton(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16.r),
                          onPressed: _canContinue
                              ? (_currentStep == 4 ? _submit : _nextStep)
                              : null,
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
                                      'Enregistrement...',
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  _currentStep == 4 ? 'Terminer' : 'Continuer',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildNameStep();
      case 1:
        return _buildSalaryStep();
      case 2:
        return _buildPaydayStep();
      case 3:
        return _buildAgeStep();
      case 4:
        return _buildBudgetingTypeStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNameStep() {
    return Column(
      key: const ValueKey('nameStep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comment vous appelez-vous ?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 24.h),
        _buildTextField(
          controller: _fullNameController,
          focusNode: _nameFocusNode,
          hintText: 'Votre nom complet',
          keyboardType: TextInputType.name,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  Widget _buildSalaryStep() {
    return Column(
      key: const ValueKey('salaryStep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quel est votre salaire mensuel ?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 24.h),
        _buildTextField(
          controller: _salaryController,
          focusNode: _salaryFocusNode,
          hintText: '0',
          keyboardType: TextInputType.number,
          suffix: 'FCFA',
          onChanged: (value) {
            final formatted = _formatAmount(value);
            if (formatted != value) {
              _salaryController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
            setState(() {});
          },
          onSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  Widget _buildPaydayStep() {
    return Column(
      key: const ValueKey('paydayStep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quel jour du mois êtes-vous payé ?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Entrez un jour entre 1 et 31',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 24.h),
        _buildTextField(
          controller: _paydayController,
          focusNode: _paydayFocusNode,
          hintText: 'Ex: 15',
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  Widget _buildAgeStep() {
    return Column(
      key: const ValueKey('ageStep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quel âge avez-vous ?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 24.h),
        _buildTextField(
          controller: _ageController,
          focusNode: _ageFocusNode,
          hintText: 'Votre âge',
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  Widget _buildBudgetingTypeStep() {
    return Column(
      key: const ValueKey('budgetingStep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez votre méthode budgétaire',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 24.h),
        _buildBudgetingOption(
          '50/30/20',
          '50% besoins, 30% loisirs, 20% épargne',
        ),
        SizedBox(height: 12.h),
        _buildBudgetingOption(
          '70/20/10',
          '70% besoins, 20% loisirs, 10% épargne',
        ),
        SizedBox(height: 12.h),
        _buildBudgetingOption(
          'Zero-Based',
          'Chaque franc a une destination',
        ),
      ],
    );
  }

  Widget _buildBudgetingOption(String type, String description) {
    final isSelected = _budgetingType == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _budgetingType = type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: Colors.white,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    TextInputType? keyboardType,
    String? suffix,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
          if (suffix != null)
            Text(
              suffix,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }
}
