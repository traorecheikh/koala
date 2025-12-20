import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/services/backup_service.dart';
import 'package:koaa/app/modules/settings/widgets/reset_app_sheet.dart';

class DataManagementView extends StatefulWidget {
  const DataManagementView({super.key});

  @override
  State<DataManagementView> createState() => _DataManagementViewState();
}

class _DataManagementViewState extends State<DataManagementView> {
  final _backupService = Get.put(BackupService());
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: KoalaColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: KoalaColors.text(context),
          ),
          onPressed: () => NavigationHelper.safeBack(),
        ),
        title: Text(
          'Gestion des données',
          style: KoalaTypography.heading3(context),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(20),
              children: [
                _buildInfoCard(context),
                SizedBox(height: 24),
                _buildSectionHeader(context, 'SAUVEGARDE & RESTAURATION'),
                SizedBox(height: 12),
                _buildBackupItem(
                  context,
                  icon: CupertinoIcons.cloud_upload_fill,
                  title: 'Créer une sauvegarde',
                  subtitle:
                      'Exportez vos données dans un fichier sécurisé (.koala).',
                  color: KoalaColors.primaryUi(context),
                  onTap: () => _showPasswordDialog(context, isExport: true),
                ),
                SizedBox(height: 16),
                _buildBackupItem(
                  context,
                  icon: CupertinoIcons.cloud_download_fill,
                  title: 'Restaurer une sauvegarde',
                  subtitle:
                      'Restaurer vos données depuis un fichier. ATTENTION: Ceci écrasera les données actuelles.',
                  color: KoalaColors.accent,
                  onTap: () => _showPasswordDialog(context, isExport: false),
                ),
                SizedBox(height: 32),
                _buildSectionHeader(context, 'ZONE DE DANGER'),
                SizedBox(height: 12),
                _buildBackupItem(
                  context,
                  icon: CupertinoIcons.trash_fill,
                  title: 'Réinitialiser l\'application',
                  subtitle:
                      'Effacer toutes les données et recommencer à zéro. Irréversible.',
                  color: KoalaColors.destructive,
                  isDestructive: true,
                  onTap: () => showResetAppSheet(context),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KoalaColors.primaryUi(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KoalaRadius.lg),
        border: Border.all(
            color: KoalaColors.primaryUi(context).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.info_circle_fill,
              color: KoalaColors.primaryUi(context)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Vos sauvegardes sont chiffrées. Vous devez définir un mot de passe pour chaque sauvegarde et vous en souvenir pour la restaurer.',
              style: KoalaTypography.caption(context)
                  .copyWith(color: KoalaColors.text(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: KoalaTypography.caption(context).copyWith(
        fontWeight: FontWeight.bold,
        color: KoalaColors.textSecondary(context),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildBackupItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KoalaRadius.lg),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KoalaColors.surface(context),
            borderRadius: BorderRadius.circular(KoalaRadius.lg),
            border: Border.all(
                color: isDestructive
                    ? KoalaColors.destructive.withOpacity(0.3)
                    : KoalaColors.border(context)),
            boxShadow: KoalaShadows.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: KoalaTypography.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDestructive ? KoalaColors.destructive : null,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: KoalaTypography.caption(context).copyWith(
                        color: KoalaColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_right,
                  color: KoalaColors.textSecondary(context), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, {required bool isExport}) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        backgroundColor: KoalaColors.surface(context),
        title: Text(isExport
            ? 'Sécuriser la sauvegarde'
            : 'Déverrouiller la sauvegarde'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isExport
                    ? 'Entrez un mot de passe pour chiffrer ce fichier.'
                    : 'Entrez le mot de passe utilisé lors de la création de la sauvegarde.',
                style: KoalaTypography.bodySmall(context),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(CupertinoIcons.lock),
                ),
                validator: (v) => v!.length < 4 ? 'Trop court (min 4)' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler',
                style: TextStyle(color: KoalaColors.textSecondary(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: KoalaColors.primaryUi(context),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Get.back();
                _handleAction(isExport, passwordController.text);
              }
            },
            child: Text('Continuer'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(bool isExport, String password) async {
    setState(() => _isLoading = true);

    try {
      if (isExport) {
        await _backupService.createBackup(password);
        Get.snackbar(
          'Succès',
          'Sauvegarde créée et prête à être partagée.',
          backgroundColor: KoalaColors.success,
          colorText: Colors.white,
        );
      } else {
        await _showRestoreWarning(password);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: KoalaColors.destructive,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showRestoreWarning(String password) async {
    // Double confirmation for restore
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: KoalaColors.surface(context),
        title: Row(
          children: [
            Icon(CupertinoIcons.exclamationmark_triangle_fill,
                color: KoalaColors.destructive),
            SizedBox(width: 8),
            Text('Attention !'),
          ],
        ),
        content: Text(
          'Cette action effacera TOUTES les données actuelles de l\'application pour les remplacer par celles de la sauvegarde.\n\nL\'application redémarrera automatiquement.\n\nÊtes-vous sûr ?',
          style: KoalaTypography.bodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'RESTAURER',
              style: TextStyle(
                  color: KoalaColors.destructive, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _backupService.restoreBackup(password);
    }
  }
}
