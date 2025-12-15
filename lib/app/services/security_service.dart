import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService extends GetxService with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();
  final RxBool isAuthEnabled = false.obs;

  // Track if we are currently authenticating to avoid loop
  bool _isAuthenticating = false;

  // Track pause time to detect if phone was actually locked (not just app switch)
  DateTime? _pausedAt;
  static const _lockThresholdSeconds = 60; // Only lock if paused > 60 seconds

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void onReady() {
    super.onReady();
    if (isAuthEnabled.value) {
      requestAuthentication();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  void _loadSettings() {
    final box = Hive.box('settingsBox');
    isAuthEnabled.value = box.get('isAuthEnabled', defaultValue: false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedAt != null && isAuthEnabled.value) {
        final pauseDuration = DateTime.now().difference(_pausedAt!).inSeconds;
        // Only lock if paused for > 60 seconds (phone was likely locked)
        if (pauseDuration > _lockThresholdSeconds) {
          requestAuthentication();
        }
      }
      _pausedAt = null;
    }
  }

  Future<void> requestAuthentication() async {
    if (_isAuthenticating) return;
    _isAuthenticating = true;

    // Small delay to ensure the app is visible
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à Koala',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/Pattern fallback
        ),
      );

      if (!didAuthenticate) {
        // If authentication failed or was cancelled, we minimize or exit?
        // Or simply ask again.
        // For better UX, we might show a blocking dialog with "Unlock" button.
        _showLockScreen();
      }
    } on PlatformException catch (_) {
      // Handle error, maybe device doesn't have security set up
      // In that case, we can't lock.
    } finally {
      _isAuthenticating = false;
    }
  }

  void _showLockScreen() {
    Get.dialog(
      PopScope(
        canPop: false, // Prevent back button
        child: Scaffold(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Application Verrouillée',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog to retry
                    requestAuthentication();
                  },
                  child: const Text('Déverrouiller'),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Get.theme.scaffoldBackgroundColor, // Cover everything
    );
  }

  Future<bool> enableLock() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Authentifiez-vous pour activer le verrouillage',
        options: const AuthenticationOptions(stickyAuth: true),
      );

      if (didAuthenticate) {
        isAuthEnabled.value = true;
        Hive.box('settingsBox').put('isAuthEnabled', true);
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  void disableLock() {
    isAuthEnabled.value = false;
    Hive.box('settingsBox').put('isAuthEnabled', false);
  }
}
