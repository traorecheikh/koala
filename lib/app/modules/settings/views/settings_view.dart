// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/modules/settings/views/subscriptions_view.dart';
import 'package:koaa/app/modules/settings/views/recurring_transactions_view.dart';
import 'package:koaa/app/modules/settings/views/profile_view.dart';
import 'package:koaa/app/modules/settings/views/privacy_policy_view.dart';
import 'package:koaa/app/modules/settings/views/terms_view.dart';
import 'package:koaa/app/modules/settings/views/data_management_view.dart';
import 'package:koaa/app/services/notification_service.dart';
import 'package:koaa/app/services/changelog_service.dart';
import 'package:koaa/app/core/utils/color_utils.dart';

import 'package:koaa/app/routes/app_pages.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

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
          'Paramètres',
          style: KoalaTypography.heading3(context),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSection(
            context,
            title: 'Apparence',
            children: [
              Obx(() => _buildSettingsItem(
                    context,
                    icon: CupertinoIcons.paintbrush_fill,
                    title: 'Personnalisation & Thème',
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: controller.currentSkin.value.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: KoalaColors.border(context), width: 2),
                      ),
                    ),
                    onTap: () => Get.toNamed(Routes.cardPersonalization),
                  )),
              Obx(() {
                final isHeroMode =
                    controller.currentCardStyle.value == BalanceCardStyle.hero;
                return _buildSettingsItem(
                  context,
                  icon: isHeroMode
                      ? CupertinoIcons.lock_fill
                      : CupertinoIcons.moon_fill,
                  title: isHeroMode ? 'Mode sombre (Imposé)' : 'Mode sombre',
                  iconColor:
                      isHeroMode ? KoalaColors.textSecondary(context) : null,
                  textColor:
                      isHeroMode ? KoalaColors.textSecondary(context) : null,
                  trailing: CupertinoSwitch(
                    value: controller.isDarkMode.value,
                    activeTrackColor: isHeroMode
                        ? KoalaColors.textSecondary(context)
                            .withValues(alpha: 0.3)
                        : KoalaColors.primaryUi(context),
                    // Disable interaction in Hero Mode
                    onChanged: isHeroMode
                        ? (v) => Get.snackbar('Thème Héros Actif',
                            'Ce thème impose un mode d\'affichage spécifique pour une meilleure expérience.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: KoalaColors.surface(context),
                            colorText: KoalaColors.text(context))
                        : controller.toggleTheme,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.checkForUpdates,
              borderRadius: BorderRadius.circular(KoalaRadius.md),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.cloud_download,
                      color: ColorUtils.ensureContrast(
                          KoalaColors.primaryUi(context),
                          KoalaColors.background(context)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Vérifier les mises à jour',
                      style: KoalaTypography.bodyMedium(context).copyWith(
                          color: ColorUtils.ensureContrast(
                              KoalaColors.primaryUi(context),
                              KoalaColors.background(context))),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            title: 'Données Financières',
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.arrow_2_circlepath,
                title: 'Revenus récurrents',
                iconColor: KoalaColors.success,
                onTap: () => Get.to(() => const RecurringTransactionsView()),
              ),
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.creditcard_fill,
                title: 'Abonnements',
                iconColor: const Color(0xFFFF6B6B),
                onTap: () => Get.to(() => const SubscriptionsView()),
              ),
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.doc_on_clipboard_fill,
                title: 'Gestion des données',
                iconColor: Colors.blueGrey,
                onTap: () => Get.to(() => const DataManagementView()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            title: 'Personnalisation',
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.sparkles,
                title: 'Mon Profil Financier',
                iconColor: KoalaColors.accent,
                onTap: () => Get.toNamed(Routes.persona),
              ),
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.flame_fill,
                title: 'Mes Accomplissements',
                iconColor: const Color(0xFFFF9500),
                onTap: () => Get.toNamed(Routes.challenges),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            title: 'Compte & Sécurité',
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.person_alt_circle_fill,
                title: 'Profil',
                onTap: () => Get.to(() => const ProfileView()),
              ),
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.lock_fill,
                title: 'Sécurité (PIN & Biométrie)',
                onTap: () => NavigationHelper.toNamed(Routes.securitySettings),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            title: 'Notifications',
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.bell_fill,
                title: 'Tester les notifications',
                onTap: () async {
                  await NotificationService.requestPermissions();
                  await NotificationService.showNotification(
                    id: 12345,
                    title: 'Test de Notification',
                    body:
                        'Ceci est un test pour vérifier que les notifications fonctionnent.',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            title: 'Confidentialité',
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.hand_raised_fill,
                title: 'Politique de confidentialité',
                onTap: () => Get.to(() => const PrivacyPolicyView()),
              ),
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.doc_text_fill,
                title: 'Conditions d\'utilisation',
                onTap: () => Get.to(() => const TermsView()),
              ),
            ],
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => ChangelogService.showWhatsNewDialog(context),
            child: Column(
              children: [
                Text(
                  ChangelogService.versionString,
                  style: KoalaTypography.bodyMedium(context).copyWith(
                    color: KoalaColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Voir les nouveautés',
                  style: KoalaTypography.caption(context).copyWith(
                    color: KoalaColors.primaryUi(context),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ]
            .animate(interval: KoalaAnim.stagger)
            .fadeIn(duration: KoalaAnim.medium)
            .slideY(begin: 0.1, curve: KoalaAnim.entryCurve),
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            title,
            style: KoalaTypography.bodySmall(context).copyWith(
              fontWeight: FontWeight.bold,
              color: ColorUtils.ensureContrast(KoalaColors.primaryUi(context),
                  KoalaColors.background(context)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: KoalaColors.surface(context),
            borderRadius: BorderRadius.circular(KoalaRadius.lg),
            border: Border.all(color: KoalaColors.border(context)),
            boxShadow: KoalaShadows.sm,
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
                      indent: 16,
                      endIndent: 16,
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
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? KoalaColors.text(context),
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: KoalaTypography.bodyMedium(context).copyWith(
                    color: textColor ?? KoalaColors.text(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null) trailing,
              if (onTap != null && trailing == null)
                Icon(
                  CupertinoIcons.chevron_right,
                  color:
                      KoalaColors.textSecondary(context).withValues(alpha: 0.5),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
