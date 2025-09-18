import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/data/services/local_data_service.dart';
import 'package:koala/app/data/services/local_settings_service.dart';

/// Controller for managing app settings and user preferences
class SettingsController extends GetxController {
  // Observable state from local services
  final Rx<dynamic> currentUser = Rx<dynamic>(null);
  final RxString appVersion = '1.0.0'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // ==== GETTERS FOR SETTINGS ====

  bool get biometricEnabled => LocalSettingsService.to.isBiometricEnabled;
  bool get cloudSyncEnabled => LocalSettingsService.to.isCloudSyncEnabled;
  bool get notificationsEnabled => LocalSettingsService.to.isNotificationsEnabled;
  bool get paymentRemindersEnabled => LocalSettingsService.to.isPaymentRemindersEnabled;

  // Observable versions for UI binding
  RxBool get biometricEnabledRx => 
      LocalSettingsService.to.isBiometricEnabled.obs;
  RxBool get cloudSyncEnabledRx => 
      LocalSettingsService.to.isCloudSyncEnabled.obs;
  RxBool get notificationsEnabledRx => 
      LocalSettingsService.to.isNotificationsEnabled.obs;
  RxBool get paymentRemindersEnabledRx => 
      LocalSettingsService.to.isPaymentRemindersEnabled.obs;

  /// Load current user data from local storage
  Future<void> loadUserData() async {
    try {
      currentUser.value = LocalDataService.to.getCurrentUser();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les données utilisateur');
    }
  }

  // ==== NAVIGATION METHODS ====

  /// Edit user profile - navigates to profile edit page
  void editProfile() {
    Get.toNamed('/profile/edit');
  }

  /// Edit financial information - navigates to financial info page
  void editFinancialInfo() {
    Get.toNamed('/profile/financial');
  }

  /// Change PIN code - navigates to PIN change page
  void changePIN() {
    Get.toNamed('/security/change-pin');
  }

  /// Open help center - navigates to help center page
  void openHelpCenter() {
    Get.toNamed('/help');
  }

  /// Send feedback - navigates to feedback page
  void sendFeedback() {
    Get.toNamed('/feedback');
  }

  /// Show about page - navigates to about page
  void showAbout() {
    Get.toNamed('/about');
  }

  /// Manage local backups - navigates to backup management page
  void manageBackups() {
    Get.toNamed('/settings/backups');
  }

  /// Navigate to import/export
  void navigateToImportExport() {
    Get.toNamed('/import-export');
  }

  // ==== SETTINGS TOGGLE METHODS ====

  /// Toggle biometric authentication
  Future<void> toggleBiometric(bool value) async {
    try {
      await LocalSettingsService.to.setBiometricEnabled(value);
      // Refresh UI
      update();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier l\'authentification biométrique');
    }
  }

  /// Toggle cloud synchronization
  Future<void> toggleCloudSync(bool value) async {
    try {
      await LocalSettingsService.to.setCloudSyncEnabled(value);
      
      if (value) {
        // Show sync confirmation
        Get.snackbar(
          'Synchronisation activée',
          'Vos données seront sauvegardées dans le cloud',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Synchronisation désactivée',
          'Vos données restent uniquement locales',
          backgroundColor: const Color(0xFFFF9800),
          colorText: Colors.white,
        );
      }
      
      // Refresh UI
      update();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier la synchronisation');
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool value) async {
    try {
      await LocalSettingsService.to.setNotificationsEnabled(value);
      update();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier les notifications');
    }
  }

  /// Toggle payment reminders
  Future<void> togglePaymentReminders(bool value) async {
    try {
      await LocalSettingsService.to.setPaymentRemindersEnabled(value);
      update();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier les rappels de paiement');
    }
  }

  // ==== LOGOUT ====

  /// Logout user and clear all data
  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ? Toutes vos données locales seront supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Clear all local data
        await LocalDataService.to.clearAllData();
        await LocalSettingsService.to.clearAllSettings();
        
        // Navigate to onboarding
        Get.offAllNamed('/onboarding');
        
        Get.snackbar(
          'Déconnecté',
          'Vous avez été déconnecté avec succès',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar('Erreur', 'Erreur lors de la déconnexion: $e');
      }
    }
  }
}

/// Mock user model for demonstration (to be replaced with real UserModel)
class MockUser {
  final String name;
  final String phone;
  final String email;

  MockUser({required this.name, required this.phone, required this.email});
}
