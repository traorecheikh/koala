import 'package:get/get.dart';
import 'package:koala/app/shared/services/storage_service.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StorageService>(StorageService());
    Get.lazyPut<SplashController>(
      () => SplashController(),
    );
  }
}
