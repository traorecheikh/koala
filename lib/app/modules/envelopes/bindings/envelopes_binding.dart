import 'package:get/get.dart';
import 'package:koaa/app/modules/envelopes/controllers/envelopes_controller.dart';

class EnvelopesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EnvelopesController>(() => EnvelopesController());
  }
}
