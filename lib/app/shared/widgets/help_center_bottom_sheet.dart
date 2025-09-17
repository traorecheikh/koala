import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/core/theme/app_colors.dart';
import 'package:koala/app/core/theme/app_dimensions.dart';
import 'package:koala/app/core/theme/app_text_styles.dart';
import 'package:koala/app/shared/widgets/base_bottom_sheet.dart';

/// Help center bottom sheet with FAQ and support options
class HelpCenterBottomSheet extends StatefulWidget {
  const HelpCenterBottomSheet({super.key});

  static Future<void> show() {
    return BaseBottomSheet.show(
      title: 'Centre d\'aide',
      child: const HelpCenterBottomSheet(),
    );
  }

  @override
  State<HelpCenterBottomSheet> createState() => _HelpCenterBottomSheetState();
}

class _HelpCenterBottomSheetState extends State<HelpCenterBottomSheet> {
  final _searchController = TextEditingController();
  final _filteredFaqs = <HelpItem>[].obs;
  final _expandedItems = <int>{}.obs;

  final List<HelpItem> _allFaqs = [
    HelpItem(
      category: 'Premiers pas',
      question: 'Comment créer mon compte Koala ?',
      answer: 'Pour créer votre compte, suivez ces étapes :\n\n1. Ouvrez l\'application Koala\n2. Appuyez sur "Commencer"\n3. Renseignez vos informations personnelles\n4. Définissez votre salaire et solde initial\n5. Créez un code PIN sécurisé\n6. Activez l\'authentification biométrique (optionnel)',
      icon: Icons.account_circle_outlined,
    ),
    HelpItem(
      category: 'Premiers pas',
      question: 'Comment configurer mon profil financier ?',
      answer: 'Dans les paramètres, allez dans "Informations financières" pour configurer :\n\n• Votre salaire mensuel\n• Votre solde initial\n• Votre date de paie\n• Vos comptes (cash, mobile money, etc.)',
      icon: Icons.account_balance_wallet_outlined,
    ),
    HelpItem(
      category: 'Transactions',
      question: 'Comment ajouter une transaction ?',
      answer: 'Pour ajouter une transaction :\n\n1. Appuyez sur le bouton "+" sur l\'écran principal\n2. Choisissez le type (dépense, revenu, transfert, etc.)\n3. Saisissez le montant\n4. Ajoutez une description\n5. Sélectionnez la catégorie\n6. Confirmez la transaction',
      icon: Icons.add_circle_outline,
    ),
    HelpItem(
      category: 'Transactions',
      question: 'Comment modifier ou supprimer une transaction ?',
      answer: 'Pour modifier une transaction :\n\n1. Trouvez la transaction dans la liste\n2. Appuyez longuement dessus\n3. Choisissez "Modifier" ou "Supprimer"\n4. Confirmez votre choix\n\nNote : La suppression est définitive',
      icon: Icons.edit_outlined,
    ),
    HelpItem(
      category: 'IA - Koa',
      question: 'Comment utiliser l\'assistant IA Koa ?',
      answer: 'Koa est votre assistant financier intelligent :\n\n• Posez des questions sur vos finances\n• Demandez des conseils d\'épargne\n• Obtenez des analyses de vos dépenses\n• Recevez des suggestions personnalisées\n\nToutes les données restent locales sur votre appareil.',
      icon: Icons.smart_toy_outlined,
    ),
    HelpItem(
      category: 'IA - Koa',
      question: 'Koa peut-il voir toutes mes données ?',
      answer: 'Koa traite vos données localement :\n\n✅ Vos données restent sur votre appareil\n✅ Aucune information n\'est envoyée à des serveurs externes\n✅ Vous contrôlez totalement vos données\n✅ Chiffrement AES-256 de toutes les données sensibles',
      icon: Icons.privacy_tip_outlined,
    ),
    HelpItem(
      category: 'Sécurité',
      question: 'Comment sécuriser mon compte ?',
      answer: 'Pour sécuriser votre compte :\n\n• Utilisez un code PIN unique et complexe\n• Activez l\'authentification biométrique\n• Ne partagez jamais vos codes d\'accès\n• Gardez l\'application à jour\n• Sauvegardez régulièrement vos données',
      icon: Icons.security_outlined,
    ),
    HelpItem(
      category: 'Sécurité',
      question: 'Que faire si j\'oublie mon code PIN ?',
      answer: 'Si vous oubliez votre code PIN :\n\n1. Utilisez l\'authentification biométrique si activée\n2. Sinon, vous devrez réinitialiser l\'application\n3. Restaurez vos données depuis une sauvegarde\n4. Reconfigurez votre profil\n\nC\'est pourquoi les sauvegardes sont importantes !',
      icon: Icons.lock_reset_outlined,
    ),
    HelpItem(
      category: 'Données',
      question: 'Comment sauvegarder mes données ?',
      answer: 'Plusieurs options de sauvegarde :\n\n• Sauvegarde locale automatique\n• Synchronisation cloud (optionnelle)\n• Export manuel de vos données\n\nAllez dans Paramètres > Sauvegardes locales pour configurer.',
      icon: Icons.backup_outlined,
    ),
    HelpItem(
      category: 'Données',
      question: 'L\'app fonctionne-t-elle hors ligne ?',
      answer: 'Oui ! Koala est conçu pour fonctionner hors ligne :\n\n✅ Toutes les fonctionnalités disponibles sans internet\n✅ Données stockées localement\n✅ Synchronisation en arrière-plan quand connecté\n✅ Aucune dépendance au réseau pour l\'utilisation quotidienne',
      icon: Icons.offline_bolt_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredFaqs.assignAll(_allFaqs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFaqs(String query) {
    if (query.isEmpty) {
      _filteredFaqs.assignAll(_allFaqs);
    } else {
      _filteredFaqs.assignAll(_allFaqs.where((faq) =>
          faq.question.toLowerCase().contains(query.toLowerCase()) ||
          faq.answer.toLowerCase().contains(query.toLowerCase()) ||
          faq.category.toLowerCase().contains(query.toLowerCase())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 16),
        _buildQuickActions(),
        const SizedBox(height: 24),
        _buildFaqList(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Rechercher dans l\'aide...',
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      onChanged: _filterFaqs,
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
              child: _buildQuickActionCard(
                icon: Icons.message_outlined,
                title: 'Contacter\nle support',
                onTap: () {
                  Get.back();
                  // TODO: Open contact support
                  Get.snackbar('Support', 'Fonction bientôt disponible');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.video_library_outlined,
                title: 'Tutoriels\nvideo',
                onTap: () {
                  Get.back();
                  // TODO: Open video tutorials
                  Get.snackbar('Tutoriels', 'Fonction bientôt disponible');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.feedback_outlined,
                title: 'Envoyer un\ncommentaire',
                onTap: () {
                  Get.back();
                  // Open feedback bottom sheet
                  FeedbackBottomSheet.show();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions fréquentes',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: _filteredFaqs.length,
              itemBuilder: (context, index) {
                final faq = _filteredFaqs[index];
                final isExpanded = _expandedItems.contains(index);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (isExpanded) {
                        _expandedItems.remove(index);
                      } else {
                        _expandedItems.add(index);
                      }
                    },
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                faq.icon,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      faq.category,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      faq.question,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            Text(
                              faq.answer,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}

class HelpItem {
  final String category;
  final String question;
  final String answer;
  final IconData icon;

  HelpItem({
    required this.category,
    required this.question,
    required this.answer,
    required this.icon,
  });
}

/// Feedback bottom sheet
class FeedbackBottomSheet extends StatefulWidget {
  const FeedbackBottomSheet({super.key});

  static Future<void> show() {
    return BaseBottomSheet.show(
      title: 'Envoyer un commentaire',
      child: const FeedbackBottomSheet(),
    );
  }

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  final _feedbackController = TextEditingController();
  final _isLoading = false.obs;
  final _feedbackType = 'suggestion'.obs;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeedbackTypeSelector(),
        const SizedBox(height: 16),
        _buildFeedbackField(),
        const SizedBox(height: 24),
        _buildSendButton(),
      ],
    );
  }

  Widget _buildFeedbackTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de commentaire',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          children: [
            _buildTypeChip('suggestion', 'Suggestion', Icons.lightbulb_outline),
            _buildTypeChip('bug', 'Bug', Icons.bug_report_outlined),
            _buildTypeChip('feature', 'Nouvelle fonctionnalité', Icons.add_circle_outline),
            _buildTypeChip('other', 'Autre', Icons.more_horiz),
          ],
        )),
      ],
    );
  }

  Widget _buildTypeChip(String value, String label, IconData icon) {
    final isSelected = _feedbackType.value == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          _feedbackType.value = value;
        }
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildFeedbackField() {
    return TextField(
      controller: _feedbackController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'Décrivez votre commentaire...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading.value ? null : _sendFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: _isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Icon(Icons.send, size: 20),
        label: Text(_isLoading.value ? 'Envoi...' : 'Envoyer'),
      ),
    ));
  }

  Future<void> _sendFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      Get.snackbar('Erreur', 'Veuillez saisir votre commentaire');
      return;
    }

    try {
      _isLoading.value = true;
      
      // Simulate sending feedback
      await Future.delayed(const Duration(seconds: 2));
      
      Get.back();
      Get.snackbar(
        'Merci !',
        'Votre commentaire a été envoyé avec succès',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'envoyer le commentaire');
    } finally {
      _isLoading.value = false;
    }
  }
}