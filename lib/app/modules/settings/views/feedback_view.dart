import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koala/app/core/theme/app_colors.dart';
import 'package:koala/app/core/theme/app_dimensions.dart';
import 'package:koala/app/core/theme/app_text_styles.dart';

/// Feedback view
class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Envoyer un commentaire'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeedbackTypeSelector(),
            const SizedBox(height: 16),
            _buildFeedbackField(),
            const SizedBox(height: 24),
            _buildSendButton(),
          ],
        ),
      ),
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
    return Expanded(
      child: TextField(
        controller: _feedbackController,
        maxLines: null,
        expands: true,
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
          contentPadding: const EdgeInsets.all(AppSpacing.md),
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