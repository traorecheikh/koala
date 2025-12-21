import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/theme.dart';
import 'package:koaa/app/services/isar_service.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hive_ce/hive.dart';
import 'package:wakelock_plus/wakelock_plus.dart'; // Added WakelockPlus
import 'package:restart_app/restart_app.dart'; // Optional: for cleaner restart, or just ask user
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/services/financial_context_service.dart';

import 'package:koaa/app/core/design_system.dart';

enum BalanceCardStyle {
  classic, // Default Gradient
  minimal, // Solid Matte
  mesh, // Mesh Gradient
  comic, // Halftone/Pop Art
  hero, // Custom Image Asset
}

class SettingsController extends GetxController {
  RxBool isDarkMode = Get.isDarkMode.obs;
  Rx<AppSkin> currentSkin = AppSkin.blue.obs;
  Rx<BalanceCardStyle> currentCardStyle = BalanceCardStyle.classic.obs;
  RxString currentHeroAsset = ''.obs; // For Hero style

  RxBool reduceMotion = false
      .obs; // For accessibility - disable animations for motion-sensitive users
  RxString currentVersion = ''.obs;
  late Dio _dio;
  late Box _settingsBox; // Make _settingsBox accessible for onClose

  Color get activeThemeColor => currentSkin.value.color;

  Rx<HeroThemeData?> currentHeroTheme = Rx<HeroThemeData?>(null);

  // Expanded Hero Theme Data
  static final Map<String, HeroThemeData> heroThemesData = {
    'assets/hero-folder/spider.png': HeroThemeData(
      patternAsset: 'assets/patterns/web_spider.png',
      baseColor: Color(0xFFE23636),
      patternOpacity: 0.05, // Reduced from 0.08
    ),
    'assets/hero-folder/deadpool.png': HeroThemeData(
      patternAsset: 'assets/patterns/deadpool_grunge.png',
      baseColor: Color(0xFF8B0000),
      patternOpacity: 0.1, // Reduced from 0.15
    ),
    'assets/hero-folder/gojo-jujutsu-kaisen.png': HeroThemeData(
      patternAsset: 'assets/patterns/gojo_void.png',
      baseColor: Color(0xFF512DA8),
      patternOpacity: 0.08, // Reduced from 0.12
    ),
    'assets/hero-folder/batman.png': HeroThemeData(
      patternAsset: 'assets/patterns/bats_pattern.png',
      baseColor: Color(0xFF263238),
      patternOpacity: 0.04, // Reduced from 0.06
    ),
    'assets/hero-folder/ironman.png': HeroThemeData(
      patternAsset: 'assets/patterns/tech_hud.png',
      baseColor: Color(0xFFBF360C),
      patternOpacity: 0.06, // Reduced from 0.1
    ),
    'assets/hero-folder/naruto.png': HeroThemeData(
      patternAsset: 'assets/patterns/konoha_symbol.png',
      baseColor: Color(0xFFFF6D00),
      patternOpacity: 0.05, // Reduced from 0.08
    ),
    'assets/hero-folder/demonslayer.png': HeroThemeData(
      patternAsset: 'assets/patterns/tanjiro_pattern.png',
      baseColor: Color(0xFF2E7D32),
      patternOpacity: 0.06, // Reduced from 0.1
    ),
    'assets/hero-folder/the-flash.png': HeroThemeData(
      patternAsset: 'assets/patterns/lightening_force.png',
      baseColor: Color(0xFFFF0000),
      patternOpacity: 0.05, // Reduced from 0.08
    ),
  };

  // Backward compatibility getter if strictly needed, or just use baseColor
  static Map<String, Color> get heroThemes =>
      heroThemesData.map((key, value) => MapEntry(key, value.baseColor));

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
    }

    final savedSkinIndex = _settingsBox.get('appSkinIndex');
    if (savedSkinIndex != null && savedSkinIndex < AppSkin.values.length) {
      currentSkin.value = AppSkin.values[savedSkinIndex];
    }

    // Load Card Style
    final savedCardStyleIndex = _settingsBox.get('balanceCardStyleIndex');
    if (savedCardStyleIndex != null &&
        savedCardStyleIndex < BalanceCardStyle.values.length) {
      currentCardStyle.value = BalanceCardStyle.values[savedCardStyleIndex];
    }

    // Load Hero Asset & Apply Theme
    final savedHeroAsset = _settingsBox.get('heroAsset');
    if (savedHeroAsset != null &&
        savedHeroAsset is String &&
        savedHeroAsset.isNotEmpty) {
      currentHeroAsset.value = savedHeroAsset;
      // Properly restore the Hero Theme Data for background persistence
      if (heroThemesData.containsKey(savedHeroAsset)) {
        currentHeroTheme.value = heroThemesData[savedHeroAsset];
        AppTheme.heroThemeNotifier.value = currentHeroTheme.value;
      }
    }

    _updateTheme();
  }

  void _updateTheme() {
    // Update global notifier to rebuild GetMaterialApp with new skin
    AppTheme.skinNotifier.value = currentSkin.value;

    // Update GetX mode
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // Also update Get.theme for immediate consistency (optional but good for non-context usages)
    Get.changeTheme(AppTheme.getTheme(
        skin: currentSkin.value,
        brightness: isDarkMode.value ? Brightness.dark : Brightness.light));
  }

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    _settingsBox.put('isDarkMode', value);
    _updateTheme();
  }

  void changeSkin(AppSkin skin) {
    currentSkin.value = skin;
    _settingsBox.put('appSkinIndex', skin.index);
    _updateTheme();
  }

  void changeCardStyle(BalanceCardStyle style) {
    currentCardStyle.value = style;
    _settingsBox.put('balanceCardStyleIndex', style.index);

    if (style == BalanceCardStyle.hero) {
      // Re-apply Hero Theme if switching TO Hero
      if (currentHeroAsset.value.isNotEmpty) {
        changeHeroAsset(currentHeroAsset.value);
      }
    } else {
      // Switching AWAY from Hero (e.g. to Classic)
      // Reset to Default Blue (Standard UI)
      changeSkin(AppSkin.blue);

      // Disable Global Hero Background
      currentHeroTheme.value = null;
      AppTheme.heroThemeNotifier.value = null;
    }
  }

  void changeHeroAsset(String assetPath) {
    currentHeroAsset.value = assetPath;
    _settingsBox.put('heroAsset', assetPath);

    // Update Hero Theme Data
    currentHeroTheme.value = heroThemesData[assetPath];
    AppTheme.heroThemeNotifier.value = currentHeroTheme.value;

    // Automatically switch App Skin to match Hero
    if (assetPath.contains('spider')) {
      changeSkin(AppSkin.spiderRed);
    } else if (assetPath.contains('deadpool')) {
      changeSkin(AppSkin.deadpoolRed);
    } else if (assetPath.contains('gojo')) {
      changeSkin(AppSkin.gojoPurple);
    } else if (assetPath.contains('batman')) {
      changeSkin(AppSkin.batmanDark);
    } else if (assetPath.contains('ironman')) {
      changeSkin(AppSkin.ironmanRed);
    } else if (assetPath.contains('naruto')) {
      changeSkin(AppSkin.narutoOrange);
    } else if (assetPath.contains('demonslayer')) {
      changeSkin(AppSkin.tanjiroGreen);
    } else if (assetPath.contains('flash')) {
      changeSkin(AppSkin.flashRed);
    }
  }

  Future<void> performReset() async {
    try {
      debugPrint('performReset: Starting reset process...');

      // Clear all data from Isar (Source of Truth)
      IsarService.clearTransactions();
      IsarService.deleteUser();
      IsarService.clearJobs();
      IsarService.clearBudgets();
      IsarService.clearDebts();
      IsarService.clearRecurringTransactions();
      IsarService.clearSavingsGoals();
      IsarService.clearGoals();
      IsarService.clearCategories();
      debugPrint('performReset: Cleared all Isar data');

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
        final String releaseNotes = data['release_notes'] ??
            'Améliorations des performances et corrections de bugs.';

        debugPrint(
            'Checking for updates: Current=$currentVersion, Latest=$latestVersion');

        if (_isNewerVersion(currentVersion.value, latestVersion)) {
          _promptUpdate(latestVersion, apkUrl, checksum, releaseNotes);
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
    await _downloadAndInstallApk(apkUrl, null);
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

  Future<void> _promptUpdate(String version, String apkUrl, String? checksum,
      String releaseNotes) async {
    final showNotes = false.obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20), // Reduced padding
          decoration: BoxDecoration(
            color: KoalaColors.surface(Get.context!),
            borderRadius: BorderRadius.circular(20), // Slightly reduced radius
            boxShadow: KoalaColors.shadowMedium,
            border: Border.all(
                color:
                    KoalaColors.primaryUi(Get.context!).withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header (Smaller)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KoalaColors.primaryUi(Get.context!)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: KoalaColors.primaryUi(Get.context!),
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              // Title (Refined size)
              Text(
                'Mise à jour v$version',
                style: KoalaTypography.heading3(Get.context!)
                    .copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // What's New Toggle
              Obx(() => GestureDetector(
                    onTap: () => showNotes.value = !showNotes.value,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: KoalaColors.textSecondary(Get.context!)
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Voir les nouveautés",
                                style: KoalaTypography.bodySmall(Get.context!)
                                    .copyWith(
                                  color: KoalaColors.primaryUi(Get.context!),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                showNotes.value
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: KoalaColors.primaryUi(Get.context!),
                              ),
                            ],
                          ),
                          if (showNotes.value) ...[
                            const SizedBox(height: 8),
                            Text(
                              releaseNotes,
                              style: KoalaTypography.caption(Get.context!)
                                  .copyWith(
                                color: KoalaColors.textSecondary(Get.context!),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: 24),
              // Actions
              Column(
                children: [
                  KoalaButton(
                    text: 'Installer maintenant',
                    onPressed: () async {
                      NavigationHelper.safeBack();
                      await _downloadAndInstallApk(apkUrl, checksum);
                    },
                    icon: Icons.system_update_rounded,
                    backgroundColor: KoalaColors.primaryUi(Get.context!),
                  ),
                  const SizedBox(height: 8), // Tighter spacing
                  KoalaButton(
                    text: 'Plus tard',
                    onPressed: () => NavigationHelper.safeBack(),
                    backgroundColor: Colors.transparent,
                    textColor: KoalaColors.textSecondary(Get.context!),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  CancelToken? _cancelToken; // Token to cancel download

  Future<void> _downloadAndInstallApk(String apkUrl,
      [String? expectedChecksum]) async {
    File? downloadedFile;
    _cancelToken = CancelToken(); // Initialize new token

    try {
      // 1. Request Permission
      if (!await Permission.requestInstallPackages.isGranted) {
        final status = await Permission.requestInstallPackages.request();
        if (!status.isGranted) {
          Get.snackbar('Permission Requise',
              'Veuillez autoriser l\'installation d\'applications inconnues pour la mise à jour.');
          openAppSettings();
          return;
        }
      }

      // 2. Prepare Download & Keep Screen On
      // Enable wakelock to prevent screen form turning off
      try {
        await WakelockPlus.enable();
      } catch (e) {
        debugPrint('Failed to enable wakelock: $e');
      }

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/update.apk';
      final file = File(filePath);

      // Check for existing partial file to resume
      int downloadedBytes = 0;
      if (file.existsSync()) {
        downloadedBytes = await file.length();
      }

      // Progress State
      final RxDouble progress = 0.0.obs;
      final RxString progressText = '0%'.obs;

      // 3. Show Downloading Dialog
      Get.dialog(
        PopScope(
          canPop: false, // Prevent back button closing
          child: Dialog(
            backgroundColor: KoalaColors.surface(Get.context!),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Téléchargement...',
                    style: KoalaTypography.heading3(Get.context!)
                        .copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Obx(() => CircularProgressIndicator(
                              value: progress.value,
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                              backgroundColor:
                                  KoalaColors.primaryUi(Get.context!)
                                      .withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  KoalaColors.primaryUi(Get.context!)),
                            )),
                      ),
                      Obx(() => Text(
                            progressText.value,
                            style: KoalaTypography.bodySmall(Get.context!)
                                .copyWith(fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Cancel Button
                  KoalaButton(
                    text: 'Annuler',
                    onPressed: () {
                      _cancelToken?.cancel('Cancelled by user');
                      Get.back(); // Close dialog
                    },
                    backgroundColor: Colors.transparent,
                    textColor: KoalaColors.destructive,
                    icon: Icons.close_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // 4. Resumable Download
      try {
        await _dio.download(
          apkUrl,
          filePath,
          cancelToken: _cancelToken,
          deleteOnError: false, // Keep partial file for resume
          options: Options(
            receiveTimeout: const Duration(minutes: 10), // Longer timeout
            sendTimeout: const Duration(seconds: 30),
            headers: downloadedBytes > 0
                ? {'range': 'bytes=$downloadedBytes-'} // Resume header
                : null,
          ),
          onReceiveProgress: (rec, total) {
            if (total != -1) {
              final totalBytes = total + downloadedBytes;
              final currentBytes = rec + downloadedBytes;
              progress.value = currentBytes / totalBytes;
              progressText.value = '${(progress.value * 100).toInt()}%';
            }
          },
        );
      } catch (e) {
        if (e is DioException && CancelToken.isCancel(e)) {
          // User cancelled, do nothing (dialog already closed)
          return;
        }
        Get.back(); // Close loading dialog on error
        rethrow;
      }

      Get.back(); // Close loading dialog success

      downloadedFile = file;

      // 5. Verify Checksum (Optional)
      if (expectedChecksum != null &&
          expectedChecksum.isNotEmpty &&
          expectedChecksum != 'REPLACE_WITH_ACTUAL_SHA256_CHECKSUM') {
        final fileBytes = await file.readAsBytes();
        final actualChecksum = sha256.convert(fileBytes).toString();

        if (actualChecksum.toLowerCase() != expectedChecksum.toLowerCase()) {
          await file.delete();
          Get.snackbar('Erreur de sécurité',
              'Le fichier téléchargé est corrompu ou invalide.',
              backgroundColor: KoalaColors.destructive.withValues(alpha: 0.1),
              colorText: KoalaColors.destructive,
              duration: const Duration(seconds: 5));
          return;
        }
      }

      // 6. Prompt Install
      Get.dialog(
        KoalaConfirmationDialog(
          title: 'Installation',
          message:
              'Le téléchargement est terminé. Voulez-vous installer la mise à jour maintenant ?',
          confirmText: 'Installer',
          onConfirm: () async {
            final result = await OpenFile.open(filePath);
            if (result.type != ResultType.done) {
              Get.snackbar('Erreur',
                  'Impossible de lancer l\'installation: ${result.message}');
            }
          },
        ),
      );
    } catch (e) {
      if (downloadedFile != null && await downloadedFile.exists()) {
        // Only delete if it's NOT a user cancellation (to allow resume later)
        if (e is! DioException || !CancelToken.isCancel(e)) {
          // await downloadedFile.delete(); // Don't delete, keep for retry!
        }
      }
      // Ensure wakelock is disabled
      WakelockPlus.disable();

      Get.closeAllSnackbars();
      Get.snackbar(
          'Erreur', 'Échec du téléchargement. Réessayez pour reprendre.');
    } finally {
      // ALWAYS disable wakelock
      WakelockPlus.disable();
    }
  }
}
