import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/data/models/user_model.dart';
import 'package:koala/app/data/services/local_data_service.dart';
import 'package:koala/app/data/services/local_settings_service.dart';

class OnboardingController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final salaryController = TextEditingController();
  final balanceController = TextEditingController();
  final initialBalanceController = TextEditingController();
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();

  // Page controller for managing steps
  final pageController = PageController();

  // Observable state
  final selectedPayDay = 1.obs;
  final selectedPayday = Rxn<int>();
  final biometricEnabled = false.obs;
  final isLoading = false.obs;
  final currentStep = 0.obs;
  final personalInfoError = ''.obs;

  // Constants
  final int totalSteps = 3;
  final int maxSteps = 3;

  @override
  void onInit() {
    super.onInit();
    // Initialize balance controller to point to the same controller
    initialBalanceController.text = balanceController.text;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    salaryController.dispose();
    balanceController.dispose();
    initialBalanceController.dispose();
    pinController.dispose();
    confirmPinController.dispose();
    pageController.dispose();
    super.onClose();
  }

  /// Move to next step
  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      if (_validateCurrentStep()) {
        currentStep.value++;
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      completeOnboarding();
    }
  }

  /// Move to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Set payday
  void setPayday(int? day) {
    if (day != null) {
      selectedPayday.value = day;
      selectedPayDay.value = day;
    }
  }

  /// Toggle biometric authentication
  void toggleBiometric(bool value) {
    biometricEnabled.value = value;
  }

  /// Validate current step
  bool _validateCurrentStep() {
    personalInfoError.value = '';

    switch (currentStep.value) {
      case 0: // Personal info step
        if (nameController.text.trim().isEmpty) {
          personalInfoError.value = 'Le nom est requis';
          return false;
        }
        if (phoneController.text.trim().isEmpty) {
          personalInfoError.value = 'Le numéro de téléphone est requis';
          return false;
        }
        return true;

      case 1: // Financial info step
        if (salaryController.text.trim().isEmpty) {
          personalInfoError.value = 'Le salaire est requis';
          return false;
        }
        if (initialBalanceController.text.trim().isEmpty) {
          personalInfoError.value = 'Le solde initial est requis';
          return false;
        }
        if (selectedPayday.value == null) {
          personalInfoError.value = 'La date de paie est requise';
          return false;
        }
        return true;

      case 2: // Security step
        if (pinController.text.trim().length < 4) {
          personalInfoError.value = 'Le PIN doit contenir au moins 4 chiffres';
          return false;
        }
        if (pinController.text != confirmPinController.text) {
          personalInfoError.value = 'Les codes PIN ne correspondent pas';
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  /// Complete onboarding process
  Future<void> completeOnboarding() async {
    if (!_validateCurrentStep()) return;

    try {
      isLoading.value = true;

      // Create user model using actual UserModel
      final user = UserModel(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        monthlySalary: double.tryParse(salaryController.text) ?? 0.0,
        currentBalance: double.tryParse(initialBalanceController.text) ?? 0.0,
        payDay: selectedPayday.value ?? 1,
        biometricEnabled: biometricEnabled.value,
      );

      // Save user to local storage
      await LocalDataService.to.saveUser(user);
      
      // Save PIN securely
      await LocalSettingsService.to.savePIN(pinController.text);
      
      // Set biometric setting
      await LocalSettingsService.to.setBiometricEnabled(biometricEnabled.value);
      
      // Mark first run as complete
      await LocalSettingsService.to.completeFirstRun();

      // Navigate to main app
      Get.offAllNamed('/main');
      Get.snackbar(
        'Bienvenue dans Koala!', 
        'Votre compte a été créé avec succès',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur', 
        'Impossible de créer le compte: $e',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
