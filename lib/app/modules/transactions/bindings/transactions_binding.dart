import 'package:get/get.dart';
import 'package:koaa/app/modules/transactions/controllers/transactions_controller.dart';

class TransactionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionsController>(
      () => TransactionsController(),
    );
  }
}

