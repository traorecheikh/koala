import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:koala/app/data/models/transaction_model.dart';
import 'package:koala/app/data/services/local_data_service.dart';
import 'package:koala/app/data/services/local_settings_service.dart';
import 'package:koala/app/data/services/api_service.dart';

/// AI Assistant Koa - Intelligent financial insights and recommendations
/// Works offline with local data analysis and online with real AI API
class KoaAiService extends GetxService {
  static KoaAiService get to => Get.find();

  // Conversation history
  final RxList<AiMessage> conversationHistory = <AiMessage>[].obs;
  final RxBool isThinking = false.obs;
  final RxBool isOnline = false.obs;

  /// Initialize the service for async dependency injection
  Future<KoaAiService> init() async {
    _initializeKoa();
    _checkOnlineStatus();
    return this;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeKoa();
    _checkOnlineStatus();
  }

  /// Check if we have internet connectivity for AI API calls
  Future<void> _checkOnlineStatus() async {
    try {
      // Simple connectivity check - you could use connectivity_plus package for more robust checking
      isOnline.value = true; // For now assume online, implement proper check if needed
    } catch (e) {
      isOnline.value = false;
    }
  }

  /// Initialize Koa with welcome message
  void _initializeKoa() {
    final user = LocalDataService.to.getCurrentUser();
    final userName = user?.name.split(' ').first ?? 'utilisateur';
    
    conversationHistory.add(AiMessage(
      text: 'Bonjour $userName ! 👋\n\nJe suis Koa, votre assistant financier personnel. Je peux vous aider à :\n\n• Analyser vos dépenses\n• Suggérer des économies\n• Répondre à vos questions financières\n• Créer des budgets personnalisés\n\n${isOnline.value ? "Je suis connecté à l'IA avancée pour des conseils personnalisés." : "Je fonctionne en mode hors ligne avec vos données locales."}\n\nComment puis-je vous aider aujourd\'hui ?',
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: AiMessageType.welcome,
    ));
  }

  /// Process user query and generate AI response
  Future<void> processUserQuery(String userQuery) async {
    if (userQuery.trim().isEmpty) return;

    // Add user message
    conversationHistory.add(AiMessage(
      text: userQuery,
      isFromUser: true,
      timestamp: DateTime.now(),
      messageType: AiMessageType.text,
    ));

    try {
      isThinking.value = true;
      
      // Check if we should use online AI or offline responses
      if (isOnline.value && LocalSettingsService.to.isCloudSyncEnabled) {
        await _getOnlineAiResponse(userQuery);
      } else {
        await _getOfflineResponse(userQuery);
      }
    } catch (e) {
      // Fallback to offline if online fails
      await _getOfflineResponse(userQuery);
    } finally {
      isThinking.value = false;
    }
  }

  /// Get response from online AI API (when connected)
  Future<void> _getOnlineAiResponse(String userQuery) async {
    try {
      // Build conversation history for context
      final history = conversationHistory.take(10).map((msg) => {
        'text': msg.text,
        'isUserMessage': msg.isFromUser,
      }).toList();

      // Call the real AI API endpoint from OpenAPI spec
      final response = await ApiService.getAiInsight(
        userQuery: userQuery,
        persona: 'insight',
        history: history,
      );

      // Process the AI response according to OpenAPI InsightResponse schema
      final suggestions = response['suggestions'] as List? ?? [];
      String responseText = '';

      if (suggestions.isNotEmpty) {
        responseText = '🤖 **Conseils IA personnalisés**\n\n';
        for (final suggestion in suggestions) {
          final title = suggestion['title'] ?? '';
          final savings = suggestion['estimated_monthly_saving'] ?? 0;
          final priority = suggestion['priority'] ?? 'normal';
          final steps = suggestion['steps'] as List? ?? [];
          
          responseText += '**$title**\n';
          if (savings > 0) {
            responseText += 'Économie estimée: ${savings.toStringAsFixed(0)} XOF/mois\n';
          }
          responseText += 'Priorité: $priority\n';
          if (steps.isNotEmpty) {
            responseText += 'Étapes:\n';
            for (final step in steps) {
              responseText += '• $step\n';
            }
          }
          responseText += '\n';
        }
      } else {
        responseText = 'Je traite votre demande et vais vous proposer des conseils personnalisés basés sur vos données financières.';
      }

      conversationHistory.add(AiMessage(
        text: responseText,
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: AiMessageType.analysis,
        data: response,
      ));
    } catch (e) {
      throw Exception('Erreur API IA: $e');
    }
  }

  /// Get offline response using local data analysis
  Future<void> _getOfflineResponse(String userQuery) async {
    // Simulate AI thinking time
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Generate response based on query type using local data
    final response = await _generateLocalResponse(userQuery);
    conversationHistory.add(response);
  }

  /// Generate AI response based on user query using local data
  Future<AiMessage> _generateLocalResponse(String query) async {
    final lowerQuery = query.toLowerCase();
    
    // Financial analysis queries
    if (lowerQuery.contains('dépense') || lowerQuery.contains('analyse') || lowerQuery.contains('spending')) {
      return await _generateSpendingAnalysis();
    }
    
    // Savings suggestions
    if (lowerQuery.contains('économie') || lowerQuery.contains('épargne') || lowerQuery.contains('save')) {
      return await _generateSavingsAdvice();
    }
    
    // Budget questions
    if (lowerQuery.contains('budget')) {
      return await _generateBudgetAdvice();
    }
    
    // Balance inquiry
    if (lowerQuery.contains('solde') || lowerQuery.contains('balance')) {
      return _generateBalanceInfo();
    }
    
    // Transaction help
    if (lowerQuery.contains('transaction') || lowerQuery.contains('ajouter')) {
      return _generateTransactionHelp();
    }
    
    // General financial advice
    if (lowerQuery.contains('conseil') || lowerQuery.contains('aide') || lowerQuery.contains('help')) {
      return _generateGeneralAdvice();
    }
    
    // Default response
    return _generateDefaultResponse(query);
  }

  /// Generate spending analysis
  Future<AiMessage> _generateSpendingAnalysis() async {
    final transactions = LocalDataService.to.transactions;
    final user = LocalDataService.to.getCurrentUser();
    
    if (transactions.isEmpty) {
      return AiMessage(
        text: '📊 **Analyse des dépenses**\n\nVous n\'avez pas encore enregistré de transactions. Commencez par ajouter quelques dépenses pour que je puisse analyser vos habitudes financières !',
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: AiMessageType.analysis,
      );
    }

    // Analyze last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentTransactions = transactions.where((t) => 
      t.date.isAfter(thirtyDaysAgo) && t.type == TransactionType.expense
    ).toList();

    final totalExpenses = recentTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final avgDaily = totalExpenses / 30;
    final salary = user?.monthlySalary ?? 0;
    final expenseRatio = salary > 0 ? (totalExpenses / salary * 100) : 0;

    // Category analysis
    final categoryExpenses = <String, double>{};
    for (final transaction in recentTransactions) {
      categoryExpenses[transaction.category] = 
        (categoryExpenses[transaction.category] ?? 0) + transaction.amount;
    }

    final topCategory = categoryExpenses.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return AiMessage(
      text: '📊 **Analyse des dépenses (30 derniers jours)**\n\n'
          '💰 **Total dépensé :** ${totalExpenses.toStringAsFixed(0)} XOF\n'
          '📅 **Moyenne quotidienne :** ${avgDaily.toStringAsFixed(0)} XOF\n'
          '📈 **% du salaire :** ${expenseRatio.toStringAsFixed(1)}%\n\n'
          '🏆 **Catégorie principale :** ${topCategory.key}\n'
          '💳 **Montant :** ${topCategory.value.toStringAsFixed(0)} XOF\n\n'
          '${_getSpendingInsight(expenseRatio)}',
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: AiMessageType.analysis,
      data: {
        'total_expenses': totalExpenses,
        'expense_ratio': expenseRatio,
        'top_category': topCategory.key,
      },
    );
  }

  /// Generate savings advice
  Future<AiMessage> _generateSavingsAdvice() async {
    final user = LocalDataService.to.getCurrentUser();
    final transactions = LocalDataService.to.transactions;
    
    if (user == null) {
      return AiMessage(
        text: '💡 **Conseils d\'épargne**\n\nVeuillez d\'abord configurer votre profil financier pour recevoir des conseils personnalisés !',
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: AiMessageType.advice,
      );
    }

    final salary = user.monthlySalary;
    final suggestedSavings = salary * 0.2; // 20% savings goal
    
    // Analyze spending patterns
    final recentExpenses = transactions.where((t) => 
      t.date.isAfter(DateTime.now().subtract(const Duration(days: 30))) &&
      t.type == TransactionType.expense
    ).fold(0.0, (sum, t) => sum + t.amount);

    final currentSavingsRate = salary > 0 ? ((salary - recentExpenses) / salary * 100) : 0;

    final suggestions = <String>[];
    
    // Generate personalized suggestions
    if (currentSavingsRate < 10) {
      suggestions.add('🎯 **Objectif immédiat :** Économisez au moins 10% de votre salaire (${(salary * 0.1).toStringAsFixed(0)} XOF/mois)');
      suggestions.add('💡 **Astuce :** Utilisez la règle 50/30/20 - 50% besoins, 30% loisirs, 20% épargne');
    } else if (currentSavingsRate < 20) {
      suggestions.add('👏 **Bravo !** Vous épargnez déjà ${currentSavingsRate.toStringAsFixed(1)}%. Objectif : 20%');
      suggestions.add('💪 **Défi :** Augmentez votre épargne de 50 XOF par semaine');
    } else {
      suggestions.add('🌟 **Excellent !** Votre taux d\'épargne de ${currentSavingsRate.toStringAsFixed(1)}% est exemplaire !');
      suggestions.add('🚀 **Évolution :** Considérez des investissements pour faire fructifier votre épargne');
    }

    // Add specific saving tips
    suggestions.add('🏠 **Transport :** Utilisez les transports en commun 2 jours/semaine → Économie ~15,000 XOF/mois');
    suggestions.add('🍽️ **Repas :** Préparez vos déjeuners 3 fois/semaine → Économie ~12,000 XOF/mois');
    suggestions.add('📱 **Abonnements :** Révisez vos forfaits téléphone/internet → Économie ~5,000 XOF/mois');

    return AiMessage(
      text: '💰 **Plan d\'épargne personnalisé**\n\n'
          '📊 **Taux d\'épargne actuel :** ${currentSavingsRate.toStringAsFixed(1)}%\n'
          '🎯 **Objectif recommandé :** ${suggestedSavings.toStringAsFixed(0)} XOF/mois\n\n'
          '**Suggestions personnalisées :**\n\n${suggestions.join('\n\n')}',
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: AiMessageType.advice,
      data: {
        'current_savings_rate': currentSavingsRate,
        'suggested_amount': suggestedSavings,
      },
    );
  }

  /// Generate budget advice
  Future<AiMessage> _generateBudgetAdvice() async {
    final user = LocalDataService.to.getCurrentUser();
    
    if (user == null) {
      return AiMessage(
        text: '📋 **Création de budget**\n\nPour créer un budget personnalisé, j\'ai besoin de vos informations financières. Rendez-vous dans Paramètres > Informations financières.',
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: AiMessageType.advice,
      );
    }

    final salary = user.monthlySalary;
    
    // 50/30/20 rule breakdown for Senegal context
    final needs = salary * 0.5;      // Essential expenses
    final wants = salary * 0.3;      // Lifestyle
    final savings = salary * 0.2;    // Savings & investments

    return AiMessage(
      text: '📋 **Budget recommandé (Règle 50/30/20)**\n\n'
          '💵 **Revenus mensuels :** ${salary.toStringAsFixed(0)} XOF\n\n'
          '🏠 **Besoins essentiels (50%) :** ${needs.toStringAsFixed(0)} XOF\n'
          '• Logement, transport, alimentation\n'
          '• Factures, assurances\n\n'
          '🎯 **Loisirs & lifestyle (30%) :** ${wants.toStringAsFixed(0)} XOF\n'
          '• Sorties, restaurants, shopping\n'
          '• Hobbies, divertissements\n\n'
          '💰 **Épargne & investissements (20%) :** ${savings.toStringAsFixed(0)} XOF\n'
          '• Épargne d\'urgence\n'
          '• Projets futurs\n\n'
          '💡 **Conseil Koa :** Commencez par suivre vos dépenses pendant 1 mois pour ajuster ce budget à votre réalité !',
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: AiMessageType.advice,
      data: {
        'needs_budget': needs,
        'wants_budget': wants,
        'savings_budget': savings,
      },
    );
  }

  /// Generate balance information
  AiMessage _generateBalanceInfo() {
    final user = LocalDataService.to.getCurrentUser();
    
    if (user == null) {
      return AiMessage(
        text: '💳 **Informations de solde**\n\nJe ne trouve pas vos informations de compte. Veuillez configurer votre profil financier !',
        isFromUser: false,
        timestamp: DateTime.now(),
        messageType: AiMessageType.info,
      );
    }

    final balance = user.currentBalance;
    final salary = user.monthlySalary;
    final daysUntilPayday = _getDaysUntilPayday(user.payDay);
    
    // Calculate daily budget until payday
    final dailyBudget = daysUntilPayday > 0 ? balance / daysUntilPayday : 0;

    String balanceStatus;
    String advice = '';
    
    if (balance < 0) {
      balanceStatus = '🔴 **Attention - Solde négatif**';
      advice = '\n\n⚠️ **Action requise :** Votre solde est négatif. Évitez les nouvelles dépenses non essentielles et cherchez des moyens de rééquilibrer rapidement votre budget.';
    } else if (balance < salary * 0.1) {
      balanceStatus = '🟡 **Solde faible**';
      advice = '\n\n💡 **Conseil :** Votre solde est bas. Limitez les dépenses aux besoins essentiels jusqu\'à votre prochaine paie.';
    } else {
      balanceStatus = '🟢 **Solde sain**';
      advice = '\n\n✨ **Bien joué !** Votre solde vous permet de tenir jusqu\'à la prochaine paie.';
    }

    return AiMessage(
      text: '💳 **État de votre solde**\n\n'
          '$balanceStatus\n'
          '💰 **Solde actuel :** ${balance.toStringAsFixed(0)} XOF\n'
          '📅 **Jours jusqu\'à la paie :** $daysUntilPayday jours\n'
          '💵 **Budget quotidien :** ${dailyBudget.toStringAsFixed(0)} XOF/jour'
          '$advice',
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: AiMessageType.info,
      data: {
        'balance': balance,
        'days_until_payday': daysUntilPayday,
        'daily_budget': dailyBudget,
      },
    );
  }

  /// Generate transaction help
  AiMessage _generateTransactionHelp() {
    return AiMessage(
      text: '📝 **Guide des transactions**\n\n'
          '**Comment ajouter une transaction :**\n'
          '1. Appuyez sur le bouton ➕ sur l\'écran principal\n'
          '2. Choisissez le type (dépense, revenu, transfert...)\n'
          '3. Saisissez le montant en XOF\n'
          '4. Ajoutez une description claire\n'
          '5. Sélectionnez une catégorie\n'
          '6. Confirmez ✅\n\n'
          '**Types de transactions disponibles :**\n'
          '• 💸 **Dépense :** Achats, factures, services\n'
          '• 💰 **Revenu :** Salaire, bonus, ventes\n'
          '• 🔄 **Transfert :** Entre comptes\n'
          '• 🏦 **Prêt :** Argent prêté ou emprunté\n'
          '• 📋 **Remboursement :** Paiement de dettes\n\n'
          '💡 **Astuce Koa :** Plus vous enregistrez de transactions, plus mes analyses seront précises !',
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: AiMessageType.help,
    );
  }

  /// Generate general financial advice
  AiMessage _generateGeneralAdvice() {
    final tips = [
      '💡 **Règle d\'or :** Payez-vous en premier ! Mettez de côté votre épargne dès que vous recevez votre salaire.',
      '📱 **Technologie :** Utilisez Koala quotidiennement pour suivre chaque dépense, même les plus petites.',
      '🎯 **Objectifs :** Fixez-vous des objectifs financiers clairs et mesurables (ex: épargner 100,000 XOF en 6 mois).',
      '⚡ **Urgences :** Constituez un fonds d\'urgence équivalent à 3-6 mois de dépenses.',
      '📊 **Révision :** Analysez vos finances chaque dimanche pour préparer la semaine.',
      '🛡️ **Protection :** Ne partagez jamais vos codes d\'accès financiers.',
    ];

    final randomTip = tips[Random().nextInt(tips.length)];

    return AiMessage(
      text: '🎓 **Conseil financier du jour**\n\n$randomTip\n\n'
          '**Autres sujets d\'aide disponibles :**\n'
          '• "Analyse mes dépenses" - Pour un bilan complet\n'
          '• "Conseils d\'épargne" - Pour économiser plus\n'
          '• "Mon budget" - Pour planifier vos finances\n'
          '• "Mon solde" - Pour l\'état de votre compte\n\n'
          'Que souhaitez-vous explorer ?',
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: AiMessageType.advice,
    );
  }

  /// Generate default response
  AiMessage _generateDefaultResponse(String query) {
    return AiMessage(
      text: '🤔 Je ne suis pas sûr de comprendre votre question sur "$query".\n\n'
          '**Je peux vous aider avec :**\n'
          '• 📊 Analyser vos dépenses\n'
          '• 💰 Suggérer des économies\n'
          '• 📋 Créer un budget\n'
          '• 💳 Vérifier votre solde\n'
          '• 📝 Gérer vos transactions\n\n'
          'Posez-moi une question plus spécifique ! Par exemple : "Analyse mes dépenses du mois" ou "Comment économiser plus ?"',
      isFromUser: false,
      timestamp: DateTime.now(),
      messageType: AiMessageType.help,
    );
  }

  /// Get spending insight based on expense ratio
  String _getSpendingInsight(double expenseRatio) {
    if (expenseRatio > 80) {
      return '🚨 **Alerte :** Vous dépensez plus de 80% de votre salaire ! Il est urgent de réduire vos dépenses.';
    } else if (expenseRatio > 60) {
      return '⚠️ **Attention :** 60% de votre salaire en dépenses. Essayez de réduire pour atteindre 50%.';
    } else if (expenseRatio > 50) {
      return '💡 **Conseil :** Vos dépenses sont raisonnables mais vous pourriez économiser plus.';
    } else {
      return '✅ **Excellent :** Votre gestion des dépenses est exemplaire ! Continuez ainsi.';
    }
  }

  /// Calculate days until next payday
  int _getDaysUntilPayday(int payDay) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, payDay);
    final nextMonth = DateTime(now.year, now.month + 1, payDay);
    
    final payday = now.isBefore(currentMonth) ? currentMonth : nextMonth;
    return payday.difference(now).inDays;
  }

  /// Clear conversation history
  void clearConversation() {
    conversationHistory.clear();
    _initializeKoa();
  }

  /// Export conversation for debugging
  Map<String, dynamic> exportConversation() {
    return {
      'messages': conversationHistory.map((m) => m.toJson()).toList(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }
}

/// AI Message model
class AiMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final AiMessageType messageType;
  final Map<String, dynamic>? data;

  AiMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    required this.messageType,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'is_from_user': isFromUser,
      'timestamp': timestamp.toIso8601String(),
      'message_type': messageType.toString(),
      'data': data,
    };
  }
}

/// AI Message types
enum AiMessageType {
  welcome,
  text,
  analysis,
  advice,
  info,
  help,
  error,
}