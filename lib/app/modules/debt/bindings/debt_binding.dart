import 'package:get/get.dart';
import 'package:koaa/app/modules/debt/controllers/debt_controller.dart';

class DebtBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DebtController>(
      () => DebtController(),
    );
  }
}


