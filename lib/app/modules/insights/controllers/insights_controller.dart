import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller for managing AI insights and recommendations
class InsightsController extends GetxController {
  // Text controllers
  final TextEditingController questionController = TextEditingController();

  // Observable state
  final RxBool isGeneratingInsight = false.obs;
  final RxList<dynamic> insights = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInsights();
  }

  @override
  void onClose() {
    questionController.dispose();
    super.onClose();
  }

  /// Load existing insights
  Future<void> loadInsights() async {
    try {
      // TODO: Load insights from storage
      await Future.delayed(const Duration(milliseconds: 300));
      // Mock insights for now
      insights.clear();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les insights');
    }
  }

  /// Generate new insight from AI
  Future<void> generateInsight() async {
    if (questionController.text.trim().isEmpty) {
      Get.snackbar('Attention', 'Veuillez poser une question');
      return;
    }

    try {
      isGeneratingInsight.value = true;

      // TODO: Implement AI insight generation
      await Future.delayed(const Duration(seconds: 2));

      // Mock insight response
      final mockInsight = MockInsight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Optimisation des dépenses',
        description:
            'Basé sur votre historique, vous pouvez économiser 15% en réduisant les sorties restaurant.',
        priority: 'high',
        potentialSavings: 75000,
        steps: [
          'Limitez les restaurants à 2 fois par semaine',
          'Préparez vos repas à la maison',
          'Utilisez une liste de courses pour éviter les achats impulsifs',
        ],
      );

      insights.insert(0, mockInsight);
      questionController.clear();
      Get.snackbar('Succès', 'Nouvel insight généré!');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de générer l\'insight');
    } finally {
      isGeneratingInsight.value = false;
    }
  }

  /// Apply an insight recommendation
  void applyInsight(String insightId) {
    // TODO: Implement insight application logic
    Get.snackbar('Info', 'Fonctionnalité en développement');
  }

  /// Dismiss an insight
  void dismissInsight(String insightId) {
    insights.removeWhere((insight) => insight.id == insightId);
    Get.snackbar('Info', 'Insight ignoré');
  }
}

/// Mock insight model for demonstration
class MockInsight {
  final String id;
  final String title;
  final String description;
  final String priority;
  final double potentialSavings;
  final List<String> steps;

  MockInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.potentialSavings,
    required this.steps,
  });
}
