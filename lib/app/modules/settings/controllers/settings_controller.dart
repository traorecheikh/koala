import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart'; // Changed import
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/category.dart' as models;
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/savings_goal.dart';
import 'package:restart_app/restart_app.dart'; // Optional: for cleaner restart, or just ask user
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/services/financial_context_service.dart';

class SettingsController extends GetxController {
  RxBool isDarkMode = Get.isDarkMode.obs;
  RxBool reduceMotion = false
      .obs; // For accessibility - disable animations for motion-sensitive users
  RxString currentVersion = ''.obs;
  late Dio _dio;
  late Box _settingsBox; // Make _settingsBox accessible for onClose

  @override
  void onInit() {
    super.onInit();
    Logger.level = kReleaseMode ? Level.off : Level.all;
    _setupDioLogger();
    _initSettings();
  }

  @override
  void onClose() {
    // Note: Do NOT close _settingsBox here as it's a global box opened in main.dart
    // and shared with other services (SecurityService, HomeController, etc.)
    _dio.close(force: true); // Close the Dio client
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    _loadCurrentVersion();
  }

  Future<void> _initSettings() async {
    _settingsBox = await Hive.openBox('settingsBox'); // Assign to _settingsBox
    final savedIsDark = _settingsBox.get('isDarkMode');
    if (savedIsDark != null) {
      isDarkMode.value = savedIsDark;
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    }
  }

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _settingsBox.put('isDarkMode', value); // Use _settingsBox
  }

  Future<void> performReset() async {
    try {
      debugPrint('performReset: Starting reset process...');

      // Clear all Hive boxes - ensure all data is wiped
      // Need to access typed boxes the same way they were opened
      final transactionBox = Hive.box<LocalTransaction>('transactionBox');
      final userBox = Hive.box<LocalUser>('userBox');
      final jobBox = Hive.box<Job>('jobBox');
      final budgetBox = Hive.box<Budget>('budgetBox');
      final debtBox = Hive.box<Debt>('debtBox');
      final recurringBox =
          Hive.box<RecurringTransaction>('recurringTransactionBox');
      final savingsGoalBox = Hive.box<SavingsGoal>('savingsGoalBox');
      final financialGoalBox = Hive.box<FinancialGoal>('financialGoalBox');
      final categoryBox = Hive.box<models.Category>('categoryBox');

      // Clear each box and flush to ensure it's written to disk
      await transactionBox.clear();
      debugPrint(
          'performReset: Cleared transactionBox (${transactionBox.length} items remaining)');

      await userBox.clear();
      debugPrint(
          'performReset: Cleared userBox (${userBox.length} items remaining)');

      await jobBox.clear();
      debugPrint(
          'performReset: Cleared jobBox (${jobBox.length} items remaining)');

      await budgetBox.clear();
      await debtBox.clear();
      await recurringBox.clear();
      await savingsGoalBox.clear();
      await financialGoalBox.clear();
      await categoryBox.clear();

      // Clear settings box (untyped)
      try {
        final settingsBox = Hive.box('settingsBox');
        await settingsBox.clear();
        debugPrint('performReset: Cleared settingsBox');
      } catch (e) {
        debugPrint('performReset: Could not clear settingsBox: $e');
      }

      // Clear migration box if it exists
      try {
        if (Hive.isBoxOpen('migrationBox')) {
          final migrationBox = Hive.box('migrationBox');
          await migrationBox.clear();
        }
      } catch (e) {
        debugPrint('performReset: Could not clear migrationBox: $e');
      }

      // Clear in-memory state of FinancialContextService
      try {
        if (Get.isRegistered<FinancialContextService>()) {
          Get.find<FinancialContextService>().clearMemory();
          debugPrint('performReset: Cleared FinancialContextService memory');
        }
      } catch (e) {
        debugPrint('performReset: Could not clear FinancialContextService: $e');
      }

      debugPrint('performReset: All boxes cleared. Restarting app...');

      // Small delay to ensure all writes are flushed
      await Future.delayed(const Duration(milliseconds: 500));

      // Restart the app
      final bool restarted = await Restart.restartApp();

      if (!restarted) {
        // If restart failed (e.g. debug mode or platform limitation),
        // navigate to home which will re-trigger checks
        Get.offAllNamed('/home');
      }
    } catch (e, st) {
      debugPrint('performReset: Error during reset: $e\n$st');
      Get.snackbar('Erreur',
          'Impossible de réinitialiser l\'application. Veuillez redémarrer manuellement.');
    }
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
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion.value = packageInfo.version;
    } catch (e) {
      currentVersion.value = 'Unknown';
      // Silently fail, don't show snackbar on startup to avoid context issues
    }
  }

  Future<void> checkForUpdates() async {
    // Check GitHub for APK updates
    // Update this URL to point to your JSON metadata file, not the APK directly
    const String updateMetadataUrl =
        'https://github.com/traorecheikh/koala/raw/refs/heads/main/version.json';

    try {
      // Add 30-second timeout for security
      final response = await _dio.get(
        updateMetadataUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
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
        final String? checksum =
            data['checksum']; // SHA-256 checksum for verification

        if (_isNewerVersion(currentVersion.value, latestVersion)) {
          _promptUpdate(latestVersion, apkUrl, checksum);
        } else {
          Get.snackbar(
              'Aucune mise à jour', 'Vous utilisez la dernière version.');
        }
      } else {
        Get.snackbar('Erreur', 'Impossible de vérifier les mises à jour.');
      }
    } catch (e) {
      Get.snackbar('Erreur',
          'Échec de la vérification des mises à jour. Vérifiez votre connexion.');
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
      // Handle build numbers (e.g., 1.0.0+1) by taking only the version part
      final currentVersionOnly = current.split('+').first;

      // Split the version strings into parts and replace nulls with 0
      final currentParts = currentVersionOnly.split('.').map((part) {
        return int.tryParse(part) ?? 0;
      }).toList();
      final latestParts = latest.split('.').map((part) {
        return int.tryParse(part) ?? 0;
      }).toList();

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

      // Compare each part of the version numbers
      for (int i = 0; i < maxLength; i++) {
        if (latestParts[i] > currentParts[i]) {
          return true;
        }
        if (latestParts[i] < currentParts[i]) {
          return false;
        }
      }

      return false;
    } catch (e) {
      Get.snackbar('Erreur', 'Format de version invalide.');
      return false;
    }
  }

  Future<void> _promptUpdate(
      String version, String apkUrl, String? checksum) async {
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
        color: Get.theme.colorScheme.onSurface,
      ),
      textConfirm: 'Mettre à jour',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      buttonColor: Get.theme.colorScheme.primary,
      cancelTextColor: Get.theme.colorScheme.secondary,
      onConfirm: () async {
        NavigationHelper.safeBack();
        await _downloadAndInstallApk(apkUrl, checksum);
      },
      radius: 8,
    );
  }

  Future<void> _downloadAndInstallApk(String apkUrl,
      [String? expectedChecksum]) async {
    File? downloadedFile;
    try {
      // 1. Request Permission to Install Packages (Android 8+)
      if (!await Permission.requestInstallPackages.isGranted) {
        final status = await Permission.requestInstallPackages.request();
        if (!status.isGranted) {
          Get.snackbar('Permission Requise',
              'Veuillez autoriser l\'installation d\'applications inconnues pour la mise à jour.');
          openAppSettings();
          return;
        }
      }

      // 2. Download to Temporary Directory
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/update.apk';
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }

      Get.snackbar(
          'Téléchargement', 'Téléchargement de la mise à jour en cours...',
          showProgressIndicator: true, duration: const Duration(seconds: 30));

      // Add timeout to download
      await _dio.download(
        apkUrl,
        filePath,
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(seconds: 30),
        ),
        onReceiveProgress: (rec, total) {
          // Could update a progress variable here
        },
      );

      downloadedFile = file;

      // 3. Verify checksum if provided
      if (expectedChecksum != null && expectedChecksum.isNotEmpty) {
        Get.closeAllSnackbars();
        Get.snackbar(
            'Vérification', 'Vérification de l\'intégrité du fichier...',
            showProgressIndicator: true, duration: const Duration(seconds: 10));

        final fileBytes = await file.readAsBytes();
        final actualChecksum = sha256.convert(fileBytes).toString();

        if (actualChecksum.toLowerCase() != expectedChecksum.toLowerCase()) {
          // Checksum mismatch - delete file immediately
          await file.delete();
          Get.closeAllSnackbars();
          Get.snackbar('Erreur de sécurité',
              'Le fichier téléchargé est corrompu ou invalide. Téléchargement annulé.',
              backgroundColor: Colors.red[100],
              duration: const Duration(seconds: 5));
          return;
        }
      }

      // 4. Trigger Installation
      Get.closeAllSnackbars();

      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        Get.snackbar('Erreur',
            'Impossible de lancer l\'installation: ${result.message}');
      }
    } catch (e) {
      // Clean up on error
      if (downloadedFile != null && await downloadedFile.exists()) {
        await downloadedFile.delete();
      }
      Get.closeAllSnackbars();
      Get.snackbar('Erreur',
          'Échec du téléchargement ou de l\'installation. Vérifiez votre connexion.');
    }
  }
}

