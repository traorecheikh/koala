import 'package:get/get.dart';
import 'package:koala/app/data/network/api_client.dart';
import 'package:koala/app/data/network/dio_provider.dart';
import 'package:koala/app/shared/controllers/theme_controller.dart';
import 'package:koala/app/shared/services/auth_service.dart';
import 'package:koala/app/shared/services/hive_service.dart';
import 'package:koala/app/shared/services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core services that need to be available app-wide
    Get.putAsync<StorageService>(() async {
      final service = StorageService();
      await service.onInit();
      return service;
    });

    // API Client with Dio (using your existing infrastructure)
    Get.lazyPut<ApiClient>(() => ApiClient(DioProvider.instance));
    Get.lazyPut<AuthService>(() => AuthService());
    // Ensure HiveService is initialized before registering dependent services
    Get.putAsync<HiveService>(() async {
      final hiveService = HiveService();
      await hiveService.init();
      return hiveService;
    });
    Get.put<ThemeController>(ThemeController());
  }
}
