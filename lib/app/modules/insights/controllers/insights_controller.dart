import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InsightsController extends GetxController {
  final currentTab = 0.obs;
  final selectedTimeframe = 'Cette semaine'.obs;
  final totalSpent = 125000.0.obs;
  final budgetLimit = 150000.0.obs;
  final savingsGoal = 200000.0.obs;
  final currentSavings = 75000.0.obs;

  final categorySpending = <Map<String, dynamic>>[].obs;
  final insights = <Map<String, dynamic>>[].obs;
  final spendingTrends = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInsights();
  }

  void _loadInsights() {
    categorySpending.assignAll([
      {
        'category': 'Alimentation',
        'amount': 45000.0,
        'percentage': 0.36,
        'icon': Icons.restaurant,
        'trend': 'up',
        'previousAmount': 42000.0,
      },
      {
        'category': 'Transport',
        'amount': 25000.0,
        'percentage': 0.20,
        'icon': Icons.directions_car,
        'trend': 'down',
        'previousAmount': 28000.0,
      },
      {
        'category': 'Divertissement',
        'amount': 35000.0,
        'percentage': 0.28,
        'icon': Icons.movie,
        'trend': 'up',
        'previousAmount': 30000.0,
      },
      {
        'category': 'Factures',
        'amount': 20000.0,
        'percentage': 0.16,
        'icon': Icons.receipt,
        'trend': 'stable',
        'previousAmount': 20000.0,
      },
    ]);

    insights.assignAll([
      {
        'type': 'warning',
        'title': 'Dépenses en hausse',
        'description':
            'Vos dépenses alimentaires ont augmenté de 7% cette semaine',
        'amount': 3000.0,
        'icon': Icons.trending_up,
        'priority': 'high',
        'suggestions': [
          'Planifiez vos repas à l\'avance',
          'Utilisez une liste de courses',
          'Cuisinez plus à la maison',
        ],
      },
      {
        'type': 'success',
        'title': 'Économies sur transport',
        'description':
            'Vous avez économisé 3,000 XOF en transport cette semaine',
        'amount': 3000.0,
        'icon': Icons.trending_down,
        'priority': 'medium',
        'suggestions': [
          'Continuez à utiliser les transports en commun',
          'Considérez le covoiturage',
        ],
      },
      {
        'type': 'info',
        'title': 'Objectif d\'épargne',
        'description': 'Vous êtes à 37.5% de votre objectif mensuel',
        'amount': 0.0,
        'icon': Icons.savings,
        'priority': 'medium',
        'suggestions': [
          'Réduisez les dépenses non essentielles',
          'Définissez un budget strict',
          'Automatisez vos épargnes',
        ],
      },
    ]);

    spendingTrends.assignAll([
      {'day': 'Lun', 'amount': 18000.0},
      {'day': 'Mar', 'amount': 22000.0},
      {'day': 'Mer', 'amount': 15000.0},
      {'day': 'Jeu', 'amount': 28000.0},
      {'day': 'Ven', 'amount': 35000.0},
      {'day': 'Sam', 'amount': 45000.0},
      {'day': 'Dim', 'amount': 25000.0},
    ]);
  }

  void changeTab(int index) {
    currentTab.value = index;
  }

  void changeTimeframe(String timeframe) {
    selectedTimeframe.value = timeframe;
    _loadInsights(); // Reload data for new timeframe
  }

  double get budgetUsagePercentage => totalSpent.value / budgetLimit.value;
  double get savingsPercentage => currentSavings.value / savingsGoal.value;
}
