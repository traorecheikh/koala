import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsController extends GetxController {
  RxBool isDarkMode = Get.isDarkMode.obs;
  RxString currentVersion = ''.obs;
  late Dio _dio;

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  void onInit() {
    super.onInit();
    Logger.level = Level.all;
    _setupDioLogger();
    _loadCurrentVersion();
  }

  void _setupDioLogger() {
    _dio = Dio();
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        compact: true,
      ),
    );
  }

  Future<void> _loadCurrentVersion() async {
    try {
      Logger().i('Loading current app version...');
      final appInfo = AppInfo.of(Get.context!);
      currentVersion.value = appInfo.package.version.toString();
      Logger().i('Loaded current app version: ${currentVersion.value}');
    } catch (e) {
      currentVersion.value = 'Unknown';
      Logger().e('Failed to load app version: $e');
      Get.snackbar('Error', 'Failed to load app version.');
    }
  }

  Future<void> checkForUpdates() async {
    // Update this URL to point to your JSON metadata file, not the APK directly
    const String updateMetadataUrl =
        'https://github.com/traorecheikh/koala/raw/refs/heads/main/version.json';

    try {
      Logger().i('Checking for updates...');
      final response = await _dio.get(updateMetadataUrl);
      Logger().i(
        'Received response: \\${response.statusCode} \\${response.data}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data;
        if (response.data is String) {
          data = jsonDecode(response.data);
        } else {
          data = response.data;
        }
        final String latestVersion = data['version'];
        final String apkUrl = data['apk_url'];
        Logger().i('Latest version from server: \\${latestVersion}');
        Logger().i('APK URL from server: \\${apkUrl}');

        if (_isNewerVersion(currentVersion.value, latestVersion)) {
          Logger().i('A newer version is available. Prompting update.');
          _promptUpdate(latestVersion, apkUrl);
        } else {
          Logger().i('No updates available. Current version is up-to-date.');
          Get.snackbar('No Updates', 'You are using the latest version.');
        }
      } else {
        Logger().e(
          'Failed to fetch update info. Status code: \\${response.statusCode}',
        );
        Get.snackbar('Error', 'Failed to check for updates.');
      }
    } catch (e) {
      Logger().e('Update check failed: \\${e}');
      Get.snackbar('Error', 'Failed to check for updates.');
    }
  }

  /// Fallback: Direct APK download if no JSON metadata is available
  Future<void> downloadAndInstallApkDirect() async {
    const String apkUrl =
        'https://github.com/traorecheikh/koala/raw/refs/heads/main/build/app/outputs/flutter-apk/app-release.apk';
    await _downloadAndInstallApk(apkUrl);
  }

  bool _isNewerVersion(String current, String latest) {
    try {
      Logger().i(
        'Starting version comparison: current=$current, latest=$latest',
      );

      // Handle build numbers (e.g., 1.0.0+1) by taking only the version part.
      final currentVersionOnly = current.split('+').first;
      Logger().i(
        'Extracted current version without build number: $currentVersionOnly',
      );

      // Split the version strings into parts and replace nulls with 0
      final currentParts = currentVersionOnly.split('.').map((part) {
        final parsed = int.tryParse(part);
        if (parsed == null) {
          Logger().w('Failed to parse part of current version: $part');
        }
        return parsed ?? 0;
      }).toList();
      final latestParts = latest.split('.').map((part) {
        final parsed = int.tryParse(part);
        if (parsed == null) {
          Logger().w('Failed to parse part of latest version: $part');
        }
        return parsed ?? 0;
      }).toList();
      Logger().i(
        'Parsed version parts: currentParts=$currentParts, latestParts=$latestParts',
      );

      // Ensure both lists are the same length by padding with zeros
      final maxLength = currentParts.length > latestParts.length
          ? currentParts.length
          : latestParts.length;
      while (currentParts.length < maxLength) {
        currentParts.add(0);
      }
      while (latestParts.length < maxLength) {
        latestParts.add(0);
      }
      Logger().i(
        'Normalized version parts: currentParts=$currentParts, latestParts=$latestParts',
      );

      // Compare each part of the version numbers
      for (int i = 0; i < maxLength; i++) {
        final currentPart = currentParts[i];
        final latestPart = latestParts[i];
        Logger().i(
          'Comparing parts: currentPart=$currentPart, latestPart=$latestPart',
        );
        if (latestPart > currentPart) {
          Logger().i('Latest version is newer.');
          return true;
        }
        if (latestPart < currentPart) {
          Logger().i('Current version is newer.');
          return false;
        }
      }

      // If all parts are equal, return false
      Logger().i('Versions are equal.');
      return false;
    } catch (e, stackTrace) {
      Logger().e('Version comparison failed, $e, $stackTrace');
      Get.snackbar('Error', 'Invalid version format encountered.');
      return false;
    }
  }

  Future<void> _promptUpdate(String version, String apkUrl) async {
    Get.defaultDialog(
      title: 'Mise à jour disponible',
      titleStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Get.theme.colorScheme.primary,
      ),
      middleText:
          'La version $version est disponible. Voulez-vous mettre à jour ?',
      middleTextStyle: TextStyle(
        fontSize: 16,
        color: Get.theme.colorScheme.onBackground,
      ),
      textConfirm: 'Mettre à jour',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      buttonColor: Get.theme.colorScheme.primary,
      cancelTextColor: Get.theme.colorScheme.secondary,
      onConfirm: () async {
        Get.back();
        await _downloadAndInstallApk(apkUrl);
      },
      radius: 8,
    );
  }

  Future<void> _downloadAndInstallApk(String apkUrl) async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception('Failed to get storage directory.');

      final filePath = '${dir.path}/update.apk';
      final file = File(filePath);

      Get.snackbar('Downloading', 'Downloading update...');
      await _dio.download(apkUrl, filePath);

      Get.snackbar('Download Complete', 'Launching installer...');
      await launchUrl(Uri.file(filePath), mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar('Error', 'Failed to download or install the update.');
    }
  }
}
