import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/core/theme/app_colors.dart';
import 'package:koala/app/core/theme/app_dimensions.dart';
import 'package:koala/app/core/theme/app_text_styles.dart';
import 'package:koala/app/modules/settings/controllers/settings_controller.dart';

/// High-fidelity settings view with user profile and app configuration
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [_buildProfileSection(), _buildSettingsGroups()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Custom app bar with navigation
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Retour',
          ),
          Expanded(child: Text('Paramètres', style: AppTextStyles.h2)),
        ],
      ),
    );
  }

  /// User profile section at the top
  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(Icons.person, size: 32, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.currentUser.value?.name ?? 'Utilisateur',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.currentUser.value?.phone ?? '',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Compte vérifié',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Edit button
            IconButton(
              onPressed: controller.editProfile,
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              tooltip: 'Modifier le profil',
            ),
          ],
        ),
      ),
    );
  }

  /// Settings groups organized by category
  Widget _buildSettingsGroups() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          _buildSettingsGroup(
            title: 'Profil',
            items: [
              _buildSettingsItem(
                icon: Icons.person_outline,
                title: 'Informations personnelles',
                subtitle: 'Nom, téléphone, salaire',
                onTap: controller.editProfile,
              ),
              _buildSettingsItem(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Informations financières',
                subtitle: 'Salaire, date de paie, comptes',
                onTap: controller.editFinancialInfo,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsGroup(
            title: 'Sécurité',
            items: [
              _buildSettingsItem(
                icon: Icons.lock_outline,
                title: 'Modifier le code PIN',
                subtitle: 'Changer votre code de sécurité',
                onTap: controller.changePIN,
              ),
              _buildToggleSettingsItem(
                icon: Icons.fingerprint,
                title: 'Authentification biométrique',
                subtitle: 'Empreinte digitale ou Face ID',
                valueGetter: () => controller.biometricEnabled,
                onChanged: controller.toggleBiometric,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsGroup(
            title: 'Données',
            items: [
              _buildToggleSettingsItem(
                icon: Icons.cloud_outlined,
                title: 'Synchronisation serveur',
                subtitle: 'Sauvegarder dans le cloud',
                valueGetter: () => controller.cloudSyncEnabled,
                onChanged: controller.toggleCloudSync,
              ),
              _buildSettingsItem(
                icon: Icons.backup_outlined,
                title: 'Sauvegardes locales',
                subtitle: 'Gérer les sauvegardes hors ligne',
                onTap: controller.manageBackups,
              ),
              _buildSettingsItem(
                icon: Icons.import_export,
                title: 'Import / Export',
                subtitle: 'Importer ou exporter vos données',
                onTap: controller.navigateToImportExport,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsGroup(
            title: 'Notifications',
            items: [
              _buildToggleSettingsItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications push',
                subtitle: 'Alertes et rappels',
                valueGetter: () => controller.notificationsEnabled,
                onChanged: controller.toggleNotifications,
              ),
              _buildToggleSettingsItem(
                icon: Icons.schedule,
                title: 'Rappels d\'échéances',
                subtitle: 'Prêts et récurrences',
                valueGetter: () => controller.paymentRemindersEnabled,
                onChanged: controller.togglePaymentReminders,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsGroup(
            title: 'Support',
            items: [
              _buildSettingsItem(
                icon: Icons.help_outline,
                title: 'Centre d\'aide',
                subtitle: 'FAQ et tutoriels',
                onTap: controller.openHelpCenter,
              ),
              _buildSettingsItem(
                icon: Icons.feedback_outlined,
                title: 'Envoyer un commentaire',
                subtitle: 'Aidez-nous à améliorer l\'app',
                onTap: controller.sendFeedback,
              ),
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'À propos',
                subtitle: 'Version ${controller.appVersion.value}',
                onTap: controller.showAbout,
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Logout button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 32),
            child: ElevatedButton.icon(
              onPressed: controller.logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                elevation: AppElevation.level1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Settings group with title and items
  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Regular settings item with tap action
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }

  /// Settings item with toggle switch
  Widget _buildToggleSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool Function() valueGetter,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: GetBuilder<SettingsController>(
        builder: (controller) => Switch(
          value: valueGetter(),
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }
}
