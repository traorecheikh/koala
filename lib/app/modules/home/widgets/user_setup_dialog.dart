// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koaa/app/services/isar_service.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';
import 'package:koaa/app/core/utils/icon_helper.dart';
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
  String _selectedDuration =
      'permanent'; // permanent, 1_month, 3_months, 6_months, 1_year
  final DateTime _paymentDate = DateTime.now();
  final List<Job> _jobs = [];

  DateTime? _getDurationEndDate() {
    final now = DateTime.now();
    switch (_selectedDuration) {
      case '1_month':
        return DateTime(now.year, now.month + 1, now.day);
      case '3_months':
        return DateTime(now.year, now.month + 3, now.day);
      case '6_months':
        return DateTime(now.year, now.month + 6, now.day);
      case '1_year':
        return DateTime(now.year + 1, now.month, now.day);
      default:
        return null; // permanent
    }
  }

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

  // Catch-up spending state (categoryId -> amount)
  final Map<String, double> _catchUpSpending = {};
  final Map<String, TextEditingController> _catchUpControllers = {};

  // Check if we should show the catch-up step (day > 5 of month)
  bool get _shouldShowCatchUpStep => DateTime.now().day > 5;

  // Total steps: 4 if no catch-up, 5 if catch-up shown
  int get _totalSteps => _shouldShowCatchUpStep ? 5 : 4;

  // The final step index (for submit check)
  int get _lastStepIndex => _totalSteps - 1;

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
      case 4: // Catch-up step (only if _shouldShowCatchUpStep)
        return true; // Always allow continuing (catch-up is optional)
      default:
        return false;
    }
  }

  void _nextStep() {
    if (!_canContinue) return;
    HapticFeedback.lightImpact();
    setState(() {
      if (_currentStep < _lastStepIndex) {
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
      final jobs = _jobs;
      for (final job in jobs) {
        IsarService.addJob(job);
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
        firstLaunchDate: DateTime.now(),
        hasCompletedCatchUp: _shouldShowCatchUpStep,
      );

      await IsarService.saveUser(newUser);
      Hive.box('settingsBox').put('hasUser', true);

      homeController.user.value = newUser;

      // Generate initial transactions based on new jobs
      await homeController.generateJobIncomeTransactions();

      // Add catch-up transactions if user entered any
      if (_catchUpSpending.isNotEmpty) {
        await homeController.addCatchUpTransactions(_catchUpSpending);
      }

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
      case 4:
        return 'Rattrapage du mois';
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
      case 4:
        return 'Combien avez-vous dépensé ce mois avant aujourd\'hui ?';
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
                const KoalaDragHandle(),

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
                                color: KoalaColors.primaryUi(context),
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
                  label:
                      'Progression: étape ${_currentStep + 1} sur $_totalSteps',
                  readOnly: true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: KoalaSpacing.xl),
                    child: Row(
                      children: List.generate(_totalSteps, (index) {
                        final isActive = index <= _currentStep;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 4.h,
                            margin: EdgeInsets.only(
                                right: index < _totalSteps - 1 ? 8.w : 0),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? KoalaColors.primaryUi(context)
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
                                    color: KoalaColors.primaryUi(context)),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Tooltip(
                          message: _currentStep == _lastStepIndex
                              ? 'Terminer la configuration'
                              : 'Continuer vers l\'étape suivante',
                          child: SizedBox(
                            height: 56.h,
                            child: KoalaButton(
                              text: _currentStep == _lastStepIndex
                                  ? 'Terminer'
                                  : 'Continuer',
                              onPressed: _canContinue
                                  ? (_currentStep == _lastStepIndex
                                      ? _submit
                                      : _nextStep)
                                  : () {}, // Disabled state handled by button or parent
                              isLoading: _loading,
                              backgroundColor: _canContinue
                                  ? KoalaColors.primaryUi(context)
                                  : KoalaColors.primaryUi(context)
                                      .withValues(alpha: 0.5),
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
      case 4:
        return _buildCatchUpStep();
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Vos revenus',
          style: KoalaTypography.heading2(context),
        ),
        SizedBox(height: 8.h),
        Text(
          'Ajoutez vos sources de revenus réguliers.',
          style: KoalaTypography.bodyMedium(context)
              .copyWith(color: KoalaColors.textSecondary(context)),
        ),
        SizedBox(height: 32.h),

        // Added Jobs List (Cards)
        if (_jobs.isNotEmpty) ...[
          ..._jobs.asMap().entries.map((entry) {
            final index = entry.key;
            final job = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: KoalaColors.surface(context),
                  borderRadius: BorderRadius.circular(KoalaRadius.md),
                  boxShadow: KoalaShadows.sm,
                  border: Border.all(color: KoalaColors.border(context)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: KoalaColors.primaryUi(context)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(KoalaRadius.sm),
                      ),
                      child: Icon(CupertinoIcons.briefcase_fill,
                          color: KoalaColors.primaryUi(context), size: 18.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.name,
                            style: KoalaTypography.bodyMedium(context)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${_formatAmount(job.amount.toStringAsFixed(0))} FCFA / mois',
                            style: KoalaTypography.caption(context),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(CupertinoIcons.delete,
                          color: KoalaColors.textSecondary(context)
                              .withValues(alpha: 0.5),
                          size: 20.sp),
                      onPressed: () {
                        setState(() => _jobs.removeAt(index));
                      },
                    )
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.1, curve: Curves.easeOutQuart),
            );
          }),
          SizedBox(height: 12.h),
          Divider(color: KoalaColors.border(context)),
          SizedBox(height: 24.h),
        ],

        // Input Card
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: KoalaColors.surface(context),
            borderRadius: BorderRadius.circular(KoalaRadius.lg),
            border: Border.all(color: KoalaColors.border(context)),
            boxShadow: KoalaShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _jobs.isEmpty ? 'Ajouter un revenu' : 'Ajouter un autre',
                style: KoalaTypography.heading4(context),
              ),
              SizedBox(height: 20.h),

              // Job Selector
              InkWell(
                onTap: _showJobSelector,
                borderRadius: BorderRadius.circular(KoalaRadius.md),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: KoalaColors.inputBackground(context),
                    borderRadius: BorderRadius.circular(KoalaRadius.md),
                    border: Border.all(color: KoalaColors.border(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.search,
                          size: 20.sp,
                          color: KoalaColors.textSecondary(context)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _selectedJobTitle ?? 'Sélectionner le poste',
                          style: _selectedJobTitle != null
                              ? KoalaTypography.bodyMedium(context)
                                  .copyWith(fontWeight: FontWeight.w500)
                              : KoalaTypography.bodyMedium(context).copyWith(
                                  color: KoalaColors.textSecondary(context)),
                        ),
                      ),
                      Icon(CupertinoIcons.chevron_down,
                          size: 16.sp,
                          color: KoalaColors.textSecondary(context)),
                    ],
                  ),
                ),
              ),

              if (_selectedJobTitle == 'Autre') ...[
                SizedBox(height: 12.h),
                KoalaTextField(
                  controller: _customJobController,
                  label: 'Précisez le poste',
                  validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                ),
              ],

              SizedBox(height: 24.h),

              // Hero Amount Input
              Center(
                child: Column(
                  children: [
                    Text(
                      'Revenu Mensuel',
                      style: KoalaTypography.caption(context)
                          .copyWith(color: KoalaColors.textSecondary(context)),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        IntrinsicWidth(
                          child: TextField(
                            controller: _salaryController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: KoalaTypography.heading1(context).copyWith(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: KoalaColors.primaryUi(context),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              hintStyle:
                                  TextStyle(color: KoalaColors.border(context)),
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            onChanged: (val) {
                              final clean =
                                  val.replaceAll(RegExp(r'[^0-9.]'), '');
                              if (clean.isNotEmpty) {
                                _selectedSalary = double.tryParse(clean) ?? 0;
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'FCFA',
                          style: KoalaTypography.heading4(context).copyWith(
                            color: KoalaColors.textSecondary(context),
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Add Button
              KoalaButton(
                text: 'Ajouter ce revenu',
                onPressed: _canAddJob() ? _addJob : () {},
                backgroundColor: _canAddJob()
                    ? KoalaColors.primaryUi(context)
                    : KoalaColors.primaryUi(context).withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  void _showJobSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: KoalaColors.surface(context),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(KoalaRadius.lg)),
          ),
          child: Column(
            children: [
              // Handle
              const KoalaDragHandle(),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w)
                    .copyWith(bottom: 16.w),
                child: Row(
                  children: [
                    Text('Sélectionner un poste',
                        style: KoalaTypography.heading4(context)),
                    Spacer(),
                    IconButton(
                      icon: Icon(CupertinoIcons.xmark,
                          color: KoalaColors.textSecondary(context)),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              Divider(height: 1, color: KoalaColors.border(context)),

              // List
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _jobTitles.length,
                  separatorBuilder: (_, __) => Divider(
                      color:
                          KoalaColors.border(context).withValues(alpha: 0.5)),
                  itemBuilder: (context, index) {
                    final title = _jobTitles[index];
                    final isSelected = _selectedJobTitle == title;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedJobTitle = title);
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          children: [
                            Text(
                              title,
                              style: isSelected
                                  ? KoalaTypography.bodyMedium(context)
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: KoalaColors.primaryUi(context))
                                  : KoalaTypography.bodyMedium(context),
                            ),
                            Spacer(),
                            if (isSelected)
                              Icon(CupertinoIcons.checkmark_circle_fill,
                                  color: KoalaColors.primaryUi(context),
                                  size: 20.sp),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
      createdAt: DateTime.now(), // Added missing required argument
      endDate: _getDurationEndDate(),
    );

    setState(() {
      _jobs.add(job);
      _selectedJobTitle = null;
      _customJobController.clear();
      _selectedSalary = 150000;
      _salaryController.text =
          _formatAmount(_selectedSalary.toStringAsFixed(0));
      _selectedFrequency = PaymentFrequency.monthly;
      _selectedDuration = 'permanent';
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
          color: isSelected
              ? KoalaColors.primaryUi(context)
              : KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(KoalaRadius.md),
          border: Border.all(
              color: isSelected
                  ? KoalaColors.primary
                  : KoalaColors.border(context),
              width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color:
                          KoalaColors.primaryUi(context).withValues(alpha: 0.2),
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
                          color: isSelected
                              ? Colors.white
                              : KoalaColors.primaryUi(context))),
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

  Widget _buildCatchUpStep() {
    // START with hardcoded defaults - guarantees categories are always available
    List<Category> expenseCategories = [
      TransactionCategory.food,
      TransactionCategory.transport,
      TransactionCategory.shopping,
      TransactionCategory.bills,
      TransactionCategory.groceries,
      TransactionCategory.entertainment,
      TransactionCategory.health,
      TransactionCategory.subscriptions,
    ].asMap().entries.map((entry) {
      final cat = entry.value;
      final color = Colors.primaries[entry.key % Colors.primaries.length];
      return Category(
        id: cat.name,
        name: cat.displayName,
        icon: cat.iconKey,
        colorValue: color.value,
        type: TransactionType.expense,
        isDefault: true,
      );
    }).toList();

    // Use hardcoded defaults for catch-up categories
    // This allows us to map to accurate IDs for initial transactions
    // without relying on legacy Hive boxes which may be empty.

    return Column(
      key: const ValueKey('catchUpStep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vos dépenses ce mois',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: KoalaSpacing.sm),
        Container(
          padding: EdgeInsets.all(KoalaSpacing.md),
          decoration: BoxDecoration(
            color: KoalaColors.primaryUi(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(KoalaRadius.md),
            border: Border.all(
                color: KoalaColors.primaryUi(context).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(CupertinoIcons.info_circle,
                  color: KoalaColors.primaryUi(context), size: 20.sp),
              SizedBox(width: KoalaSpacing.sm),
              Expanded(
                child: Text(
                  'Optionnel: Entrez vos dépenses depuis le 1er du mois.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: KoalaColors.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: KoalaSpacing.xl),
        ...expenseCategories.take(8).map((category) {
          // Initialize controller if not exists
          _catchUpControllers.putIfAbsent(
            category.id,
            () => TextEditingController(),
          );
          final controller = _catchUpControllers[category.id]!;

          return Container(
            margin: EdgeInsets.only(bottom: KoalaSpacing.md),
            height: 60.h, // Ensure minimum touch target height
            padding: EdgeInsets.symmetric(
              horizontal: KoalaSpacing.lg,
              vertical: KoalaSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: KoalaColors.inputBackground(context),
              borderRadius: BorderRadius.circular(KoalaRadius.md),
              border: Border.all(color: KoalaColors.border(context)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: Color(category.colorValue).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CategoryIcon(
                      iconKey: category.icon,
                      size: 22.sp,
                      color: Color(category.colorValue),
                    ),
                  ),
                ),
                SizedBox(width: KoalaSpacing.md),
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: 120.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: KoalaColors.surface(context),
                    borderRadius: BorderRadius.circular(KoalaRadius.sm),
                    border: Border.all(color: KoalaColors.border(context)),
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: '0 F',
                      hintStyle: TextStyle(
                        color: KoalaColors.textSecondary(context),
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: KoalaSpacing.sm,
                        vertical: KoalaSpacing.sm,
                      ),
                    ),
                    onChanged: (value) {
                      final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                      if (digitsOnly.isNotEmpty) {
                        _catchUpSpending[category.id] =
                            double.parse(digitsOnly);
                      } else {
                        _catchUpSpending.remove(category.id);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
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
