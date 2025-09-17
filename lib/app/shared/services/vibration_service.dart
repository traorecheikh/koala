import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

class VibrationService extends GetxService {
  Future<void> lightImpact() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }
  }

  Future<void> success() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 100, 100, 100]);
    }
  }
}
