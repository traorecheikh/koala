import 'package:get/get.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoriesController>(
      () => CategoriesController(),
      fenix: true,
    );
  }
}


