import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/core/theme/app_colors.dart';
import 'package:koala/app/core/theme/app_dimensions.dart';
import 'package:koala/app/core/theme/app_text_styles.dart';

/// Help center view with FAQ and support options
class HelpView extends StatefulWidget {
  const HelpView({super.key});

  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> {
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
      category: 'Transactions',
      question: 'Comment ajouter une transaction ?',
      answer: 'Pour ajouter une transaction :\n\n1. Appuyez sur le bouton "+" sur l\'écran principal\n2. Choisissez le type (dépense, revenu, transfert, etc.)\n3. Saisissez le montant\n4. Ajoutez une description\n5. Sélectionnez la catégorie\n6. Confirmez la transaction',
      icon: Icons.add_circle_outline,
    ),
    HelpItem(
      category: 'IA - Koa',
      question: 'Comment utiliser l\'assistant IA Koa ?',
      answer: 'Koa est votre assistant financier intelligent :\n\n• Posez des questions sur vos finances\n• Demandez des conseils d\'épargne\n• Obtenez des analyses de vos dépenses\n• Recevez des suggestions personnalisées\n\nToutes les données restent locales sur votre appareil.',
      icon: Icons.smart_toy_outlined,
    ),
    HelpItem(
      category: 'Sécurité',
      question: 'Comment sécuriser mon compte ?',
      answer: 'Pour sécuriser votre compte :\n\n• Utilisez un code PIN unique et complexe\n• Activez l\'authentification biométrique\n• Ne partagez jamais vos codes d\'accès\n• Gardez l\'application à jour\n• Sauvegardez régulièrement vos données',
      icon: Icons.security_outlined,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Centre d\'aide'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildFaqList(),
          ],
        ),
      ),
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
                  Get.toNamed('/feedback');
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