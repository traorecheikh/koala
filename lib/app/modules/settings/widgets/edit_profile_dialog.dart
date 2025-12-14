import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';

void showEditProfileDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _EditProfileSheet(),
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _homeController = Get.find<HomeController>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _salaryController;
  late final TextEditingController _paydayController;
  late final TextEditingController _ageController;
  late String _budgetingType;
  bool _loading = false;
  bool _buttonPressed = false;

  @override
  void initState() {
    super.initState();
    final user = _homeController.user.value!;
    _fullNameController = TextEditingController(text: user.fullName);
    _salaryController = TextEditingController(text: user.salary.toString());
    _paydayController = TextEditingController(text: user.payday.toString());
    _ageController = TextEditingController(text: user.age.toString());
    _budgetingType = user.budgetingType;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _salaryController.dispose();
    _paydayController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      setState(() => _loading = true);

      await Future.delayed(const Duration(milliseconds: 800));

      final updatedUser = LocalUser(
        fullName: _fullNameController.text,
        salary: double.parse(_salaryController.text),
        payday: int.parse(_paydayController.text),
        age: int.parse(_ageController.text),
        budgetingType: _budgetingType,
      );
      _homeController.user.value = updatedUser;

      if (mounted) {
        NavigationHelper.safeBack();
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                Text(
                  'Modifier le profil',
                  style: theme.textTheme.headlineSmall,
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    NavigationHelper.safeBack();
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24.w,
                  24.h,
                  24.w,
                  keyboardHeight + 24.h,
                ),
                child: Column(
                  children:
                      [
                            _buildTextFormField(
                              controller: _fullNameController,
                              label: 'Nom complet',
                              icon: CupertinoIcons.person_fill,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre nom complet';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            _buildTextFormField(
                              controller: _salaryController,
                              label: 'Salaire',
                              icon: CupertinoIcons.money_dollar_circle_fill,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    double.tryParse(value) == null) {
                                  return 'Veuillez entrer un salaire valide';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            _buildTextFormField(
                              controller: _paydayController,
                              label: 'Jour de paie (Jour du mois)',
                              icon: CupertinoIcons.calendar,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre jour de paie';
                                }
                                final day = int.tryParse(value);
                                if (day == null || day < 1 || day > 31) {
                                  return 'Veuillez entrer un jour valide (1-31)';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            _buildTextFormField(
                              controller: _ageController,
                              label: 'Âge',
                              icon: CupertinoIcons.person_badge_plus_fill,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    int.tryParse(value) == null) {
                                  return 'Veuillez entrer un âge valide';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            _buildDropdown(),
                            SizedBox(height: 48.h),
                            _buildSaveButton(),
                          ]
                          .animate(interval: 100.ms)
                          .slideY(
                            begin: 0.2,
                            duration: 400.ms,
                            curve: Curves.easeOutQuart,
                          )
                          .fadeIn(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: 17.sp,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
          prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20.sp),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _budgetingType,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            CupertinoIcons.chart_pie_fill,
            color: Colors.grey.shade500,
            size: 20.sp,
          ),
        ),
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        items: ['50/30/20', '70/20/10', 'Zero-Based']
            .map((label) => DropdownMenuItem(value: label, child: Text(label)))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _budgetingType = value);
          }
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedScale(
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
                    await Future.delayed(const Duration(milliseconds: 100));
                    setState(() => _buttonPressed = false);
                    _saveProfile();
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
                    'Enregistrer les modifications',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}


