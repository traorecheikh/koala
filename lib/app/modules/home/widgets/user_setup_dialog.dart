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
  final _ageController = TextEditingController();
  final _customJobController = TextEditingController();
  final _salaryController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();

  String? _selectedJobTitle;
  double _selectedSalary = 150000;
  PaymentFrequency _selectedFrequency = PaymentFrequency.monthly;
  DateTime _paymentDate = DateTime.now();
  List<Job> _jobs = [];

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
        return age != null && age > 0;
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
    NavigationHelper.safeBack();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.heavyImpact();
    setState(() => _loading = true);

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

    if (mounted) {
      NavigationHelper.safeBack();
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
              Container(
                width: 36.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenue sur Koaa',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 24.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Configurons votre profil pour commencer.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade600,
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
                          foregroundColor: Colors.grey.shade600,
                        ),
                        child: const Text('Passer'),
                      ),
                  ],
                ),
              ),

              // Enhanced Progress Indicator
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: List.generate(4, (index) {
                    final isActive = index <= _currentStep;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4.h,
                        margin: EdgeInsets.only(right: index < 3 ? 8.w : 0),
                        decoration: BoxDecoration(
                          color: isActive ? theme.colorScheme.primary : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ).animate().fadeIn(duration: 300.ms),

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

              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: SizedBox(
                          width: 56.w,
                          height: 56.h,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            onPressed: _previousStep,
                            child: Icon(CupertinoIcons.back, color: Colors.black),
                          ),
                        ),
                      ),
                    Expanded(
                      child: SizedBox(
                        height: 56.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          onPressed: _canContinue ? (_currentStep == 3 ? _submit : _nextStep) : null,
                          child: _loading
                              ? const CupertinoActivityIndicator(color: Colors.white)
                              : Text(
                                  _currentStep == 3 ? 'Terminer' : 'Continuer',
                                  style: TextStyle(
                                    fontSize: 16.sp,
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
      case 0: return _buildNameStep();
      case 1: return _buildJobsStep();
      case 2: return _buildAgeStep();
      case 3: return _buildBudgetingTypeStep();
      default: return const SizedBox.shrink();
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

  Widget _buildJobsStep() {
    return Column(
      key: const ValueKey('jobsStep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajoutez vos revenus',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8.h),
        Text(
          'Vous pouvez ajouter plusieurs sources de revenus.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15.sp),
        ),
        SizedBox(height: 24.h),

        if (_jobs.isNotEmpty) ...[
          ..._jobs.asMap().entries.map((entry) {
            final index = entry.key;
            final job = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                      ],
                    ),
                    child: Icon(CupertinoIcons.briefcase, color: Colors.black, size: 20.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.name,
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${job.frequency.displayName} • FCFA ${_formatAmount(job.amount.toString())}',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.minus_circle, color: Colors.red.shade400),
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
          }).toList(),
          SizedBox(height: 24.h),
        ],

        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _jobs.isEmpty ? 'Ajouter une source' : 'Ajouter une autre source',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: _selectedJobTitle,
                decoration: InputDecoration(
                  hintText: 'Type de poste',
                  fillColor: Colors.grey.shade50,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
                items: _jobTitles.map((job) => DropdownMenuItem(value: job, child: Text(job))).toList(),
                onChanged: (value) => setState(() => _selectedJobTitle = value),
              ),
              
              if (_selectedJobTitle == 'Autre') ...[
                SizedBox(height: 12.h),
                TextField(
                  controller: _customJobController,
                  decoration: InputDecoration(
                    hintText: 'Précisez votre poste',
                    fillColor: Colors.grey.shade50,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                  ),
                ),
              ],
              
              SizedBox(height: 20.h),
              Text('Revenu Mensuel', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
              SizedBox(height: 8.h),
              
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.black),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        suffixText: 'FCFA',
                        suffixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
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
                        activeTrackColor: Colors.black,
                        inactiveTrackColor: Colors.grey.shade300,
                        thumbColor: Colors.black,
                        trackHeight: 4.h,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
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
                            _salaryController.text = _formatAmount(newValue.toStringAsFixed(0));
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
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: _canAddJob() ? _addJob : null,
                  child: const Text('Ajouter ce revenu', style: TextStyle(color: Colors.white)),
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
      _salaryController.text = _formatAmount(_selectedSalary.toStringAsFixed(0));
      _selectedFrequency = PaymentFrequency.monthly;
    });

    HapticFeedback.mediumImpact();
  }

  Widget _buildAgeStep() {
    return Column(
      key: const ValueKey('ageStep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quel âge avez-vous ?', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700)),
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
        Text('Votre méthode budgétaire', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 24.h),
        _buildBudgetingOption('50/30/20', '50% besoins, 30% loisirs, 20% épargne'),
        SizedBox(height: 12.h),
        _buildBudgetingOption('70/20/10', '70% besoins, 20% loisirs, 10% épargne'),
        SizedBox(height: 12.h),
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
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade200, width: 1.5),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.black)),
                  SizedBox(height: 4.h),
                  Text(description, style: TextStyle(fontSize: 14.sp, color: isSelected ? Colors.white70 : Colors.grey.shade600)),
                ],
              ),
            ),
            if (isSelected) Icon(CupertinoIcons.check_mark_circled_solid, color: Colors.white, size: 24.sp),
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          suffixText: suffix,
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}