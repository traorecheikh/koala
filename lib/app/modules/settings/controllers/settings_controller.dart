import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/data/services/local_data_service.dart';
import 'package:koala/app/data/services/local_settings_service.dart';
import 'package:koala/app/shared/widgets/about_bottom_sheet.dart';
import 'package:koala/app/shared/widgets/change_pin_bottom_sheet.dart';
import 'package:koala/app/shared/widgets/financial_info_bottom_sheet.dart';
import 'package:koala/app/shared/widgets/help_center_bottom_sheet.dart';
import 'package:koala/app/shared/widgets/local_backup_bottom_sheet.dart';
import 'package:koala/app/shared/widgets/personal_info_bottom_sheet.dart';

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
  RxBool get biometricEnabledRx => LocalSettingsService.to.settings.map((s) => s.biometricEnabled).obs;
  RxBool get cloudSyncEnabledRx => LocalSettingsService.to.settings.map((s) => s.cloudSyncEnabled).obs;
  RxBool get notificationsEnabledRx => LocalSettingsService.to.settings.map((s) => s.notificationsEnabled).obs;
  RxBool get paymentRemindersEnabledRx => LocalSettingsService.to.settings.map((s) => s.paymentRemindersEnabled).obs;

  /// Load current user data from local storage
  Future<void> loadUserData() async {
    try {
      currentUser.value = LocalDataService.to.getCurrentUser();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les données utilisateur');
    }
  }

  // ==== NAVIGATION METHODS ====

  /// Edit user profile - opens personal info bottom sheet
  void editProfile() {
    PersonalInfoBottomSheet.show();
  }

  /// Edit financial information - opens financial info bottom sheet
  void editFinancialInfo() {
    FinancialInfoBottomSheet.show();
  }

  /// Change PIN code - opens PIN change bottom sheet
  void changePIN() {
    ChangePinBottomSheet.show();
  }

  /// Open help center - opens help center bottom sheet
  void openHelpCenter() {
    HelpCenterBottomSheet.show();
  }

  /// Send feedback - opens feedback bottom sheet via help center
  void sendFeedback() {
    HelpCenterBottomSheet.show();
  }

  /// Show about dialog - opens about bottom sheet
  void showAbout() {
    AboutBottomSheet.show();
  }

  /// Manage local backups - opens backup management bottom sheet
  void manageBackups() {
    LocalBackupBottomSheet.show();
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
