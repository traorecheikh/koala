import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/services/pin_service.dart';
import 'package:koaa/app/modules/lock/views/pin_lock_view.dart';

/// Security service - biometric is now PRIMARY, PIN is fallback
/// No phone lock required - we have our own PIN system
class SecurityService extends GetxService with WidgetsBindingObserver {
  bool _isLockScreenShowing = false;

  // Track pause time - 5 minutes before requiring re-auth
  DateTime? _pausedAt;
  static const _lockThresholdSeconds = 300; // 5 minutes (was 60)

  PinService get _pinService => Get.find<PinService>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onReady() {
    super.onReady();
    // Show lock on app start if PIN is set
    if (_pinService.isPinEnabled.value && _pinService.isPinSet.value) {
      _tryBiometricThenPin();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedAt != null &&
          _pinService.isPinEnabled.value &&
          _pinService.isPinSet.value &&
          !_isLockScreenShowing) {
        final pauseDuration = DateTime.now().difference(_pausedAt!).inSeconds;
        if (pauseDuration > _lockThresholdSeconds) {
          _tryBiometricThenPin();
        }
      }
      _pausedAt = null;
    }
  }

  /// Try biometric FIRST, only show PIN if biometric fails/unavailable
  Future<void> _tryBiometricThenPin() async {
    if (_isLockScreenShowing) return;

    // Try biometric first (silent attempt)
    final biometricAvailable = await _pinService.isBiometricAvailable();
    if (biometricAvailable) {
      final didAuth = await _pinService.authenticateWithBiometric();
      if (didAuth) {
        // Success! No need to show PIN screen
        return;
      }
    }

    // Biometric failed or unavailable - show PIN screen
    _showPinLockScreen();
  }

  /// Show PIN lock screen (fallback)
  void _showPinLockScreen() {
    if (_isLockScreenShowing) return;
    _isLockScreenShowing = true;

    Get.dialog(
      PopScope(
        canPop: false,
        child: PinLockView(
          onUnlocked: () {
            _isLockScreenShowing = false;
            Get.back();
          },
          onBiometricRequest: () async {
            // Manual biometric retry button
            final didAuth = await _pinService.authenticateWithBiometric();
            if (didAuth) {
              _isLockScreenShowing = false;
              Get.back();
            }
          },
        ),
      ),
      barrierDismissible: false,
      barrierColor: Get.theme.scaffoldBackgroundColor,
      useSafeArea: false,
    );
  }
}
