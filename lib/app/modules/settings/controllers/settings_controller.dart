import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller for managing app settings and user preferences
class SettingsController extends GetxController {
  // Observable state
  final RxBool biometricEnabled = false.obs;
  final RxBool cloudSyncEnabled = false.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool paymentRemindersEnabled = true.obs;
  final RxString appVersion = '1.0.0'.obs;
  final Rx<dynamic> currentUser = Rx<dynamic>(null);

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadUserData();
  }

  /// Load user settings from storage
  Future<void> loadSettings() async {
    try {
      // TODO: Load settings from secure storage
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock settings for now
      biometricEnabled.value = false;
      cloudSyncEnabled.value = true;
      notificationsEnabled.value = true;
      paymentRemindersEnabled.value = true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les paramètres');
    }
  }

  /// Load current user data
  Future<void> loadUserData() async {
    try {
      // TODO: Load user from storage
      await Future.delayed(const Duration(milliseconds: 200));

      // Mock user for now
      currentUser.value = MockUser(
        name: 'Utilisateur Koala',
        phone: '+221 77 123 45 67',
        email: 'user@koala.com',
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les données utilisateur');
    }
  }

  /// Edit user profile
  void editProfile() {
    Get.toNamed('/profile/edit');
  }

  /// Edit financial information
  void editFinancialInfo() {
    Get.toNamed('/profile/financial');
  }

  /// Change PIN code
  void changePIN() {
    Get.toNamed('/security/change-pin');
  }

  /// Toggle biometric authentication
  void toggleBiometric(bool value) {
    biometricEnabled.value = value;
    _saveSettings();
  }

  /// Toggle cloud synchronization
  void toggleCloudSync(bool value) {
    cloudSyncEnabled.value = value;
    _saveSettings();
  }

  /// Toggle notifications
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    _saveSettings();
  }

  /// Toggle payment reminders
  void togglePaymentReminders(bool value) {
    paymentRemindersEnabled.value = value;
    _saveSettings();
  }

  /// Manage local backups
  void manageBackups() {
    Get.toNamed('/settings/backups');
  }

  /// Navigate to import/export
  void navigateToImportExport() {
    Get.toNamed('/import-export');
  }

  /// Open help center
  void openHelpCenter() {
    Get.toNamed('/help');
  }

  /// Send feedback
  void sendFeedback() {
    Get.toNamed('/feedback');
  }

  /// Show about dialog
  void showAbout() {
    Get.dialog(
      AlertDialog(
        title: const Text('À propos'),
        content: const Text('Koala - Assistant Financier\nVersion 1.0.0'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Fermer')),
        ],
      ),
    );
  }

  /// Logout user
  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Get.back();
              _performLogout();
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    try {
      // TODO: Save settings to secure storage
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de sauvegarder les paramètres');
    }
  }

  /// Perform logout operations
  Future<void> _performLogout() async {
    try {
      // TODO: Clear user session and navigate to login
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/onboarding');
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la déconnexion');
    }
  }
}

/// Mock user model for demonstration
class MockUser {
  final String name;
  final String phone;
  final String email;

  MockUser({required this.name, required this.phone, required this.email});
}
