import 'package:get/get.dart';
import 'package:koala/app/modules/main/views/main_view.dart';

import '../../dashboard/controllers/dashboard_controller.dart';
import '../../insights/controllers/insights_controller.dart';
import '../../loans/controllers/loans_controller.dart';
import '../../transactions/controllers/transaction_controller.dart';

/// Binding for MainController, ensures dependency injection via GetX.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<TransactionController>(
      () => TransactionController(),
      fenix: true,
    );
    Get.lazyPut<LoansController>(() => LoansController(), fenix: true);
    Get.lazyPut<InsightsController>(() => InsightsController(), fenix: true);
  }
}
