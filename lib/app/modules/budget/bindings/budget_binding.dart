import 'package:get/get.dart';
import 'package:koaa/app/modules/budget/controllers/budget_controller.dart';

class BudgetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BudgetController>(
      () => BudgetController(),
    );
  }
}

