import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:koaa/app/core/design_system.dart';

/// Simple changelog service for version tracking and what's new popup
class ChangelogService {
  static const String _boxName = 'app_settings';
  static const String _lastSeenVersionKey = 'last_seen_version';

  static String currentVersion = '1.7.2';
  static String currentBuildNumber = '1';

  /// Changelog entries - simple text only
  static const Map<String, List<String>> changelog = {
    '1.7.2': [
      '• Correctif critique "Data Rescue" pour anciens utilisateurs',
      '• Stabilisation et sécurisation des sauvegardes',
    ],
    '1.7.0': [
      '• Migration sécurisée des données (Jobs/Dettes)',
      '• Correctif critique "Data Rescue" pour anciens utilisateurs',
      '• Retour du bouton "Ajouter" pour les Emplois',
      '• Stabilisation et sécurisation des sauvegardes',
    ],
    '1.3.5': [
      '• Nouvel écran de démarrage minimaliste "Apple-style"',
      '• Animations 3D du logo',
      '• Amélioration des performances de démarrage',
      '• Notifications intelligentes enrichies',
    ],
    '1.3.2': [
      '• Correction de l\'affichage des descriptions longues',
      '• Amélioration de la lisibilité dans l\'historique',
    ],
    '1.3.1': [
      '• Amélioration de l\'intelligence artificielle',
      '• Prédictions plus souples (plage de confiance)',
      '• Meilleure reconnaissance des habitudes',
    ],
    '1.3.0': [
      '• Refonte complète des animations',
      '• Animations fluides pour les listes et cartes',
      '• Micro-interactions pour les boutons',
      '• Nouvelles animations dans les paramètres',
    ],
    '1.2.0': [
      '• Nouveau tracker d\'abonnements avec logos',
      '• 7 widgets Android pour l\'ecran d\'accueil',
      '• Systeme de changelog et nouveautes',
      '• Corrections du mode sombre',
      '• Ameliorations de performance',
    ],
    '1.1.0': [
      '• Defis financiers et badges',
      '• Profils financiers IA',
      '• Rattrapage des depenses initiales',
    ],
    '1.0.4': [
      '• Ameliorations de performance',
      '• Corrections du mode sombre',
    ],
    '1.0.0': [
      '• Lancement initial de Koala',
      '• Suivi des transactions',
      '• Budgets et objectifs',
      '• Gestion des dettes',
    ],
  };

  /// Initialize with real app version from package_info_plus
  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      currentVersion = info.version;
      currentBuildNumber = info.buildNumber;
    } catch (_) {
      // Fallback to hardcoded version
    }
  }

  /// Check if we should show what's new popup
  static Future<bool> shouldShowWhatsNew() async {
    try {
      final box = await Hive.openBox(_boxName);
      final lastSeen = box.get(_lastSeenVersionKey) as String?;
      return lastSeen != currentVersion;
    } catch (_) {
      return false;
    }
  }

  /// Mark current version as seen
  static Future<void> markVersionSeen() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_lastSeenVersionKey, currentVersion);
    } catch (_) {}
  }

  /// Show what's new popup if version changed
  static Future<void> showWhatsNewIfNeeded(BuildContext context) async {
    if (await shouldShowWhatsNew()) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (context.mounted) {
        showWhatsNewDialog(context);
      }
    }
  }

  /// Show the what's new dialog - simple text, no fancy cards
  static void showWhatsNewDialog(BuildContext context) {
    final changes = changelog[currentVersion] ?? [];

    Get.dialog(
      Dialog(
        backgroundColor: KoalaColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    CupertinoIcons.sparkles,
                    color: KoalaColors.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Nouveautés v$currentVersion',
                    style: KoalaTypography.heading3(context),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Changes list - simple text
              ...changes.map((change) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text(
                      change,
                      style: KoalaTypography.bodyMedium(context).copyWith(
                        height: 1.4,
                      ),
                    ),
                  )),

              SizedBox(height: 20.h),

              // OK button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    markVersionSeen();
                    Get.back();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: KoalaColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'C\'est noté !',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Get formatted version string
  static String get versionString => 'v$currentVersion ($currentBuildNumber)';
}
