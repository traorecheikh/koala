import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/services/pin_service.dart';
import 'package:koaa/app/modules/lock/views/pin_setup_view.dart';

class SecuritySettingsController extends GetxController {
  final _pinService = Get.find<PinService>();

  RxBool get isPinSet => _pinService.isPinSet;
  RxBool get isPinEnabled => _pinService.isPinEnabled;

  /// Show custom PIN setup screen (no keyboard)
  void showPinSetupDialog(BuildContext context) {
    PinSetupView.show(context, isChanging: isPinSet.value);
  }

  /// Toggle PIN lock (enable/disable)
  void togglePinLock(bool value) async {
    if (value) {
      // Need to set a PIN first
      if (!isPinSet.value) {
        showPinSetupDialog(Get.context!);
      } else {
        await _pinService.enablePinLock();
      }
    } else {
      // Disable lock (keep PIN for next time)
      final box = Get.find<PinService>();
      await box.disablePin();
    }
  }

  /// Remove PIN completely
  void removePin() async {
    await _pinService.disablePin();
    Get.snackbar(
      'Succès',
      'Code PIN supprimé',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: KoalaColors.success,
      colorText: Colors.white,
    );
  }
}
