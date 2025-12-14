import 'package:get/get.dart';
import 'package:koaa/app/modules/settings/controllers/security_settings_controller.dart';

class SecuritySettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SecuritySettingsController>(
      () => SecuritySettingsController(),
      fenix: true,
    );
  }
}
