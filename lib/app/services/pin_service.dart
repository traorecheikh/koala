import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// Service for managing app PIN lock
/// Stores PIN securely using Hive
/// Works alongside SecurityService for biometric fallback
class PinService extends GetxService {
  static const String _boxName = 'settingsBox';
  static const String _pinKey = 'app_pin';
  static const String _pinEnabledKey = 'pin_enabled';

  final LocalAuthentication _auth = LocalAuthentication();

  final RxBool isPinSet = false.obs;
  final RxBool isPinEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    final box = Hive.box(_boxName);
    final storedPin = box.get(_pinKey) as String?;
    isPinSet.value = storedPin != null && storedPin.isNotEmpty;
    isPinEnabled.value = box.get(_pinEnabledKey, defaultValue: false);
  }

  /// Get stored PIN (null if not set)
  String? getStoredPin() {
    final box = Hive.box(_boxName);
    return box.get(_pinKey) as String?;
  }

  /// Set new PIN
  Future<bool> setPin(String pin) async {
    if (pin.length != 4) return false;

    try {
      final box = Hive.box(_boxName);
      await box.put(_pinKey, pin);
      await box.put(_pinEnabledKey, true);
      isPinSet.value = true;
      isPinEnabled.value = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Verify PIN
  bool verifyPin(String pin) {
    final storedPin = getStoredPin();
    return storedPin != null && storedPin == pin;
  }

  /// Disable PIN (removes it)
  Future<void> disablePin() async {
    final box = Hive.box(_boxName);
    await box.delete(_pinKey);
    await box.put(_pinEnabledKey, false);
    isPinSet.value = false;
    isPinEnabled.value = false;
  }

  /// Enable PIN lock
  Future<void> enablePinLock() async {
    final box = Hive.box(_boxName);
    await box.put(_pinEnabledKey, true);
    isPinEnabled.value = true;
  }

  /// Attempt biometric authentication
  Future<bool> authenticateWithBiometric() async {
    try {
      // Using older API for local_auth 3.x compatibility
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Utilisez votre empreinte pour déverrouiller Koala',
      );
      return didAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Check if biometrics are available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }
}
