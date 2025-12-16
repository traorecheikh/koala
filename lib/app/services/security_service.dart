import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/services/pin_service.dart';
import 'package:koaa/app/modules/lock/views/pin_lock_view.dart';

/// Security service - uses app PIN first, biometric is optional bypass
/// No phone lock required - we have our own PIN system
class SecurityService extends GetxService with WidgetsBindingObserver {
  bool _isLockScreenShowing = false;

  // Track pause time
  DateTime? _pausedAt;
  static const _lockThresholdSeconds = 60;

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
      _showPinLockScreen();
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
          _showPinLockScreen();
        }
      }
      _pausedAt = null;
    }
  }

  /// Show PIN lock screen
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
            // Optional biometric bypass
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
