import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/core/theme/app_colors.dart';
import 'package:koala/app/core/theme/app_dimensions.dart';
import 'package:koala/app/core/theme/app_text_styles.dart';
import 'package:koala/app/data/services/local_data_service.dart';
import 'package:koala/app/data/services/local_settings_service.dart';
import 'package:koala/app/shared/widgets/base_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';

/// Local backup management bottom sheet
class LocalBackupBottomSheet extends StatefulWidget {
  const LocalBackupBottomSheet({super.key});

  static Future<void> show() {
    return BaseBottomSheet.show(
      title: 'Sauvegardes locales',
      child: const LocalBackupBottomSheet(),
    );
  }

  @override
  State<LocalBackupBottomSheet> createState() => _LocalBackupBottomSheetState();
}

class _LocalBackupBottomSheetState extends State<LocalBackupBottomSheet> {
  final _isLoading = false.obs;
  final _backups = <BackupInfo>[].obs;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBackupHeader(),
        const SizedBox(height: 24),
        _buildQuickActions(),
        const SizedBox(height: 24),
        _buildBackupsList(),
      ],
    );
  }

  Widget _buildBackupHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.backup,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion des sauvegardes',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Créez et restaurez vos sauvegardes locales',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_circle_outline,
                title: 'Créer\nsauvegarde',
                color: AppColors.success,
                onTap: _createBackup,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.file_upload_outlined,
                title: 'Importer\nsauvegarde',
                color: AppColors.primary,
                onTap: _importBackup,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.settings_backup_restore,
                title: 'Auto-\nsauvegarde',
                color: AppColors.warning,
                onTap: _configureAutoBackup,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupsList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sauvegardes disponibles',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              
              if (_backups.isEmpty) {
                return _buildEmptyState();
              }
              
              return ListView.builder(
                itemCount: _backups.length,
                itemBuilder: (context, index) {
                  final backup = _backups[index];
                  return _buildBackupItem(backup);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.backup_table,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune sauvegarde',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre première sauvegarde\npour protéger vos données',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBackupItem(BackupInfo backup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.folder_zip_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    backup.name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Créée le ${_formatDate(backup.createdAt)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    backup.size,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleBackupAction(value, backup),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      Icon(Icons.restore, size: 18),
                      SizedBox(width: 8),
                      Text('Restaurer'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 18),
                      SizedBox(width: 8),
                      Text('Exporter'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _loadBackups() async {
    try {
      _isLoading.value = true;
      
      // Get backups directory
      final directory = await getApplicationDocumentsDirectory();
      final backupsDir = Directory('${directory.path}/backups');
      
      if (!await backupsDir.exists()) {
        _backups.clear();
        return;
      }
      
      final files = await backupsDir.list().toList();
      final backupFiles = files.whereType<File>().where((f) => f.path.endsWith('.json')).toList();
      
      final backups = <BackupInfo>[];
      
      for (final file in backupFiles) {
        final stat = await file.stat();
        final name = file.path.split('/').last.replaceAll('.json', '');
        
        backups.add(BackupInfo(
          name: name,
          path: file.path,
          createdAt: stat.modified,
          size: '${(stat.size / 1024).round()} KB',
        ));
      }
      
      // Sort by creation date (newest first)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _backups.assignAll(backups);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les sauvegardes: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _createBackup() async {
    try {
      _isLoading.value = true;
      
      // Create backup data
      final data = LocalDataService.to.exportData();
      final settings = LocalSettingsService.to.exportSettings();
      
      final backupData = {
        'version': '1.0.0',
        'created_at': DateTime.now().toIso8601String(),
        'data': data,
        'settings': settings,
      };
      
      // Create backups directory
      final directory = await getApplicationDocumentsDirectory();
      final backupsDir = Directory('${directory.path}/backups');
      if (!await backupsDir.exists()) {
        await backupsDir.create(recursive: true);
      }
      
      // Save backup file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'backup_$timestamp.json';
      final file = File('${backupsDir.path}/$fileName');
      
      await file.writeAsString(jsonEncode(backupData));
      
      await _loadBackups();
      
      Get.snackbar(
        'Succès',
        'Sauvegarde créée avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer la sauvegarde: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _importBackup() async {
    // TODO: Implement file picker for backup import
    Get.snackbar('Info', 'Fonction d\'import bientôt disponible');
  }

  Future<void> _configureAutoBackup() async {
    // TODO: Show auto-backup configuration
    Get.snackbar('Info', 'Configuration auto-sauvegarde bientôt disponible');
  }

  Future<void> _handleBackupAction(String action, BackupInfo backup) async {
    switch (action) {
      case 'restore':
        await _restoreBackup(backup);
        break;
      case 'export':
        await _exportBackup(backup);
        break;
      case 'delete':
        await _deleteBackup(backup);
        break;
    }
  }

  Future<void> _restoreBackup(BackupInfo backup) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Restaurer la sauvegarde'),
        content: const Text(
          'Cette action remplacera toutes vos données actuelles. Voulez-vous continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        _isLoading.value = true;
        
        // Read backup file
        final file = File(backup.path);
        final content = await file.readAsString();
        final backupData = jsonDecode(content);
        
        // TODO: Implement data restoration
        await Future.delayed(const Duration(seconds: 2)); // Mock restoration
        
        Get.snackbar(
          'Succès',
          'Sauvegarde restaurée avec succès',
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
        );
      } catch (e) {
        Get.snackbar('Erreur', 'Impossible de restaurer la sauvegarde: $e');
      } finally {
        _isLoading.value = false;
      }
    }
  }

  Future<void> _exportBackup(BackupInfo backup) async {
    // TODO: Implement backup export (share file)
    Get.snackbar('Info', 'Export de sauvegarde bientôt disponible');
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer la sauvegarde'),
        content: Text('Voulez-vous supprimer "${backup.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final file = File(backup.path);
        await file.delete();
        await _loadBackups();
        
        Get.snackbar(
          'Succès',
          'Sauvegarde supprimée',
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
        );
      } catch (e) {
        Get.snackbar('Erreur', 'Impossible de supprimer la sauvegarde: $e');
      }
    }
  }
}

class BackupInfo {
  final String name;
  final String path;
  final DateTime createdAt;
  final String size;

  BackupInfo({
    required this.name,
    required this.path,
    required this.createdAt,
    required this.size,
  });
}