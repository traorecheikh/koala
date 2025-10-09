import 'package:get/get.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';

import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<RecurringTransactionsController>(() => RecurringTransactionsController());
  }
}
