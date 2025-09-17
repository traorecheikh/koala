import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveService extends GetxService {
  late Box<bool> _settingsBox;
  late Box<dynamic> _userDataBox;

  Future<HiveService> init() async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
            _settingsBox = await Hive.openBox<bool>('settingsBox');
      _userDataBox = await Hive.openBox<dynamic>('userDataBox');
    } catch (e) {
      debugPrint('Error initializing Hive or opening box: $e');
      rethrow;
    }
    return this;
  }

  // Onboarding status
  bool get isOnboardingComplete =>
      _settingsBox.get('onboardingComplete') ?? false;
  Future<void> setOnboardingComplete(bool value) =>
      _settingsBox.put('onboardingComplete', value);

  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _userDataBox.put('userProfile', data);
  }

  Map<String, dynamic>? getUserData() {
    return _userDataBox.get('userProfile');
  }

  @override
  void onClose() {
    _settingsBox.close();
    _userDataBox.close();
    super.onClose();
  }
}
