import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Safe navigation helper that prevents GetX snackbar controller crashes
class NavigationHelper {
  /// Safely navigate back without triggering snackbar errors
  static void safeBack({dynamic result}) {
    // 1. Try Navigator first (Most reliable)
    if (Get.context != null && Navigator.of(Get.context!).canPop()) {
       Navigator.of(Get.context!).pop(result);
       return;
    }

    // 2. Fallback to Get.back
    try {
      Get.back(result: result);
    } catch (e) {
      // 3. Last resort: just try to close dialog/bottomsheet/snackbar if any
      try {
        if (Get.isDialogOpen ?? false) Get.back();
        else if (Get.isBottomSheetOpen ?? false) Get.back();
        else if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      } catch (_) {}
    }
  }

  /// Safely close a dialog
  static void safeCloseDialog({dynamic result}) {
    try {
      if (Get.isDialogOpen ?? false) {
        Get.back(result: result);
      }
    } catch (e) {
      // Silently ignore
    }
  }

  /// Safely close a bottom sheet
  static void safeCloseBottomSheet({dynamic result}) {
    try {
      if (Get.isBottomSheetOpen ?? false) {
        Get.back(result: result);
      }
    } catch (e) {
      // Silently ignore
    }
  }
}
