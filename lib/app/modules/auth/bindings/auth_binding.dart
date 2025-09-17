import 'package:get/get.dart';
import 'package:koala/app/modules/auth/controllers/auth_controller.dart';
import 'package:koala/app/shared/services/auth_service.dart';
import 'package:koala/app/shared/services/storage_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<StorageService>(() => StorageService());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
