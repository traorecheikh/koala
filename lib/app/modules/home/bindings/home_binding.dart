import 'package:get/get.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/modules/goals/controllers/goals_controller.dart';
import 'package:koaa/app/modules/budget/controllers/budget_controller.dart';
import 'package:koaa/app/modules/debt/controllers/debt_controller.dart';
import 'package:koaa/app/modules/analytics/controllers/analytics_controller.dart';
import 'package:koaa/app/modules/simulator/controllers/simulator_controller.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CategoriesController>(() => CategoriesController());
    Get.lazyPut<GoalsController>(() => GoalsController());
    Get.lazyPut<BudgetController>(() => BudgetController());
    Get.lazyPut<DebtController>(() => DebtController());
    Get.lazyPut<AnalyticsController>(() => AnalyticsController());
    Get.lazyPut<SimulatorController>(() => SimulatorController());
  }
}


