import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/routes/app_routes.dart';
import 'package:koala/app/shared/services/hive_service.dart';
import 'package:koala/app/shared/theme/colors.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  var currentPage = 0.obs;

  final TextEditingController salaryInputController = TextEditingController();
  final TextEditingController balanceInputController = TextEditingController();

  var salary = ''.obs;
  var balance = ''.obs;

  final HiveService _hiveService = Get.find<HiveService>();

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(() {
      currentPage.value = pageController.page?.round() ?? 0;
    });
    salaryInputController.addListener(() {
      salary.value = salaryInputController.text;
    });
    balanceInputController.addListener(() {
      balance.value = balanceInputController.text;
    });
  }

  void nextPage() {
    // Validate current step before proceeding
    if (!_validateCurrentStep()) {
      return;
    }

    if (currentPage.value < 4) {
      // Now we have 5 steps (0-4)
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
      4, // Go to completion step
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
      case 2: // Salary step
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
        return true;
      case 3: // Balance step
        if (balance.value.isEmpty || double.tryParse(balance.value) == null) {
          print('Balance: ${balance.value}');
          Get.snackbar(
            'Solde requis',
            'Veuillez saisir votre solde actuel${balance.value}',
            backgroundColor: AppColors.warning.withAlpha((0.8 * 255).toInt()),
            colorText: AppColors.textInverse,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
        return true;
      case 4: // Final step
        return true;
      default:
        return true;
    }
  }

  void _saveOnboardingData() {
    try {
      _hiveService.saveUserData({
        'salary': double.parse(salary.value),
        'initialBalance': double.parse(balance.value),
        'currentBalance': double.parse(balance.value),
        'currency': 'XOF',
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
        'Impossible de sauvegarder vos données',
        backgroundColor: AppColors.error.withAlpha((0.8 * 255).toInt()),
        colorText: AppColors.textInverse,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    salaryInputController.dispose();
    balanceInputController.dispose();
    super.onClose();
  }
}
