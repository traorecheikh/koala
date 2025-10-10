import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsController extends GetxController {
  RxBool isDarkMode = Get.isDarkMode.obs;
  RxString currentVersion = ''.obs;

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  void onInit() {
    super.onInit();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion.value = packageInfo.version;
    } catch (e) {
      currentVersion.value = 'Unknown';
      Get.snackbar('Error', 'Failed to load app version.');
    }
  }

  Future<void> checkForUpdates() async {
    const String updateUrl =
        'https://raw.githubusercontent.com/traorecheikh/koala/main/version.json';

    try {
      final response = await Dio().get(updateUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        final String latestVersion = data['version'];
        final String apkUrl = data['apk_url'];

        if (_isNewerVersion(currentVersion.value, latestVersion)) {
          _promptUpdate(latestVersion, apkUrl);
        } else {
          Get.snackbar('No Updates', 'You are using the latest version.');
        }
      }
    } catch (e) {
      Logger().e('Update check failed ${e}');
      Get.snackbar('Error', 'Failed to check for updates.');
    }
  }

  bool _isNewerVersion(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < currentParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
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
      await Dio().download(apkUrl, filePath);

      Get.snackbar('Download Complete', 'Launching installer...');
      await launchUrl(Uri.file(filePath), mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar('Error', 'Failed to download or install the update.');
    }
  }
}
