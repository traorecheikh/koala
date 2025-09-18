import 'package:get/get.dart';
import 'package:koala/app/data/services/koa_ai_service.dart';
import 'package:koala/app/data/services/local_data_service.dart';
import 'package:koala/app/data/services/local_settings_service.dart';
import 'package:koala/app/data/services/biometric_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize core services for offline-first functionality
    Get.putAsync(() => LocalSettingsService().init(), permanent: true);
    Get.putAsync(() => LocalDataService().init(), permanent: true);
    Get.putAsync(() => KoaAiService().init(), permanent: true);
    
    // Initialize biometric service
    Get.put(BiometricService(), permanent: true);

    // API Client with Dio (using your existing infrastructure)
 }
}
