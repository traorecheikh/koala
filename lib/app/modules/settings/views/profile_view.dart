import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/core/design_system.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _homeController = Get.find<HomeController>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _salaryController;
  late final TextEditingController _paydayController;
  late final TextEditingController _ageController;
  late String _budgetingType;
  bool _loading = false;
  bool _isEditing = false;

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

      await Future.delayed(const Duration(milliseconds: 500));

      final currentUser = _homeController.user.value;

      final updatedUser = LocalUser(
        fullName: _fullNameController.text,
        salary: double.parse(_salaryController.text),
        payday: int.parse(_paydayController.text),
        age: int.parse(_ageController.text),
        budgetingType: _budgetingType,
        firstLaunchDate: currentUser?.firstLaunchDate,
        hasCompletedCatchUp: currentUser?.hasCompletedCatchUp ?? false,
      );

      final userBox = Hive.box<LocalUser>('userBox');
      await userBox.put('currentUser', updatedUser);

      _homeController.user.value = updatedUser;

      if (mounted) {
        setState(() {
          _loading = false;
          _isEditing = false;
        });
        HapticFeedback.mediumImpact();
        Get.snackbar(
          'Profil mis à jour',
          'Vos informations ont été enregistrées',
          backgroundColor: KoalaColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16.w),
        );
      }
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _homeController.user.value!;

    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              sliver: SliverToBoxAdapter(
                child: _buildHeader(context),
              ),
            ),

            // Profile Card
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverToBoxAdapter(
                child: _buildProfileCard(context, user),
              ),
            ),

            // Stats Section
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'STATISTIQUES',
                  style: KoalaTypography.caption(context).copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: KoalaColors.textSecondary(context),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              sliver: SliverToBoxAdapter(
                child: _buildStatsCards(context, user),
              ),
            ),

            // Edit Form (when editing)
            if (_isEditing)
              SliverPadding(
                padding: EdgeInsets.all(20.w),
                sliver: SliverToBoxAdapter(
                  child: _buildEditForm(context),
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => NavigationHelper.safeBack(),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: KoalaColors.surface(context),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: KoalaShadows.xs,
              ),
              child: Icon(CupertinoIcons.back,
                  size: 20.sp, color: KoalaColors.text(context)),
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          const Spacer(),
          Text('Mon Profil', style: KoalaTypography.heading3(context))
              .animate()
              .fadeIn(),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _isEditing = !_isEditing),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _isEditing
                    ? KoalaColors.primary
                    : KoalaColors.surface(context),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: KoalaShadows.xs,
              ),
              child: Icon(
                _isEditing ? CupertinoIcons.xmark : CupertinoIcons.pencil,
                size: 20.sp,
                color: _isEditing ? Colors.white : KoalaColors.text(context),
              ),
            ),
          ).animate().fadeIn().slideX(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, LocalUser user) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.xl),
        border: Border.all(color: KoalaColors.border(context)),
        boxShadow: KoalaShadows.sm,
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [KoalaColors.primary, KoalaColors.accent],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.fullName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            user.fullName,
            style: KoalaTypography.heading3(context),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(
                context,
                icon: CupertinoIcons.calendar,
                text: 'Paie le ${user.payday}',
              ),
              SizedBox(width: 12.w),
              _buildInfoChip(
                context,
                icon: CupertinoIcons.person,
                text: '${user.age} ans',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildInfoChip(BuildContext context,
      {required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: KoalaColors.primaryUi(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KoalaRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: KoalaColors.primaryUi(context)),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              color: KoalaColors.primaryUi(context),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, LocalUser user) {
    final memberSince = user.firstLaunchDate ?? DateTime.now();
    final daysSinceJoin = DateTime.now().difference(memberSince).inDays;
    final formatter = NumberFormat('#,###', 'fr_FR');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: CupertinoIcons.money_dollar_circle,
                label: 'Salaire',
                value: '${formatter.format(user.salary)} F',
                color: KoalaColors.success,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                context,
                icon: CupertinoIcons.calendar_badge_plus,
                label: 'Membre depuis',
                value: '$daysSinceJoin jours',
                color: KoalaColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildStatCard(
          context,
          icon: CupertinoIcons.chart_pie,
          label: 'Méthode de budgétisation',
          value: _getBudgetingTypeLabel(user.budgetingType),
          color: KoalaColors.accent,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.lg),
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: KoalaTypography.caption(context).copyWith(
                    color: KoalaColors.textSecondary(context),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: KoalaTypography.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }

  String _getBudgetingTypeLabel(String type) {
    switch (type) {
      case '50_30_20':
        return '50/30/20';
      case '80_20':
        return '80/20';
      case 'zero_based':
        return 'Budget base zéro';
      case 'envelope':
        return 'Enveloppes';
      default:
        return type;
    }
  }

  Widget _buildEditForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(KoalaRadius.xl),
          border: Border.all(color: KoalaColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modifier le profil',
                style: KoalaTypography.heading4(context)),
            SizedBox(height: 20.h),
            _buildTextField(
              controller: _fullNameController,
              label: 'Nom complet',
              icon: CupertinoIcons.person_fill,
            ),
            SizedBox(height: 12.h),
            _buildTextField(
              controller: _salaryController,
              label: 'Salaire',
              icon: CupertinoIcons.money_dollar_circle_fill,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12.h),
            _buildTextField(
              controller: _paydayController,
              label: 'Jour de paie (1-31)',
              icon: CupertinoIcons.calendar,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12.h),
            _buildTextField(
              controller: _ageController,
              label: 'Âge',
              icon: CupertinoIcons.person,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: KoalaButton(
                text: _loading ? 'Enregistrement...' : 'Enregistrer',
                onPressed: _loading ? () {} : _saveProfile,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: KoalaTypography.bodyMedium(context),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KoalaRadius.md),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        return null;
      },
    );
  }
}
