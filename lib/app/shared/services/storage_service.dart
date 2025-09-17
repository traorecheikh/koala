import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

class StorageService extends GetxService {
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _settingsKey = 'app_settings';

  late Box _secureBox;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initStorage();
  }

  Future<void> _initStorage() async {
    try {
      _secureBox = await Hive.openBox('secure_storage');
    } catch (e, stack) {
      Get.log('Storage initialization error: $e', isError: true);
      Get.log(stack.toString(), isError: true);
      // Optionally rethrow in dev mode to catch issues early
      assert(() {
        throw Exception('Hive storage failed to initialize: $e');
      }());
    }
  }

  /// Save authentication token
  Future<void> saveAuthToken(String token) async {
    await _secureBox.put(_authTokenKey, token);
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    return _secureBox.get(_authTokenKey);
  }

  /// Clear authentication token
  Future<void> clearAuthToken() async {
    await _secureBox.delete(_authTokenKey);
  }

  /// Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _secureBox.put(_userDataKey, userData);
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final data = _secureBox.get(_userDataKey);
    return data?.cast<String, dynamic>();
  }

  /// Clear user data
  Future<void> clearUserData() async {
    await _secureBox.delete(_userDataKey);
  }

  /// Save app settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _secureBox.put(_settingsKey, settings);
  }

  /// Get app settings
  Future<Map<String, dynamic>?> getSettings() async {
    final data = _secureBox.get(_settingsKey);
    return data?.cast<String, dynamic>();
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _secureBox.clear();
  }

  /// Check if user data exists
  bool get hasUserData => _secureBox.containsKey(_userDataKey);

  /// Check if auth token exists
  bool get hasAuthToken => _secureBox.containsKey(_authTokenKey);
}
