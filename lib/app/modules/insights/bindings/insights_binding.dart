import 'package:get/get.dart';
import 'package:koala/app/modules/insights/controllers/insights_controller.dart';

class InsightsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InsightsController>(() => InsightsController());
  }
}
