import 'package:get/get.dart';
import 'package:koaa/app/services/security_service.dart';

class SecuritySettingsController extends GetxController {
  final _securityService = Get.find<SecurityService>();

  RxBool get isAuthEnabled => _securityService.isAuthEnabled;

  void toggleAuth(bool value) async {
    if (value) {
      // Enable lock
      await _securityService.enableLock();
    } else {
      // Disable lock
      _securityService.disableLock();
    }
  }
}