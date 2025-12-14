// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/core/design_system.dart';

void showUserSetupDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
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
  final _ageController = TextEditingController();
  final _customJobController = TextEditingController();
  final _salaryController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();

  String? _selectedJobTitle;
  double _selectedSalary = 150000;
  PaymentFrequency _selectedFrequency = PaymentFrequency.monthly;
  final DateTime _paymentDate = DateTime.now();
  final List<Job> _jobs = [];

  final List<String> _jobTitles = [
    'Développeur FullStack',
    'Consultant Technique',
    'Ingénieur Logiciel',
    'Architecte Solution',
    'Chef de Projet IT',
    'DevOps Engineer',
    'Développeur Mobile',
    'Développeur Frontend',
    'Développeur Backend',
    'Administrateur Système',
    'Analyste Cybersécurité',
    'UX/UI Designer',
    'Product Manager',
    'Data Scientist',
    'Ingénieur IA/ML',
    'Analyste de Données',
    'Consultant ERP',
    'Testeur QA',
    'Enseignant',
    'Commerçant',
    'Santé / Médical',
    'Autre',
  ];

  String _budgetingType = '50/30/20';
  bool _loading = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _salaryController.text = _formatAmount(_selectedSalary.toStringAsFixed(0));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _customJobController.dispose();
    _salaryController.dispose();
    _nameFocusNode.dispose();
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

  bool get _canContinue {
    switch (_currentStep) {
      case 0:
        return _fullNameController.text.trim().isNotEmpty;
      case 1:
        return true;
      case 2:
        final age = int.tryParse(_ageController.text);
        return age != null && age > 0 && age <= 120;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (!_canContinue) return;
    HapticFeedback.lightImpact();
    setState(() {
      if (_currentStep < 3) {
        _currentStep++;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (_currentStep) {
            case 2:
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

  void _skipSetup() {
    if (_currentStep == 0 || _fullNameController.text.trim().isEmpty) {
      // First step or no data entered, allow direct skip
      NavigationHelper.safeBack();
    } else {
      // Show confirmation if user has entered data
      KoalaConfirmationDialog.show(
        context: context,
        title: 'Quitter la configuration ?',
        message: 'Vos informations ne seront pas sauvegardées.',
        confirmText: 'Quitter',
        isDestructive: true,
        onConfirm: () => NavigationHelper.safeBack(),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.heavyImpact();
    setState(() => _loading = true);

    try {
      final jobBox = Hive.box<Job>('jobBox');
      for (final job in _jobs) {
        await jobBox.put(job.id, job);
      }

      final homeController = Get.find<HomeController>();
      final totalMonthlyIncome = _jobs.fold(
        0.0,
        (sum, job) => sum + job.monthlyIncome,
      );
      final defaultPayday = _jobs.isNotEmpty ? _jobs.first.paymentDate.day : 1;

      final newUser = LocalUser(
        fullName: _fullNameController.text.trim(),
        salary: totalMonthlyIncome,
        payday: defaultPayday,
        age: int.parse(_ageController.text),
        budgetingType: _budgetingType,
      );

      homeController.user.value = newUser;

      // Generate initial transactions based on new jobs
      await homeController.generateJobIncomeTransactions();

      if (mounted) {
        NavigationHelper.safeBack();
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: ${e.toString()}'),
            backgroundColor: KoalaColors.destructive,
          ),
        );
      }
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Bienvenue sur Koaa';
      case 1:
        return 'Vos revenus';
      case 2:
        return 'Votre profil';
      case 3:
        return 'Votre budget';
      default:
        return 'Configuration';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Configurons votre profil pour commencer.';
      case 1:
        return 'Ajoutez toutes vos sources de revenus.';
      case 2:
        return 'Quelques informations supplémentaires.';
      case 3:
        return 'Choisissez votre méthode de budgétisation.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: _currentStep == 0 || _fullNameController.text.trim().isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _skipSetup();
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.92,
          minHeight: screenHeight * 0.5,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(KoalaRadius.lg)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: 36.w,
                  height: 4.h,
                  margin: EdgeInsets.only(top: KoalaSpacing.md),
                  decoration: BoxDecoration(
                    color: KoalaColors.border(context),
                    borderRadius: BorderRadius.circular(KoalaRadius.xs),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(KoalaSpacing.xl, KoalaSpacing.xl,
                      KoalaSpacing.xl, KoalaSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Étape ${_currentStep + 1} sur 4',
                              style: KoalaTypography.caption(context).copyWith(
                                fontWeight: FontWeight.w600,
                                color: KoalaColors.primary,
                              ),
                            ),
                            SizedBox(height: KoalaSpacing.xs),
                            Text(
                              _getStepTitle(),
                              style: KoalaTypography.heading3(context).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: KoalaSpacing.sm),
                            Text(
                              _getStepSubtitle(),
                              style:
                                  KoalaTypography.bodyMedium(context).copyWith(
                                color: KoalaColors.textSecondary(context),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_currentStep == 0)
                        TextButton(
                          onPressed: _skipSetup,
                          style: TextButton.styleFrom(
                            foregroundColor: KoalaColors.textSecondary(context),
                          ),
                          child: const Text('Passer'),
                        ),
                    ],
                  ),
                ),

                // Enhanced Progress Indicator
                Semantics(
                  label: 'Progression: étape ${_currentStep + 1} sur 4',
                  readOnly: true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: KoalaSpacing.xl),
                    child: Row(
                      children: List.generate(4, (index) {
                        final isActive = index <= _currentStep;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 4.h,
                            margin: EdgeInsets.only(right: index < 3 ? 8.w : 0),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? theme.colorScheme.primary
                                  : KoalaColors.border(context),
                              borderRadius:
                                  BorderRadius.circular(KoalaRadius.xs),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: KoalaSpacing.xxxl,
                      bottom: keyboardHeight > 0
                          ? keyboardHeight + KoalaSpacing.xl
                          : KoalaSpacing.xl,
                      left: KoalaSpacing.xl,
                      right: KoalaSpacing.xl,
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

                Padding(
                  padding: EdgeInsets.fromLTRB(
                      KoalaSpacing.xl, 0, KoalaSpacing.xl, KoalaSpacing.xxxl),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Padding(
                          padding: EdgeInsets.only(right: KoalaSpacing.lg),
                          child: Tooltip(
                            message: 'Étape précédente',
                            child: SizedBox(
                              width: 56.w,
                              height: 56.h,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(KoalaRadius.md),
                                  ),
                                  side: BorderSide(
                                      color: KoalaColors.border(context)),
                                ),
                                onPressed: _previousStep,
                                child: Icon(CupertinoIcons.back,
                                    color: KoalaColors.primary),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Tooltip(
                          message: _currentStep == 3
                              ? 'Terminer la configuration'
                              : 'Continuer vers l\'étape suivante',
                          child: SizedBox(
                            height: 56.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: KoalaColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(KoalaRadius.md),
                                ),
                              ),
                              onPressed: _canContinue
                                  ? (_currentStep == 3 ? _submit : _nextStep)
                                  : null,
                              child: _loading
                                  ? const CupertinoActivityIndicator(
                                      color: Colors.white)
                                  : Text(
                                      _currentStep == 3
                                          ? 'Terminer'
                                          : 'Continuer',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
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
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildNameStep();
      case 1:
        return _buildJobsStep();
      case 2:
        return _buildAgeStep();
      case 3:
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
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: KoalaSpacing.xl),
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

  Widget _buildJobsStep() {
    return Column(
      key: const ValueKey('jobsStep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajoutez vos revenus',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: KoalaSpacing.sm),
        Text(
          'Vous pouvez ajouter plusieurs sources de revenus.',
          style: TextStyle(
              color: KoalaColors.textSecondary(context), fontSize: 15.sp),
        ),
        SizedBox(height: KoalaSpacing.xl),
        if (_jobs.isNotEmpty) ...[
          ..._jobs.asMap().entries.map((entry) {
            final index = entry.key;
            final job = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: KoalaSpacing.md),
              padding: EdgeInsets.all(KoalaSpacing.lg),
              decoration: BoxDecoration(
                color: KoalaColors.inputBackground(context),
                borderRadius: BorderRadius.circular(KoalaRadius.md),
                border: Border.all(color: KoalaColors.border(context)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(KoalaSpacing.sm),
                    decoration: BoxDecoration(
                      color: KoalaColors.surface(context),
                      borderRadius: BorderRadius.circular(KoalaRadius.sm),
                      boxShadow: [
                        BoxShadow(
                            color: KoalaColors.primary.withOpacity(0.05),
                            blurRadius: 4),
                      ],
                    ),
                    child: Icon(CupertinoIcons.briefcase,
                        color: KoalaColors.primary, size: 20.sp),
                  ),
                  SizedBox(width: KoalaSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.name,
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: KoalaSpacing.xs),
                        Text(
                          '${job.frequency.displayName} • FCFA ${_formatAmount(job.amount.toString())}',
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: KoalaColors.textSecondary(context)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.minus_circle,
                        color: Colors.red.shade400),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _jobs.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: KoalaSpacing.xl),
        ],
        Container(
          padding: EdgeInsets.all(KoalaSpacing.xl),
          decoration: BoxDecoration(
            color: KoalaColors.surface(context),
            borderRadius: BorderRadius.circular(KoalaRadius.lg),
            border: Border.all(color: KoalaColors.border(context)),
            boxShadow: [
              BoxShadow(
                  color: KoalaColors.primary.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _jobs.isEmpty
                    ? 'Ajouter une source'
                    : 'Ajouter une autre source',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: KoalaSpacing.lg),
              DropdownButtonFormField<String>(
                value: _selectedJobTitle,
                decoration: InputDecoration(
                  hintText: 'Type de poste',
                  fillColor: KoalaColors.inputBackground(context),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KoalaRadius.sm),
                      borderSide: BorderSide.none),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
                items: _jobTitles
                    .map(
                        (job) => DropdownMenuItem(value: job, child: Text(job)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedJobTitle = value),
              ),
              if (_selectedJobTitle == 'Autre') ...[
                SizedBox(height: KoalaSpacing.md),
                TextField(
                  controller: _customJobController,
                  decoration: InputDecoration(
                    hintText: 'Précisez votre poste',
                    fillColor: KoalaColors.inputBackground(context),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KoalaRadius.sm),
                        borderSide: BorderSide.none),
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              Text('Revenu Mensuel',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: KoalaColors.textSecondary(context))),
              SizedBox(height: KoalaSpacing.sm),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: KoalaColors.inputBackground(context),
                  borderRadius: BorderRadius.circular(KoalaRadius.md),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: KoalaColors.primary),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        suffixText: 'FCFA',
                        suffixStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                      onChanged: (value) {
                        String digits = value.replaceAll(RegExp(r'[^\d]'), '');
                        if (digits.isNotEmpty) {
                          double val = double.parse(digits);
                          setState(() => _selectedSalary = val);
                        } else {
                          setState(() => _selectedSalary = 0);
                        }
                      },
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: KoalaColors.primary,
                        inactiveTrackColor: KoalaColors.border(context),
                        thumbColor: KoalaColors.primary,
                        trackHeight: 4.h,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 10.r),
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: _selectedSalary.clamp(0, 1000000),
                        min: 0,
                        max: 1000000,
                        onChanged: (value) {
                          final newValue = (value / 5000).round() * 5000.0;
                          setState(() {
                            _selectedSalary = newValue;
                            _salaryController.text =
                                _formatAmount(newValue.toStringAsFixed(0));
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KoalaColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KoalaRadius.sm)),
                  ),
                  onPressed: _canAddJob() ? _addJob : null,
                  child: const Text('Ajouter ce revenu',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _canAddJob() {
    if (_selectedJobTitle == 'Autre') {
      return _customJobController.text.isNotEmpty && _selectedSalary > 0;
    }
    return _selectedJobTitle != null && _selectedSalary > 0;
  }

  void _addJob() {
    if (!_canAddJob()) return;

    String jobName = _selectedJobTitle!;
    if (jobName == 'Autre') {
      jobName = _customJobController.text.trim();
    }

    final job = Job(
      id: const Uuid().v4(),
      name: jobName,
      amount: _selectedSalary,
      frequency: _selectedFrequency,
      paymentDate: _paymentDate,
    );

    setState(() {
      _jobs.add(job);
      _selectedJobTitle = null;
      _customJobController.clear();
      _selectedSalary = 150000;
      _salaryController.text =
          _formatAmount(_selectedSalary.toStringAsFixed(0));
      _selectedFrequency = PaymentFrequency.monthly;
    });

    HapticFeedback.mediumImpact();
  }

  Widget _buildAgeStep() {
    final age = int.tryParse(_ageController.text);
    final hasError = _ageController.text.isNotEmpty &&
        (age == null || age <= 0 || age > 120);

    return Column(
      key: const ValueKey('ageStep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quel âge avez-vous ?',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: KoalaSpacing.xl),
        _buildTextField(
          controller: _ageController,
          focusNode: _ageFocusNode,
          hintText: 'Votre âge',
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _nextStep(),
        ),
        if (hasError) ...[
          SizedBox(height: KoalaSpacing.sm),
          Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_circle,
                size: 14.sp,
                color: KoalaColors.destructive,
              ),
              SizedBox(width: KoalaSpacing.xs),
              Text(
                age != null && age > 120
                    ? 'L\'âge doit être inférieur à 120 ans'
                    : 'Veuillez entrer un âge valide (1-120)',
                style: KoalaTypography.caption(context).copyWith(
                  color: KoalaColors.destructive,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBudgetingTypeStep() {
    return Column(
      key: const ValueKey('budgetingStep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Votre méthode budgétaire',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: KoalaSpacing.xl),
        _buildBudgetingOption(
            '50/30/20', '50% besoins, 30% loisirs, 20% épargne'),
        SizedBox(height: KoalaSpacing.md),
        _buildBudgetingOption(
            '70/20/10', '70% besoins, 20% loisirs, 10% épargne'),
        SizedBox(height: KoalaSpacing.md),
        _buildBudgetingOption('Zero-Based', 'Chaque franc a une destination'),
      ],
    );
  }

  Widget _buildBudgetingOption(String type, String description) {
    final isSelected = _budgetingType == type;
    return GestureDetector(
      onTap: () => setState(() => _budgetingType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(KoalaSpacing.xl),
        decoration: BoxDecoration(
          color:
              isSelected ? KoalaColors.primary : KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(KoalaRadius.md),
          border: Border.all(
              color: isSelected
                  ? KoalaColors.primary
                  : KoalaColors.border(context),
              width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: KoalaColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type,
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? Colors.white : KoalaColors.primary)),
                  SizedBox(height: KoalaSpacing.xs),
                  Text(description,
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected
                              ? Colors.white70
                              : KoalaColors.textSecondary(context))),
                ],
              ),
            ),
            if (isSelected)
              const Icon(CupertinoIcons.check_mark_circled_solid,
                  color: Colors.white, size: 24),
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: KoalaColors.inputBackground(context),
        borderRadius: BorderRadius.circular(KoalaRadius.md),
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: KoalaColors.textSecondary(context)),
          border: InputBorder.none,
          suffixText: suffix,
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

