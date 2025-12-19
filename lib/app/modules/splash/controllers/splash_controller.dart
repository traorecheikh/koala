import 'dart:async';
import 'package:get/get.dart';
import 'package:koaa/app/core/service_initializer.dart';
import 'package:koaa/app/routes/app_pages.dart';

class SplashController extends GetxController {
  final isLoading = true.obs;
  final RxString statusMessage = 'Démarrage...'.obs;

  // Funny/Cute messages to show while loading
  final List<String> _loadingMessages = [
    'Réveil du Koala...',
    'Saviez-vous que le koala est le roi des arbres ?',
    'Vérification de vos économies...',
    'Analyse des budgets...',
    'Calcul de la richesse...',
    'Prêt !',
  ];

  @override
  void onInit() {
    super.onInit();
    _startMessageCycle();
    _startInitialization();
  }

  void _startMessageCycle() async {
    int index = 0;

    while (isLoading.value) {
      if (index >= _loadingMessages.length) break;

      statusMessage.value = _loadingMessages[index];

      // Smart delay: 1.5s base + extra time for long text
      // "Pixar" storytelling needs time to be read
      final delay = 1500 + (_loadingMessages[index].length * 30);
      await Future.delayed(Duration(milliseconds: delay));

      index++;
      // Loop if we run out but still loading
      if (index >= _loadingMessages.length) index = 0;
    }
  }

  Future<void> _startInitialization() async {
    // Minimum 2.5 seconds for the animation to be appreciated
    final minWait = Future.delayed(const Duration(milliseconds: 2500));

    // Initialize heavy services
    final init = ServiceInitializer.initialize();

    await Future.wait([minWait, init]);

    isLoading.value = false;
    statusMessage.value = 'C\'est parti !';

    // Tiny delay to show "Ready" state
    await Future.delayed(const Duration(milliseconds: 500));

    Get.offAllNamed(Routes.home);
  }
}
