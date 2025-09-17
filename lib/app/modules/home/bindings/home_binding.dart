import 'package:get/get.dart';
import 'package:koala/app/modules/home/controllers/home_controller.dart';
import 'package:koala/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:koala/app/modules/transactions/controllers/transactions_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<TransactionsController>(() => TransactionsController());
  }
}