// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/modules/settings/views/recurring_transactions_view.dart';
import 'package:koaa/app/modules/settings/widgets/edit_profile_dialog.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: theme.textTheme.bodyLarge?.color,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Paramètres', // Translated from 'Settings'
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSection(
            context,
            title: 'Apparence', // Translated from 'Appearance'
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.moon_fill,
                title: 'Mode sombre', // Translated from 'Dark Mode'
                trailing: Obx(
                  () => CupertinoSwitch(
                    value: controller.isDarkMode.value,
                    onChanged: controller.toggleTheme,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(
              CupertinoIcons.cloud_download,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              'Vérifier les mises à jour',
              style: theme.textTheme.bodyLarge,
            ),
            onTap: controller.checkForUpdates,
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            title: 'Intelligence Artificielle', // New section
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.sparkles,
                title: 'Mon Profil Financier',
                onTap: () => Get.toNamed('/persona'), // Use named route
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            title: 'Compte', // Translated from 'Account'
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.person_alt_circle_fill,
                title: 'Profil', // Translated from 'Profile'
                onTap: () => showEditProfileDialog(context),
              ),
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.lock_fill,
                title: 'Sécurité', // Translated from 'Security'
                onTap: () {},
              ),
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.repeat,
                title:
                    'Transactions récurrentes', // Translated from 'Recurring Transactions'
                onTap: () => Get.to(() => const RecurringTransactionsView()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            title: 'Notifications', // Translated from 'Notifications'
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.bell_fill,
                title:
                    'Paramètres de notification', // Translated from 'Notification Settings'
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            title: 'Confidentialité', // Translated from 'Privacy'
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.hand_raised_fill,
                title:
                    'Politique de confidentialité', // Translated from 'Privacy Policy'
                onTap: () {},
              ),
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.doc_text_fill,
                title:
                    'Conditions d\'utilisation', // Translated from 'Terms of Service'
                onTap: () {},
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children.map((item) {
              return Column(
                children: [
                  item,
                  if (item != children.last)
                    Divider(
                      height: 0,
                      indent: 16,
                      endIndent: 16,
                      color: theme.dividerColor.withOpacity(0.1),
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
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurface, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(
                CupertinoIcons.forward,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
