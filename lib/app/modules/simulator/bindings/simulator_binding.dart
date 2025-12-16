import 'package:get/get.dart';
import 'package:koaa/app/modules/simulator/controllers/simulator_controller.dart';

class SimulatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SimulatorController>(
      () => SimulatorController(),
    );
  }
}
