import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/modules/settings/controllers/settings_controller.dart';
import 'package:koala/app/shared/controllers/theme_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildProfileSection(context),
          _buildAccountsSection(context),
          _buildAppSettingsSection(context, themeController),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16.0),
            const ListTile(
              leading: CircleAvatar(child: Text('U')),
              title: Text('User'),
              subtitle: Text('+221 77 123 4567'),
              trailing: Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accounts', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16.0),
            Obx(() {
              if (controller.accounts.isEmpty) {
                return const Center(child: Text('No accounts found.'));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.accounts.length,
                itemBuilder: (context, index) {
                  final account = controller.accounts[index];
                  return ListTile(
                    leading: Icon(account['icon'] as IconData),
                    title: Text(account['name'] as String),
                    subtitle: Text(account['provider'] as String),
                    trailing: Text('${account['balance']} XOF'),
                  );
                },
              );
            }),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: controller.addAccount,
                icon: const Icon(Icons.add),
                label: const Text('Add Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection(BuildContext context, ThemeController themeController) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Settings', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16.0),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              trailing: Obx(
                () => DropdownButton<ThemeMode>(
                  value: themeController.themeMode,
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      themeController.setThemeMode(value);
                    }
                  },
                ),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const ListTile(
              leading: Icon(Icons.security),
              title: Text('Security'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About & Support', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16.0),
            const ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('About Koala'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: controller.logout,
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
