import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/routes/app_routes.dart';
import 'package:koala/app/shared/services/auth_service.dart';
import 'package:koala/app/shared/services/storage_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = Get.find<StorageService>();

  final pinController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool obscurePin = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<String> enteredPin = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _checkExistingAuth();
  }

  @override
  void onClose() {
    pinController.dispose();
    super.onClose();
  }

  /// Check if user is already authenticated
  void _checkExistingAuth() async {
    final token = await _storageService.getAuthToken();
    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(Routes.home);
    }
  }

  /// Toggle PIN visibility
  void togglePinVisibility() {
    obscurePin.value = !obscurePin.value;
  }

  /// Add digit to PIN entry
  void addPinDigit(String digit) {
    if (enteredPin.length < 4) {
      enteredPin.add(digit);
      pinController.text = enteredPin.join();

      // Auto-submit when 4 digits entered
      if (enteredPin.length == 4) {
        login();
      }
    }
  }

  /// Remove last PIN digit
  void removePinDigit() {
    if (enteredPin.isNotEmpty) {
      enteredPin.removeLast();
      pinController.text = enteredPin.join();
    }
  }

  /// Clear all PIN digits
  void clearPin() {
    enteredPin.clear();
    pinController.clear();
    errorMessage.value = '';
  }

  /// Validate PIN format
  String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN est requis';
    }
    if (value.length != 4) {
      return 'PIN doit contenir 4 chiffres';
    }
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'PIN doit contenir uniquement des chiffres';
    }
    return null;
  }

  /// Perform login with PIN
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authService.login(
        pin: pinController.text,
        deviceId: await _authService.getDeviceId(),
      );

      if (result.isSuccess) {
        await _storageService.saveAuthToken(result.data!.token);
        Get.offAllNamed(Routes.home);
        Get.snackbar(
          'Connexion réussie',
          'Bienvenue dans Koala',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 2),
        );
      } else {
        errorMessage.value = result.message ?? 'Erreur de connexion';
        clearPin();

        Get.snackbar(
          'Erreur de connexion',
          result.message ?? 'PIN incorrect',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      errorMessage.value =
          'Erreur de connexion. Vérifiez votre connexion internet.';
      clearPin();

      Get.snackbar(
        'Erreur',
        'Impossible de se connecter. Vérifiez votre connexion internet.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to onboarding for new users
  void goToOnboarding() {
    Get.toNamed(Routes.onboarding);
  }

  /// Show forgot PIN dialog
  void showForgotPinDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('PIN oublié ?'),
        content: const Text(
          'Contactez le support pour réinitialiser votre PIN ou réinstallez l\'application pour créer un nouveau compte.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Get.back();
              goToOnboarding();
            },
            child: const Text('Nouveau compte'),
          ),
        ],
      ),
    );
  }
}
