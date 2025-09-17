import 'package:get/get.dart';
import 'package:koala/app/modules/transactions/controllers/transaction_controller.dart';

/// Binding for transaction module dependencies
class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionController>(() => TransactionController());
  }
}
