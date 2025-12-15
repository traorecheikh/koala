// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/modules/settings/controllers/security_settings_controller.dart';

class SecuritySettingsView extends GetView<SecuritySettingsController> {
  const SecuritySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: KoalaColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: KoalaColors.text(context),
          ),
          onPressed: () => NavigationHelper.safeBack(),
        ),
        title: Text(
          'Sécurité',
          style: KoalaTypography.heading3(context),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSettingsSection(
            context,
            title: 'Verrouillage',
            children: [
              Obx(
                () => _buildSettingsItem(
                  context,
                  icon: CupertinoIcons.lock_shield_fill,
                  title: 'Verrouiller l\'application',
                  subtitle: 'Nécessite une authentification au lancement',
                  trailing: CupertinoSwitch(
                    value: controller.isAuthEnabled.value,
                    activeColor: KoalaColors.primaryUi(context),
                    onChanged: controller.toggleAuth,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Text(
            title,
            style: KoalaTypography.bodySmall(context).copyWith(
              fontWeight: FontWeight.bold,
              color: KoalaColors.primaryUi(context),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: KoalaColors.surface(context),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: KoalaColors.border(context)),
            boxShadow: KoalaColors.shadowSubtle,
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index != children.length - 1)
                    Divider(
                      height: 1,
                      indent: 16.w,
                      endIndent: 16.w,
                      color: KoalaColors.border(context),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(icon, color: KoalaColors.text(context), size: 20.sp),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: KoalaTypography.bodyMedium(context)
                            .copyWith(fontWeight: FontWeight.w500)),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: KoalaTypography.caption(context).copyWith(
                          color: KoalaColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (onTap != null && trailing == null)
                Icon(
                  CupertinoIcons.chevron_right,
                  color: KoalaColors.textSecondary(context).withOpacity(0.5),
                  size: 16.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
