import 'package:get/get.dart';
import 'package:koala/app/routes/app_routes.dart';
import 'package:koala/app/shared/services/storage_service.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // Show splash for minimum time for branding
      await Future.delayed(const Duration(milliseconds: 1500));

      // Check authentication status
      final hasToken = await _storageService.getAuthToken();
      final hasUserData = _storageService.hasUserData;

      if (hasToken != null && hasToken.isNotEmpty && hasUserData) {
        // User is authenticated, go to home
        Get.offAllNamed(Routes.home);
      } else if (hasUserData) {
        // User exists but not authenticated, go to login
        Get.offAllNamed(Routes.auth);
      } else {
        // New user, go to onboarding
        Get.offAllNamed(Routes.onboarding);
      }
    } catch (e) {
      errorMessage.value = 'Erreur d\'initialisation. Veuillez redémarrer l\'application.';
      isLoading.value = false;

      // Fallback to auth after error
      await Future.delayed(const Duration(seconds: 3));
      Get.offAllNamed(Routes.auth);
    }
  }
}
