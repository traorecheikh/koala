import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:koala/app/data/models/auth_response.dart';
import 'package:koala/app/data/network/api_client.dart';
import 'package:koala/app/shared/utils/result.dart';

class AuthService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Generate unique device ID
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios_device';
      }
    } catch (e) {
      // Fallback to timestamp-based ID
      return 'device_${DateTime.now().millisecondsSinceEpoch}';
    }

    return 'unknown_device';
  }

  /// Login with PIN and device ID
  Future<Result<AuthResponse>> login({
    required String pin,
    required String deviceId,
  }) async {
    try {
      final response = await _apiClient.login({
        'pin': pin,
        'device_id': deviceId,
      });

      if (response.response.statusCode == 200 && response.data != null) {
        final authResponse = AuthResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        return Result.success(authResponse);
      } else {
        return Result.error('PIN incorrect ou appareil non autorisé');
      }
    } catch (e) {
      return Result.error('Erreur de connexion: ${e.toString()}');
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    // Clear any stored tokens or session data
    // This would typically involve calling a logout endpoint
    // and clearing local storage
  }

  /// Check if current session is valid
  Future<bool> isSessionValid() async {
    // Implementation would check token validity
    // For now, return false to force re-authentication
    return false;
  }
}
