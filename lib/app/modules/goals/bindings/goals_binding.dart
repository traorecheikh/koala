import 'package:get/get.dart';
import 'package:koaa/app/modules/goals/controllers/goals_controller.dart';

class GoalsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GoalsController>(
      () => GoalsController(),
    );
  }
}
