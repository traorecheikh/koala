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
import 'package:package_info_plus/package_info_plus.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _homeController = Get.find<HomeController>();
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v${packageInfo.version}';
      });
    }
  }

  void _showEditProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _EditProfileSheet(user: _homeController.user.value!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      body: SafeArea(
        child: Obx(() {
          final user = _homeController.user.value;
          if (user == null) return const SizedBox.shrink();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                sliver: SliverToBoxAdapter(
                  child: _buildHeader(context, user),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 24.h)),

              // Identity Section
              _buildSectionTitle(context, 'IDENTITÉ'),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverToBoxAdapter(
                  child: _buildIdentitySection(context, user),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 24.h)),

              // Financial Section
              _buildSectionTitle(context, 'PARAMÈTRES FINANCIERS'),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverToBoxAdapter(
                  child: _buildFinancialSection(context, user),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 24.h)),

              // Account Section
              _buildSectionTitle(context, 'INFORMATIONS DU COMPTE'),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverToBoxAdapter(
                  child: _buildAccountSection(context, user),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LocalUser user) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => NavigationHelper.safeBack(),
          child: Icon(CupertinoIcons.back,
              size: 24.sp, color: KoalaColors.text(context)),
        ),
        SizedBox(width: 16.w),
        // Avatar
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: KoalaColors.surface(context),
            shape: BoxShape.circle,
            border: Border.all(color: KoalaColors.primaryUi(context), width: 2),
            boxShadow: KoalaShadows.sm,
          ),
          child: Center(
            child: Text(
              user.fullName.isNotEmpty
                  ? user.fullName.substring(0, 1).toUpperCase()
                  : '?',
              style: TextStyle(
                color: KoalaColors.primaryUi(context),
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: KoalaTypography.heading4(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Profil Utilisateur',
                style: KoalaTypography.caption(context).copyWith(
                  color: KoalaColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _showEditProfileSheet(context),
          icon: Icon(
            CupertinoIcons.pencil_circle_fill,
            size: 32.sp,
            color: KoalaColors.primaryUi(context),
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.05);
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return SliverPadding(
      padding: EdgeInsets.only(left: 20.w, top: 0, bottom: 8.h),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: KoalaTypography.caption(context).copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: KoalaColors.textSecondary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentitySection(BuildContext context, LocalUser user) {
    return _ProfileSectionCard(
      children: [
        _ProfileRow(
          icon: CupertinoIcons.person_fill,
          label: 'Nom Complet',
          value: user.fullName,
          isFirst: true,
        ),
        _ProfileRow(
          icon: CupertinoIcons.number_circle,
          label: 'Âge',
          value: '${user.age} ans',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildFinancialSection(BuildContext context, LocalUser user) {
    final numberFormat = NumberFormat('#,###', 'fr_FR');

    return _ProfileSectionCard(
      children: [
        _ProfileRow(
          icon: CupertinoIcons.money_dollar_circle_fill,
          label: 'Salaire Mensuel',
          value: '${numberFormat.format(user.salary)} F',
          isFirst: true,
        ),
        _ProfileRow(
          icon: CupertinoIcons.calendar_today,
          label: 'Jour de Paie',
          value: 'Le ${user.payday} du mois',
        ),
        _ProfileRow(
          icon: CupertinoIcons.chart_pie_fill,
          label: 'Budget',
          value: _getBudgetingTypeLabel(user.budgetingType),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context, LocalUser user) {
    final memberSince = user.firstLaunchDate ?? DateTime.now();
    final dateStr = DateFormat('dd MMM yyyy', 'fr_FR').format(memberSince);
    final days = DateTime.now().difference(memberSince).inDays;

    // Attempt to get a stable ID. HiveObject key can be dynamic, but usually int (index) or custom key.
    // If key is null (not saved), default to '-'.
    final accountId = user.key != null ? 'User#${user.key}' : 'Non synchronisé';

    return _ProfileSectionCard(
      children: [
        _ProfileRow(
          icon: CupertinoIcons.time_solid,
          label: 'Membre Depuis',
          value: '$dateStr ($days jours)',
          isFirst: true,
        ),
        _ProfileRow(
          icon: CupertinoIcons.barcode,
          label: 'ID Compte',
          value: accountId,
          enableCopy: true,
        ),
        _ProfileRow(
          icon: CupertinoIcons.info_circle_fill,
          label: 'Version App',
          value: _appVersion,
          isLast: true,
        ),
      ],
    );
  }

  String _getBudgetingTypeLabel(String type) {
    switch (type) {
      case '50_30_20':
        return '50/30/20';
      case '80_20':
        return '80/20';
      case 'zero_based':
        return 'Base Zéro';
      case 'envelope':
        return 'Enveloppes';
      default:
        return type;
    }
  }
}

class _ProfileSectionCard extends StatelessWidget {
  final List<Widget> children;

  const _ProfileSectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.lg),
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Column(
        children: children,
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;
  final bool enableCopy;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
    this.enableCopy = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = KoalaColors.primaryUi(context);

    return Column(
      children: [
        if (!isFirst)
          Divider(
            height: 1,
            indent: 52.w, // Inspect visual alignment
            color: KoalaColors.border(context),
          ),
        InkWell(
          onTap: enableCopy
              ? () {
                  Clipboard.setData(ClipboardData(text: value));
                  HapticFeedback.mediumImpact();
                  Get.snackbar('Copié', 'Copié dans le presse-papier');
                }
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(icon, size: 22.sp, color: color),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    label,
                    style: KoalaTypography.bodyMedium(context),
                  ),
                ),
                Text(
                  value,
                  style: KoalaTypography.bodyMedium(context).copyWith(
                    color: KoalaColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (enableCopy) ...[
                  SizedBox(width: 8.w),
                  Icon(CupertinoIcons.doc_on_doc,
                      size: 14.sp,
                      color: KoalaColors.textSecondary(context)
                          .withValues(alpha: 0.5)),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Edit Bottom Sheet ---

class _EditProfileSheet extends StatefulWidget {
  final LocalUser user;
  const _EditProfileSheet({required this.user});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _homeController = Get.find<HomeController>();
  late TextEditingController _nameCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _paydayCtrl;
  late TextEditingController _ageCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.fullName);
    _salaryCtrl =
        TextEditingController(text: widget.user.salary.toStringAsFixed(0));
    _paydayCtrl = TextEditingController(text: widget.user.payday.toString());
    _ageCtrl = TextEditingController(text: widget.user.age.toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _salaryCtrl.dispose();
    _paydayCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact(); // Error
      return;
    }

    setState(() => _loading = true);
    HapticFeedback.lightImpact();

    // Simulate minimal delay
    await Future.delayed(const Duration(milliseconds: 600));

    final updatedUser = LocalUser(
      fullName: _nameCtrl.text.trim(),
      salary: double.tryParse(_salaryCtrl.text.trim()) ?? widget.user.salary,
      payday: int.tryParse(_paydayCtrl.text.trim()) ?? widget.user.payday,
      age: int.tryParse(_ageCtrl.text.trim()) ?? widget.user.age,
      budgetingType: widget.user.budgetingType,
      firstLaunchDate: widget.user.firstLaunchDate,
      hasCompletedCatchUp: widget.user.hasCompletedCatchUp,
    );

    // Save to Hive
    final userBox = Hive.box<LocalUser>('userBox');
    // Using key from original user if available, else 'currentUser' if we used a string key before
    // The previous code used 'currentUser' string key.
    await userBox.put('currentUser', updatedUser);

    // update controller
    _homeController.user.value = updatedUser;

    setState(() => _loading = false);
    HapticFeedback.mediumImpact();
    if (mounted) Navigator.pop(context);

    Get.snackbar(
      'Profil mis à jour',
      'Vos modifications ont été enregistrées.',
      backgroundColor: KoalaColors.success,
      colorText: Colors.white,
      margin: EdgeInsets.all(16.w),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KoalaRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
          20.w, 20.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 40.h),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color:
                      KoalaColors.textSecondary(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text('Modifier le Profil',
                style: KoalaTypography.heading3(context)),
            SizedBox(height: 24.h),
            _buildField('Nom', _nameCtrl, CupertinoIcons.person),
            SizedBox(height: 16.h),
            _buildField('Salaire', _salaryCtrl, CupertinoIcons.money_dollar,
                type: TextInputType.number),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                    child: _buildField(
                        'Jour de paie', _paydayCtrl, CupertinoIcons.calendar,
                        type: TextInputType.number)),
                SizedBox(width: 16.w),
                Expanded(
                    child: _buildField('Âge', _ageCtrl, CupertinoIcons.number,
                        type: TextInputType.number)),
              ],
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: KoalaButton(
                text: _loading ? 'Enregistrement...' : 'Enregistrer',
                onPressed: _loading ? () {} : _save,
                backgroundColor: KoalaColors.primaryUi(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: KoalaTypography.bodyMedium(context),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: KoalaColors.textSecondary(context)),
        filled: true,
        fillColor: KoalaColors.background(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KoalaRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
    );
  }
}
