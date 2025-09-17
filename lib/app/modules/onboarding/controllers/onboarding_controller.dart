import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/routes/app_routes.dart';
import 'package:koala/app/shared/services/hive_service.dart';
import 'package:koala/app/shared/theme/colors.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  var currentPage = 0.obs;

  // Text controllers for all form fields
  final TextEditingController nameInputController = TextEditingController();
  final TextEditingController phoneInputController = TextEditingController();
  final TextEditingController salaryInputController = TextEditingController();
  final TextEditingController balanceInputController = TextEditingController();
  final TextEditingController pinInputController = TextEditingController();

  // Observable data
  var name = ''.obs;
  var phone = ''.obs;
  var salary = ''.obs;
  var balance = ''.obs;
  var pin = ''.obs;
  var biometricEnabled = false.obs;

  final HiveService _hiveService = Get.find<HiveService>();

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(() {
      currentPage.value = pageController.page?.round() ?? 0;
    });
    
    // Add listeners for all controllers
    nameInputController.addListener(() {
      name.value = nameInputController.text;
    });
    phoneInputController.addListener(() {
      phone.value = phoneInputController.text;
    });
    salaryInputController.addListener(() {
      salary.value = salaryInputController.text;
    });
    balanceInputController.addListener(() {
      balance.value = balanceInputController.text;
    });
    pinInputController.addListener(() {
      pin.value = pinInputController.text;
    });
  }

  void nextPage() {
    // Validate current step before proceeding
    if (!_validateCurrentStep()) {
      return;
    }

    if (currentPage.value < 6) {
      // Now we have 7 steps (0-6)
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Onboarding finished, save data and navigate to home
      _saveOnboardingData();
      _hiveService.setOnboardingComplete(true);
      Get.offAllNamed(Routes.home);
    }
  }

  void skipToEnd() {
    pageController.animateToPage(
      6, // Go to completion step (7th step, index 6)
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (currentPage.value) {
      case 0: // Welcome step
      case 1: // Koala bot intro step
        return true;
      case 2: // Personal info step
        if (name.value.isEmpty || name.value.trim().length < 2) {
          Get.snackbar(
            'Nom requis',
            'Veuillez saisir votre nom complet',
            backgroundColor: AppColors.warning.withAlpha((0.8 * 255).toInt()),
            colorText: AppColors.textInverse,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
        if (phone.value.isEmpty || phone.value.length < 8) {
          Get.snackbar(
            'Téléphone requis',
            'Veuillez saisir un numéro de téléphone valide',
            backgroundColor: AppColors.warning.withAlpha((0.8 * 255).toInt()),
            colorText: AppColors.textInverse,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
        return true;
      case 3: // Salary step
        if (salary.value.isEmpty || double.tryParse(salary.value) == null) {
          Get.snackbar(
            'Salaire requis',
            'Veuillez saisir votre salaire mensuel',
            backgroundColor: AppColors.warning.withAlpha((0.8 * 255).toInt()),
            colorText: AppColors.textInverse,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
        final salaryValue = double.parse(salary.value);
        if (salaryValue <= 0) {
          Get.snackbar(
            'Salaire invalide',
            'Le salaire doit être supérieur à zéro',
            backgroundColor: AppColors.warning.withAlpha((0.8 * 255).toInt()),
            colorText: AppColors.textInverse,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
        return true;
      case 4: // Balance step
        if (balance.value.isEmpty || double.tryParse(balance.value) == null) {
          Get.snackbar(
            'Solde requis',
            'Veuillez saisir votre solde actuel',
            backgroundColor: AppColors.warning.withAlpha((0.8 * 255).toInt()),
            colorText: AppColors.textInverse,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
        return true;
      case 5: // Security step
        if (pin.value.length != 4) {
          Get.snackbar(
            'Code PIN requis',
            'Veuillez créer un code PIN à 4 chiffres',
            backgroundColor: AppColors.warning.withAlpha((0.8 * 255).toInt()),
            colorText: AppColors.textInverse,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
        return true;
      case 6: // Final step
        return true;
      default:
        return true;
    }
  }

  void _saveOnboardingData() {
    try {
      _hiveService.saveUserData({
        'name': name.value.trim(),
        'phone': phone.value.trim(),
        'salary': double.parse(salary.value),
        'initialBalance': double.parse(balance.value),
        'currentBalance': double.parse(balance.value),
        'currency': 'XOF',
        'pin': pin.value, // In a real app, this should be hashed
        'biometricEnabled': biometricEnabled.value,
        'onboardingCompleted': true,
        'setupDate': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        'Profil créé!',
        'Votre configuration a été sauvegardée avec succès',
        backgroundColor: AppColors.success.withAlpha((0.8 * 255).toInt()),
        colorText: AppColors.textInverse,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder vos données: $e',
        backgroundColor: AppColors.error.withAlpha((0.8 * 255).toInt()),
        colorText: AppColors.textInverse,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    nameInputController.dispose();
    phoneInputController.dispose();
    salaryInputController.dispose();
    balanceInputController.dispose();
    pinInputController.dispose();
    super.onClose();
  }
}
