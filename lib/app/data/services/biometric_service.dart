import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';

/// Service for handling biometric authentication
class BiometricService extends GetxService {
  static BiometricService get to => Get.find();
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  /// Check if biometric authentication is available on the device
  Future<bool> isAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
  
  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  /// Authenticate using biometrics
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await this.isAvailable();
      if (!isAvailable) {
        return false;
      }
      
      return await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Authentification biométrique',
            cancelButton: 'Annuler',
            deviceCredentialsRequiredTitle: 'Authentification requise',
            deviceCredentialsSetupDescription: 'Veuillez configurer l\'authentification sur votre appareil',
            goToSettingsButton: 'Paramètres',
            goToSettingsDescription: 'Aller aux paramètres pour configurer l\'authentification',
          ),
          IOSAuthMessages(
            cancelButton: 'Annuler',
            goToSettingsButton: 'Paramètres',
            goToSettingsDescription: 'Aller aux paramètres pour configurer l\'authentification',
            lockOut: 'Authentification bloquée. Veuillez réessayer plus tard.',
          ),
        ],
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow PIN/password fallback
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur d\'authentification',
        'Impossible d\'utiliser l\'authentification biométrique: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
  
  /// Get readable names for biometric types
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Reconnaissance faciale';
      case BiometricType.fingerprint:
        return 'Empreinte digitale';
      case BiometricType.iris:
        return 'Reconnaissance iris';
      case BiometricType.weak:
        return 'Authentification faible';
      case BiometricType.strong:
        return 'Authentification forte';
    }
  }
  
  /// Check if user can authenticate with any method (biometric + PIN/password)
  Future<bool> canAuthenticate() async {
    try {
      return await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }
}