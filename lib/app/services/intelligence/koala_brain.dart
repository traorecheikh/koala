import 'dart:math';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/savings_goal.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';

part 'koala_brain.g.dart';

// Alias for RecurringTransaction's Frequency enum
typedef RecurringFrequency = Frequency;

/// The intelligent brain of Koala - learns, predicts, and coaches
class KoalaBrain {
  final Box<LocalTransaction> transactionsBox;
  final Box<Job> jobsBox;
  final Box<SavingsGoal> savingsBox;
  final Box<RecurringTransaction> recurringBox;
  final Box<CategoryPattern> patternsBox;
  final Box<UserBehavior> behaviorBox;

  // Caches
  CashFlowForecast? _cachedForecast;
  List<ProactiveAlert>? _cachedAlerts;
  Map<String, SmartBudget>? _cachedBudgets;
  DateTime? _lastAnalysis;

  KoalaBrain({
    required this.transactionsBox,
    required this.jobsBox,
    required this.savingsBox,
    required this.recurringBox,
    required this.patternsBox,
    required this.behaviorBox,
  });

  // ══════════════════════════════════════════════════════════════════════════
  // 1. SMART CATEGORIZATION ENGINE
  // ══════════════════════════════════════════════════════════════════════════

  /// Suggests a category based on transaction description
  /// Uses keyword matching + learned patterns from user behavior
  CategorySuggestion suggestCategory(String description, TransactionType type) {
    final normalizedDesc = description.toLowerCase().trim();

    // First: Check learned patterns (user's own corrections)
    final learnedMatch = _matchLearnedPattern(normalizedDesc, type);
    if (learnedMatch != null && learnedMatch.confidence > 0.7) {
      return learnedMatch;
    }

    // Second: Keyword-based matching
    final keywordMatch = _matchKeywords(normalizedDesc, type);
    if (keywordMatch != null) {
      return keywordMatch;
    }

    // Third: Fuzzy matching with existing descriptions
    final fuzzyMatch = _fuzzyMatchExisting(normalizedDesc, type);
    if (fuzzyMatch != null && fuzzyMatch.confidence > 0.5) {
      return fuzzyMatch;
    }

    // Default fallback
    return CategorySuggestion(
      category: type == TransactionType.income
          ? TransactionCategory.otherIncome
          : TransactionCategory.otherExpense,
      confidence: 0.1,
      reason: 'Aucun pattern reconnu',
    );
  }

  CategorySuggestion? _matchLearnedPattern(String desc, TransactionType type) {
    final patterns = patternsBox.values.where((p) => p.type == type).toList();

    for (final pattern in patterns) {
      for (final keyword in pattern.keywords) {
        if (desc.contains(keyword.toLowerCase())) {
          return CategorySuggestion(
            category: pattern.category,
            categoryId: pattern.categoryId,
            confidence: pattern.confidence,
            reason: 'Basé sur vos habitudes',
          );
        }
      }
    }
    return null;
  }

  CategorySuggestion? _matchKeywords(String desc, TransactionType type) {
    // Comprehensive keyword mapping for FCFA region context
    final expenseKeywords = <TransactionCategory, List<String>>{
      TransactionCategory.food: [
        'restaurant', 'resto', 'manger', 'dejeuner', 'diner', 'petit-dej',
        'fast food', 'kfc', 'pizza', 'burger', 'cafe', 'boulangerie',
        'snack', 'grill', 'maquis', 'dibiterie', 'tangana', 'garba',
      ],
      TransactionCategory.transport: [
        'uber', 'taxi', 'yango', 'bolt', 'bus', 'essence', 'carburant',
        'gasoil', 'parking', 'peage', 'station', 'total', 'oil',
        'sotrama', 'gbaka', 'woro-woro', 'moto',
      ],
      TransactionCategory.groceries: [
        'supermarche', 'marche', 'courses', 'epicerie', 'auchan', 'carrefour',
        'casino', 'super u', 'king cash', 'cdiscount', 'alimentation',
      ],
      TransactionCategory.bills: [
        'facture', 'electricite', 'eau', 'cie', 'sodeci', 'eneo', 'senelec',
        'internet', 'wifi', 'orange', 'mtn', 'moov', 'airtel', 'free',
      ],
      TransactionCategory.health: [
        'pharmacie', 'medicament', 'docteur', 'hopital', 'clinique',
        'consultation', 'analyse', 'radio', 'medecin', 'ordonnance',
      ],
      TransactionCategory.education: [
        'ecole', 'scolarite', 'universite', 'formation', 'cours', 'livre',
        'fourniture', 'inscription', 'frais scolaire',
      ],
      TransactionCategory.rent: [
        'loyer', 'appartement', 'location', 'maison', 'bail', 'proprietaire',
      ],
      TransactionCategory.shopping: [
        'achat', 'shopping', 'vetement', 'chaussure', 'sac', 'accessoire',
        'zara', 'h&m', 'jumia', 'amazon', 'aliexpress', 'commande',
      ],
      TransactionCategory.entertainment: [
        'cinema', 'film', 'netflix', 'spotify', 'concert', 'sortie',
        'boite', 'bar', 'fete', 'jeu', 'game', 'playstation', 'xbox',
      ],
      TransactionCategory.subscriptions: [
        'abonnement', 'subscription', 'mensuel', 'forfait', 'premium',
        'youtube', 'apple', 'google', 'microsoft', 'canal+', 'dstv',
      ],
      TransactionCategory.utilities: [
        'service', 'reparation', 'maintenance', 'nettoyage', 'menage',
      ],
      TransactionCategory.travel: [
        'voyage', 'billet', 'avion', 'hotel', 'airbnb', 'booking',
        'vacances', 'transport', 'train', 'bus longue distance',
      ],
      TransactionCategory.fitness: [
        'sport', 'gym', 'fitness', 'musculation', 'coach', 'salle',
      ],
      TransactionCategory.beauty: [
        'coiffure', 'salon', 'beaute', 'maquillage', 'soin', 'massage',
        'ongle', 'manucure', 'barbier', 'tresse',
      ],
      TransactionCategory.gifts: [
        'cadeau', 'anniversaire', 'mariage', 'bapteme', 'fete',
      ],
      TransactionCategory.insurance: [
        'assurance', 'mutuelle', 'prevoyance', 'sante',
      ],
    };

    final incomeKeywords = <TransactionCategory, List<String>>{
      TransactionCategory.salary: [
        'salaire', 'paie', 'remuneration', 'virement employeur',
      ],
      TransactionCategory.freelance: [
        'freelance', 'mission', 'prestation', 'client', 'projet',
      ],
      TransactionCategory.business: [
        'vente', 'commerce', 'benefice', 'chiffre', 'recette',
      ],
      TransactionCategory.investment: [
        'dividende', 'interet', 'placement', 'investissement', 'rendement',
      ],
      TransactionCategory.bonus: [
        'bonus', 'prime', 'gratification', '13eme mois',
      ],
      TransactionCategory.refund: [
        'remboursement', 'retour', 'avoir', 'credit',
      ],
      TransactionCategory.gift: [
        'cadeau', 'don', 'aide', 'famille', 'parent',
      ],
      TransactionCategory.rental: [
        'loyer recu', 'location', 'locataire',
      ],
    };

    final keywords = type == TransactionType.expense ? expenseKeywords : incomeKeywords;

    for (final entry in keywords.entries) {
      for (final keyword in entry.value) {
        if (desc.contains(keyword)) {
          return CategorySuggestion(
            category: entry.key,
            confidence: 0.8,
            reason: 'Mot-clé détecté: "$keyword"',
          );
        }
      }
    }
    return null;
  }

  CategorySuggestion? _fuzzyMatchExisting(String desc, TransactionType type) {
    final transactions = transactionsBox.values
        .where((t) => t.type == type && t.description.isNotEmpty)
        .toList();

    if (transactions.isEmpty) return null;

    // Find similar descriptions
    double bestScore = 0;
    LocalTransaction? bestMatch;

    for (final tx in transactions) {
      final score = _similarityScore(desc, tx.description.toLowerCase());
      if (score > bestScore) {
        bestScore = score;
        bestMatch = tx;
      }
    }

    if (bestMatch != null && bestScore > 0.5) {
      return CategorySuggestion(
        category: bestMatch.category,
        categoryId: bestMatch.categoryId,
        confidence: bestScore * 0.9,
        reason: 'Similaire à "${bestMatch.description}"',
      );
    }
    return null;
  }

  double _similarityScore(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final wordsA = a.split(RegExp(r'\s+'));
    final wordsB = b.split(RegExp(r'\s+'));

    int matches = 0;
    for (final wordA in wordsA) {
      if (wordA.length < 3) continue;
      for (final wordB in wordsB) {
        if (wordB.contains(wordA) || wordA.contains(wordB)) {
          matches++;
          break;
        }
      }
    }

    return matches / max(wordsA.length, wordsB.length);
  }

  /// Learn from user's category correction
  void learnCategoryChoice(String description, TransactionCategory category,
      String? categoryId, TransactionType type) {
    final normalizedDesc = description.toLowerCase().trim();
    final keywords = _extractKeywords(normalizedDesc);

    // Find or create pattern
    final existingPattern = patternsBox.values.firstWhere(
      (p) => p.category == category && p.type == type,
      orElse: () => CategoryPattern(
        category: category,
        categoryId: categoryId,
        type: type,
        keywords: [],
        confidence: 0.5,
        usageCount: 0,
      ),
    );

    // Update pattern
    final updatedKeywords = {...existingPattern.keywords, ...keywords}.toList();
    final newCount = existingPattern.usageCount + 1;
    final newConfidence = min(0.95, 0.5 + (newCount * 0.05));

    final updatedPattern = CategoryPattern(
      category: category,
      categoryId: categoryId,
      type: type,
      keywords: updatedKeywords,
      confidence: newConfidence,
      usageCount: newCount,
    );

    // Save
    if (existingPattern.isInBox) {
      existingPattern.keywords = updatedKeywords;
      existingPattern.confidence = newConfidence;
      existingPattern.usageCount = newCount;
      existingPattern.save();
    } else {
      patternsBox.add(updatedPattern);
    }
  }

  List<String> _extractKeywords(String text) {
    final stopWords = {'le', 'la', 'les', 'de', 'du', 'des', 'un', 'une', 'et',
                       'ou', 'pour', 'par', 'sur', 'avec', 'dans', 'a', 'au'};
    return text
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !stopWords.contains(w))
        .take(5)
        .toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. PREDICTIVE ENGINE - Seasonal, Monthly, Cash Flow
  // ══════════════════════════════════════════════════════════════════════════

  /// Predicts cash flow for the next 30 days
  CashFlowForecast forecastCashFlow({int days = 30}) {
    if (_cachedForecast != null &&
        _lastAnalysis != null &&
        DateTime.now().difference(_lastAnalysis!).inHours < 1) {
      return _cachedForecast!;
    }

    final now = DateTime.now();
    final predictions = <DateTime, DailyPrediction>{};

    // Get historical data
    final transactions = transactionsBox.values.toList();
    final jobs = jobsBox.values.where((j) => j.isActive).toList();
    final recurring = recurringBox.values.toList();

    // Calculate baseline daily spending
    final dailyAverages = _calculateDailyAverages(transactions);
    final weekdayFactors = _calculateWeekdayFactors(transactions);
    final monthFactors = _calculateMonthFactors(transactions);
    final paydayEffect = _calculatePaydayEffect(transactions, jobs);

    double runningBalance = _calculateCurrentBalance(transactions);

    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day + i);

      // Predicted expenses
      double predictedExpense = dailyAverages.expense;
      predictedExpense *= weekdayFactors[date.weekday] ?? 1.0;
      predictedExpense *= monthFactors[date.month] ?? 1.0;

      // Payday effect (people spend more after payday)
      final daysSincePayday = _daysSinceLastPayday(date, jobs);
      if (daysSincePayday <= 3) {
        predictedExpense *= paydayEffect;
      }

      // Predicted income
      double predictedIncome = 0;

      // Check for job payments
      for (final job in jobs) {
        if (_isPayday(date, job)) {
          predictedIncome += job.amount;
        }
      }

      // Check for recurring transactions
      for (final rec in recurring) {
        if (_recurringDueOn(date, rec)) {
          if (rec.type == TransactionType.income) {
            predictedIncome += rec.amount;
          } else {
            predictedExpense += rec.amount;
          }
        }
      }

      runningBalance += predictedIncome - predictedExpense;

      predictions[date] = DailyPrediction(
        date: date,
        predictedIncome: predictedIncome,
        predictedExpense: predictedExpense,
        predictedBalance: runningBalance,
        confidence: _calculateConfidence(transactions.length, i),
        factors: _getFactorsDescription(date, jobs, daysSincePayday),
      );
    }

    _cachedForecast = CashFlowForecast(
      generatedAt: now,
      predictions: predictions,
      summary: _generateForecastSummary(predictions),
    );
    _lastAnalysis = now;

    return _cachedForecast!;
  }

  DailyAverages _calculateDailyAverages(List<LocalTransaction> transactions) {
    if (transactions.isEmpty) {
      return DailyAverages(income: 0, expense: 0);
    }

    final expenses = transactions.where((t) => t.type == TransactionType.expense);
    final incomes = transactions.where((t) => t.type == TransactionType.income);

    final dates = transactions.map((t) => t.date).toList()..sort();
    final daySpan = max(1, dates.last.difference(dates.first).inDays);

    return DailyAverages(
      income: incomes.fold(0.0, (sum, t) => sum + t.amount) / daySpan,
      expense: expenses.fold(0.0, (sum, t) => sum + t.amount) / daySpan,
    );
  }

  Map<int, double> _calculateWeekdayFactors(List<LocalTransaction> transactions) {
    final factors = <int, double>{};
    final weekdayTotals = <int, double>{};
    final weekdayCounts = <int, int>{};

    for (final tx in transactions.where((t) => t.type == TransactionType.expense)) {
      final day = tx.date.weekday;
      weekdayTotals[day] = (weekdayTotals[day] ?? 0) + tx.amount;
      weekdayCounts[day] = (weekdayCounts[day] ?? 0) + 1;
    }

    if (weekdayTotals.isEmpty) return {for (int i = 1; i <= 7; i++) i: 1.0};

    final overallAvg = weekdayTotals.values.reduce((a, b) => a + b) /
                       weekdayCounts.values.reduce((a, b) => a + b);

    for (int day = 1; day <= 7; day++) {
      if (weekdayCounts[day] != null && weekdayCounts[day]! > 0) {
        final dayAvg = weekdayTotals[day]! / weekdayCounts[day]!;
        factors[day] = dayAvg / overallAvg;
      } else {
        factors[day] = 1.0;
      }
    }

    return factors;
  }

  Map<int, double> _calculateMonthFactors(List<LocalTransaction> transactions) {
    final factors = <int, double>{};
    final monthTotals = <int, double>{};
    final monthCounts = <int, int>{};

    for (final tx in transactions.where((t) => t.type == TransactionType.expense)) {
      final month = tx.date.month;
      monthTotals[month] = (monthTotals[month] ?? 0) + tx.amount;
      monthCounts[month] = (monthCounts[month] ?? 0) + 1;
    }

    if (monthTotals.isEmpty) return {for (int i = 1; i <= 12; i++) i: 1.0};

    final overallAvg = monthTotals.values.reduce((a, b) => a + b) /
                       monthCounts.values.reduce((a, b) => a + b);

    // Known seasonal patterns for FCFA region
    final seasonalDefaults = <int, double>{
      1: 0.9,   // January - post-holiday recovery
      2: 0.95,
      3: 1.0,
      4: 1.0,
      5: 1.05,
      6: 1.1,   // Mid-year activities
      7: 1.0,
      8: 1.15,  // Back to school
      9: 1.2,   // School expenses peak
      10: 1.0,
      11: 1.1,
      12: 1.3,  // Holidays
    };

    for (int month = 1; month <= 12; month++) {
      if (monthCounts[month] != null && monthCounts[month]! > 2) {
        final monthAvg = monthTotals[month]! / monthCounts[month]!;
        factors[month] = monthAvg / overallAvg;
      } else {
        // Use seasonal defaults if not enough data
        factors[month] = seasonalDefaults[month]!;
      }
    }

    return factors;
  }

  double _calculatePaydayEffect(List<LocalTransaction> transactions, List<Job> jobs) {
    if (jobs.isEmpty || transactions.isEmpty) return 1.2; // Default 20% increase

    final paydays = jobs.map((j) => j.paymentDate.day).toSet();

    double afterPaydayTotal = 0;
    int afterPaydayCount = 0;
    double normalTotal = 0;
    int normalCount = 0;

    for (final tx in transactions.where((t) => t.type == TransactionType.expense)) {
      final dayOfMonth = tx.date.day;
      bool isNearPayday = paydays.any((payday) =>
        (dayOfMonth >= payday && dayOfMonth <= payday + 3) ||
        (payday > 28 && dayOfMonth <= 3)
      );

      if (isNearPayday) {
        afterPaydayTotal += tx.amount;
        afterPaydayCount++;
      } else {
        normalTotal += tx.amount;
        normalCount++;
      }
    }

    if (normalCount == 0 || afterPaydayCount == 0) return 1.2;

    final afterPaydayAvg = afterPaydayTotal / afterPaydayCount;
    final normalAvg = normalTotal / normalCount;

    return normalAvg > 0 ? afterPaydayAvg / normalAvg : 1.2;
  }

  double _calculateCurrentBalance(List<LocalTransaction> transactions) {
    double balance = 0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.income) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  int _daysSinceLastPayday(DateTime date, List<Job> jobs) {
    if (jobs.isEmpty) return 15;

    int minDays = 31;
    for (final job in jobs) {
      int payday = job.paymentDate.day;
      int currentDay = date.day;

      if (currentDay >= payday) {
        minDays = min(minDays, currentDay - payday);
      } else {
        // Last month's payday
        final lastMonth = DateTime(date.year, date.month - 1, payday);
        minDays = min(minDays, date.difference(lastMonth).inDays);
      }
    }
    return minDays;
  }

  bool _isPayday(DateTime date, Job job) {
    return date.day == job.paymentDate.day;
  }

  bool _recurringDueOn(DateTime date, RecurringTransaction rec) {
    switch (rec.frequency) {
      case RecurringFrequency.daily:
        return true;
      case RecurringFrequency.weekly:
        // Check if current weekday is in the daysOfWeek list
        return rec.daysOfWeek.contains(date.weekday);
      case RecurringFrequency.monthly:
        return date.day == rec.dayOfMonth;
    }
  }

  double _calculateConfidence(int dataPoints, int daysAhead) {
    // Confidence decreases with fewer data points and further predictions
    final dataConfidence = min(1.0, dataPoints / 50);
    final timeDecay = 1.0 - (daysAhead / 60); // Confidence drops over 60 days
    return max(0.1, dataConfidence * timeDecay);
  }

  List<String> _getFactorsDescription(DateTime date, List<Job> jobs, int daysSincePayday) {
    final factors = <String>[];

    // Weekday
    final weekdays = ['', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    if (date.weekday >= 6) {
      factors.add('Weekend (dépenses +)');
    }

    // Payday proximity
    if (daysSincePayday <= 3) {
      factors.add('Proche du jour de paie');
    }

    // Month-end
    if (date.day >= 25) {
      factors.add('Fin de mois');
    }

    // Special months
    if (date.month == 12) factors.add('Période des fêtes');
    if (date.month == 9) factors.add('Rentrée scolaire');

    return factors;
  }

  ForecastSummary _generateForecastSummary(Map<DateTime, DailyPrediction> predictions) {
    if (predictions.isEmpty) {
      return ForecastSummary(
        lowestBalance: 0,
        lowestBalanceDate: DateTime.now(),
        endBalance: 0,
        totalPredictedExpenses: 0,
        totalPredictedIncome: 0,
        riskLevel: RiskLevel.unknown,
        warnings: [],
      );
    }

    final values = predictions.values.toList();
    final lowest = values.reduce((a, b) =>
      a.predictedBalance < b.predictedBalance ? a : b);
    final last = values.last;

    double totalExpenses = 0;
    double totalIncome = 0;
    for (final p in values) {
      totalExpenses += p.predictedExpense;
      totalIncome += p.predictedIncome;
    }

    final warnings = <String>[];
    RiskLevel risk = RiskLevel.low;

    if (lowest.predictedBalance < 0) {
      warnings.add('Solde négatif prévu le ${_formatDate(lowest.date)}');
      risk = RiskLevel.critical;
    } else if (lowest.predictedBalance < totalExpenses * 0.1) {
      warnings.add('Solde très bas prévu le ${_formatDate(lowest.date)}');
      risk = RiskLevel.high;
    } else if (last.predictedBalance < values.first.predictedBalance * 0.5) {
      warnings.add('Forte baisse du solde prévue ce mois');
      risk = RiskLevel.medium;
    }

    return ForecastSummary(
      lowestBalance: lowest.predictedBalance,
      lowestBalanceDate: lowest.date,
      endBalance: last.predictedBalance,
      totalPredictedExpenses: totalExpenses,
      totalPredictedIncome: totalIncome,
      riskLevel: risk,
      warnings: warnings,
    );
  }

  String _formatDate(DateTime date) {
    final months = ['', 'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
                   'juil', 'août', 'sep', 'oct', 'nov', 'déc'];
    return '${date.day} ${months[date.month]}';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. PROACTIVE COACHING - Alerts before problems
  // ══════════════════════════════════════════════════════════════════════════

  List<ProactiveAlert> generateAlerts() {
    if (_cachedAlerts != null &&
        _lastAnalysis != null &&
        DateTime.now().difference(_lastAnalysis!).inMinutes < 30) {
      return _cachedAlerts!;
    }

    final alerts = <ProactiveAlert>[];
    final forecast = forecastCashFlow();
    final transactions = transactionsBox.values.toList();
    final goals = savingsBox.values.toList();

    // 1. Cash flow warnings
    if (forecast.summary.riskLevel == RiskLevel.critical) {
      alerts.add(ProactiveAlert(
        type: AlertType.cashFlowCritical,
        title: 'Alerte solde',
        message: 'Votre solde pourrait devenir négatif le ${_formatDate(forecast.summary.lowestBalanceDate)}',
        severity: AlertSeverity.critical,
        actionSuggestion: 'Réduisez les dépenses non-essentielles cette semaine',
        icon: '🚨',
      ));
    } else if (forecast.summary.riskLevel == RiskLevel.high) {
      alerts.add(ProactiveAlert(
        type: AlertType.cashFlowWarning,
        title: 'Solde bas prévu',
        message: 'Solde prévu de ${forecast.summary.lowestBalance.toStringAsFixed(0)} FCFA',
        severity: AlertSeverity.high,
        actionSuggestion: 'Surveillez vos dépenses cette semaine',
        icon: '⚠️',
      ));
    }

    // 2. Spending pace alerts
    final spendingPace = _analyzeSpendingPace(transactions);
    if (spendingPace.isOverPace) {
      alerts.add(ProactiveAlert(
        type: AlertType.spendingPace,
        title: 'Rythme de dépenses élevé',
        message: 'Vous avez dépensé ${spendingPace.percentOfExpected.toStringAsFixed(0)}% de votre budget habituel en ${spendingPace.daysElapsed} jours',
        severity: spendingPace.percentOfExpected > 120
            ? AlertSeverity.high
            : AlertSeverity.medium,
        actionSuggestion: 'Il vous reste ${spendingPace.daysRemaining} jours ce mois',
        icon: '📊',
      ));
    }

    // 3. Goal progress alerts
    for (final goal in goals) {
      final progress = _analyzeGoalProgress(goal, transactions);
      if (progress != null) {
        if (progress.isOffTrack) {
          alerts.add(ProactiveAlert(
            type: AlertType.goalOffTrack,
            title: 'Objectif en danger',
            message: 'Vous êtes à ${progress.currentProgress.toStringAsFixed(0)}% de votre objectif d\'épargne',
            severity: AlertSeverity.medium,
            actionSuggestion: 'Économisez ${progress.dailyNeeded.toStringAsFixed(0)} FCFA/jour pour rattraper',
            icon: '🎯',
          ));
        } else if (progress.isAhead) {
          alerts.add(ProactiveAlert(
            type: AlertType.goalAhead,
            title: 'Bravo !',
            message: 'Vous êtes en avance sur votre objectif d\'épargne (${progress.currentProgress.toStringAsFixed(0)}%)',
            severity: AlertSeverity.positive,
            actionSuggestion: 'Continuez comme ça !',
            icon: '🌟',
          ));
        }
      }
    }

    // 4. Unusual category spending
    final categoryAlerts = _detectCategoryOverspending(transactions);
    alerts.addAll(categoryAlerts);

    // 5. Bill reminders (upcoming recurring expenses)
    final billAlerts = _generateBillReminders();
    alerts.addAll(billAlerts);

    // Sort by severity
    alerts.sort((a, b) => b.severity.index.compareTo(a.severity.index));

    _cachedAlerts = alerts;
    return alerts;
  }

  SpendingPace _analyzeSpendingPace(List<LocalTransaction> transactions) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysElapsed = now.day;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - daysElapsed;

    // This month's expenses
    final thisMonthExpenses = transactions
        .where((t) => t.type == TransactionType.expense &&
                     t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))))
        .fold(0.0, (sum, t) => sum + t.amount);

    // Expected based on history
    final lastMonths = <double>[];
    for (int i = 1; i <= 3; i++) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);
      final monthExpenses = transactions
          .where((t) => t.type == TransactionType.expense &&
                       t.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
                       t.date.isBefore(monthEnd.add(const Duration(days: 1))))
          .fold(0.0, (sum, t) => sum + t.amount);
      if (monthExpenses > 0) lastMonths.add(monthExpenses);
    }

    final avgMonthly = lastMonths.isEmpty
        ? thisMonthExpenses
        : lastMonths.reduce((a, b) => a + b) / lastMonths.length;

    final expectedAtThisPoint = avgMonthly * (daysElapsed / daysInMonth);
    final percentOfExpected = expectedAtThisPoint > 0
        ? (thisMonthExpenses / expectedAtThisPoint) * 100.0
        : 100.0;

    return SpendingPace(
      daysElapsed: daysElapsed,
      daysRemaining: daysRemaining,
      currentSpending: thisMonthExpenses,
      expectedSpending: expectedAtThisPoint,
      percentOfExpected: percentOfExpected,
      isOverPace: percentOfExpected > 110,
    );
  }

  GoalProgress? _analyzeGoalProgress(SavingsGoal goal, List<LocalTransaction> transactions) {
    final now = DateTime.now();

    // Check if goal is for current period
    if (goal.year != now.year) return null;
    // Month 0 means yearly goal, otherwise it's a monthly goal
    final isYearlyGoal = goal.month == 0;
    if (!isYearlyGoal && goal.month != now.month) return null;

    // Calculate current savings
    DateTime periodStart;
    DateTime periodEnd;
    int totalDays;
    int daysElapsed;

    if (!isYearlyGoal) {
      // Monthly goal
      periodStart = DateTime(goal.year, goal.month, 1);
      periodEnd = DateTime(goal.year, goal.month + 1, 0);
      totalDays = periodEnd.day;
      daysElapsed = now.day;
    } else {
      // Yearly goal (month = 0)
      periodStart = DateTime(goal.year, 1, 1);
      periodEnd = DateTime(goal.year, 12, 31);
      totalDays = 365;
      daysElapsed = now.difference(periodStart).inDays;
    }

    final periodTransactions = transactions.where((t) =>
        t.date.isAfter(periodStart.subtract(const Duration(days: 1))) &&
        t.date.isBefore(now.add(const Duration(days: 1))));

    double netSavings = 0;
    for (final tx in periodTransactions) {
      if (tx.type == TransactionType.income) {
        netSavings += tx.amount;
      } else {
        netSavings -= tx.amount;
      }
    }

    final targetProgress = (daysElapsed / totalDays) * goal.targetAmount;
    final currentProgress = goal.targetAmount > 0
        ? (netSavings / goal.targetAmount) * 100.0
        : 0.0;
    final expectedProgress = (daysElapsed / totalDays) * 100.0;

    final daysRemaining = totalDays - daysElapsed;
    final amountNeeded = goal.targetAmount - netSavings;
    final dailyNeeded = daysRemaining > 0 ? amountNeeded / daysRemaining : amountNeeded;

    return GoalProgress(
      goal: goal,
      currentSavings: netSavings,
      currentProgress: currentProgress,
      expectedProgress: expectedProgress,
      isOffTrack: currentProgress < expectedProgress * 0.8,
      isAhead: currentProgress > expectedProgress * 1.2,
      dailyNeeded: dailyNeeded,
      daysRemaining: daysRemaining,
    );
  }

  List<ProactiveAlert> _detectCategoryOverspending(List<LocalTransaction> transactions) {
    final alerts = <ProactiveAlert>[];
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Group this month's expenses by category
    final thisMonthByCategory = <String, double>{};
    final historicalByCategory = <String, List<double>>{};

    for (final tx in transactions.where((t) => t.type == TransactionType.expense)) {
      final category = tx.category?.displayName ?? 'Autre';

      if (tx.date.isAfter(startOfMonth.subtract(const Duration(days: 1)))) {
        thisMonthByCategory[category] =
            (thisMonthByCategory[category] ?? 0) + tx.amount;
      } else {
        // Historical data
        final monthKey = '${tx.date.year}-${tx.date.month}';
        historicalByCategory.putIfAbsent(category, () => []);
        // Only add once per month
        historicalByCategory[category]!.add(tx.amount);
      }
    }

    // Compare to historical averages
    for (final entry in thisMonthByCategory.entries) {
      final historical = historicalByCategory[entry.key];
      if (historical != null && historical.length >= 3) {
        final avgHistorical = historical.reduce((a, b) => a + b) / historical.length;
        final ratio = entry.value / avgHistorical;

        if (ratio > 1.5) {
          alerts.add(ProactiveAlert(
            type: AlertType.categoryOverspend,
            title: 'Dépenses élevées en ${entry.key}',
            message: '${entry.value.toStringAsFixed(0)} FCFA ce mois vs ${avgHistorical.toStringAsFixed(0)} FCFA en moyenne',
            severity: ratio > 2 ? AlertSeverity.high : AlertSeverity.medium,
            actionSuggestion: 'C\'est ${((ratio - 1) * 100).toStringAsFixed(0)}% de plus que d\'habitude',
            icon: '📈',
          ));
        }
      }
    }

    return alerts;
  }

  List<ProactiveAlert> _generateBillReminders() {
    final alerts = <ProactiveAlert>[];
    final now = DateTime.now();
    final recurring = recurringBox.values.where((r) =>
        r.type == TransactionType.expense).toList();

    for (final rec in recurring) {
      DateTime? nextDue;

      switch (rec.frequency) {
        case RecurringFrequency.daily:
          nextDue = DateTime(now.year, now.month, now.day + 1);
          break;
        case RecurringFrequency.weekly:
          // Find the next day of week from daysOfWeek list
          if (rec.daysOfWeek.isNotEmpty) {
            int minDaysUntil = 8;
            for (final dayOfWeek in rec.daysOfWeek) {
              final daysUntil = (dayOfWeek - now.weekday + 7) % 7;
              if (daysUntil < minDaysUntil && daysUntil > 0) {
                minDaysUntil = daysUntil;
              }
            }
            if (minDaysUntil <= 7) {
              nextDue = DateTime(now.year, now.month, now.day + minDaysUntil);
            }
          }
          break;
        case RecurringFrequency.monthly:
          if (rec.dayOfMonth > now.day) {
            nextDue = DateTime(now.year, now.month, rec.dayOfMonth);
          } else {
            nextDue = DateTime(now.year, now.month + 1, rec.dayOfMonth);
          }
          break;
      }

      if (nextDue != null) {
        final daysUntilDue = nextDue.difference(now).inDays;

        if (daysUntilDue <= 3 && daysUntilDue >= 0) {
          alerts.add(ProactiveAlert(
            type: AlertType.billReminder,
            title: 'Rappel: ${rec.description}',
            message: daysUntilDue == 0
                ? 'Dû aujourd\'hui: ${rec.amount.toStringAsFixed(0)} FCFA'
                : 'Dû dans $daysUntilDue jours: ${rec.amount.toStringAsFixed(0)} FCFA',
            severity: daysUntilDue == 0 ? AlertSeverity.high : AlertSeverity.low,
            actionSuggestion: 'Assurez-vous d\'avoir les fonds',
            icon: '🔔',
          ));
        }
      }
    }

    return alerts;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4. SMART BUDGET RECOMMENDATIONS
  // ══════════════════════════════════════════════════════════════════════════

  Map<String, SmartBudget> generateSmartBudgets() {
    if (_cachedBudgets != null &&
        _lastAnalysis != null &&
        DateTime.now().difference(_lastAnalysis!).inHours < 6) {
      return _cachedBudgets!;
    }

    final transactions = transactionsBox.values.toList();
    final jobs = jobsBox.values.where((j) => j.isActive).toList();
    final budgets = <String, SmartBudget>{};

    // Calculate total monthly income
    double monthlyIncome = 0;
    for (final job in jobs) {
      monthlyIncome += job.monthlyIncome;
    }

    // Add average non-job income
    final nonJobIncome = _calculateAverageNonJobIncome(transactions);
    monthlyIncome += nonJobIncome;

    if (monthlyIncome == 0) {
      return {}; // Can't recommend budgets without income
    }

    // Analyze historical spending by category
    final categoryAverages = _calculateCategoryAverages(transactions);

    // Apply budget rules
    for (final entry in categoryAverages.entries) {
      final category = entry.key;
      final historicalAvg = entry.value.average;
      final historicalVariance = entry.value.variance;

      // Calculate recommended budget
      double recommended;
      String reasoning;
      BudgetStrategy strategy;

      // Essential categories get more budget
      if (_isEssentialCategory(category)) {
        recommended = max(historicalAvg, monthlyIncome * 0.1);
        strategy = BudgetStrategy.essential;
        reasoning = 'Catégorie essentielle - basé sur vos dépenses';
      } else if (historicalVariance > historicalAvg * 0.5) {
        // High variance = needs control
        recommended = historicalAvg * 0.8;
        strategy = BudgetStrategy.reduce;
        reasoning = 'Dépenses variables - budget réduit pour stabiliser';
      } else {
        recommended = historicalAvg;
        strategy = BudgetStrategy.maintain;
        reasoning = 'Dépenses stables - maintenir le niveau actuel';
      }

      // Cap discretionary spending at 15% of income per category
      if (!_isEssentialCategory(category)) {
        recommended = min(recommended, monthlyIncome * 0.15);
      }

      budgets[category] = SmartBudget(
        category: category,
        recommendedAmount: recommended,
        historicalAverage: historicalAvg,
        percentOfIncome: (recommended / monthlyIncome) * 100,
        reasoning: reasoning,
        strategy: strategy,
        flexibility: historicalVariance < historicalAvg * 0.3
            ? BudgetFlexibility.strict
            : BudgetFlexibility.flexible,
      );
    }

    // Add savings recommendation
    final totalBudgeted = budgets.values.fold(0.0, (sum, b) => sum + b.recommendedAmount);
    final savingsTarget = monthlyIncome - totalBudgeted;

    budgets['Épargne'] = SmartBudget(
      category: 'Épargne',
      recommendedAmount: max(0, savingsTarget),
      historicalAverage: 0,
      percentOfIncome: max(0, (savingsTarget / monthlyIncome) * 100),
      reasoning: savingsTarget > monthlyIncome * 0.1
          ? 'Objectif d\'épargne sain (>${(savingsTarget / monthlyIncome * 100).toStringAsFixed(0)}%)'
          : 'Essayez d\'économiser au moins 10% de vos revenus',
      strategy: BudgetStrategy.grow,
      flexibility: BudgetFlexibility.target,
    );

    _cachedBudgets = budgets;
    return budgets;
  }

  double _calculateAverageNonJobIncome(List<LocalTransaction> transactions) {
    final now = DateTime.now();
    final incomes = transactions.where((t) =>
        t.type == TransactionType.income &&
        t.category != TransactionCategory.salary &&
        t.date.isAfter(DateTime(now.year, now.month - 3, 1)));

    if (incomes.isEmpty) return 0;
    return incomes.fold(0.0, (sum, t) => sum + t.amount) / 3;
  }

  Map<String, CategoryStats> _calculateCategoryAverages(List<LocalTransaction> transactions) {
    final now = DateTime.now();
    final stats = <String, CategoryStats>{};
    final categoryMonthly = <String, List<double>>{};

    // Group by category and month
    for (final tx in transactions.where((t) => t.type == TransactionType.expense)) {
      final category = tx.category?.displayName ?? 'Autre';
      final monthKey = '${tx.date.year}-${tx.date.month}';

      categoryMonthly.putIfAbsent(category, () => []);

      // Add to monthly totals
      final monthIndex = categoryMonthly[category]!.indexWhere(
        (m) => m == monthKey.hashCode.toDouble());
      if (monthIndex == -1) {
        categoryMonthly[category]!.add(tx.amount);
      } else {
        categoryMonthly[category]![monthIndex] += tx.amount;
      }
    }

    // Calculate stats
    for (final entry in categoryMonthly.entries) {
      final amounts = entry.value;
      if (amounts.isEmpty) continue;

      final average = amounts.reduce((a, b) => a + b) / amounts.length;
      final variance = amounts.map((a) => pow(a - average, 2))
          .reduce((a, b) => a + b) / amounts.length;

      stats[entry.key] = CategoryStats(
        average: average,
        variance: sqrt(variance),
        min: amounts.reduce(min),
        max: amounts.reduce(max),
        dataPoints: amounts.length,
      );
    }

    return stats;
  }

  bool _isEssentialCategory(String category) {
    final essentials = [
      'Loyer', 'Courses', 'Transport', 'Factures', 'Santé',
      'Éducation', 'Services', 'Assurance',
    ];
    return essentials.contains(category);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 5. GOAL FEASIBILITY ANALYZER
  // ══════════════════════════════════════════════════════════════════════════

  GoalFeasibility analyzeGoalFeasibility(double targetAmount, int months) {
    final transactions = transactionsBox.values.toList();
    final jobs = jobsBox.values.where((j) => j.isActive).toList();

    // Calculate average monthly savings
    final monthlySavings = _calculateAverageMonthlySavings(transactions);

    // Calculate total monthly income
    double monthlyIncome = 0;
    for (final job in jobs) {
      monthlyIncome += job.monthlyIncome;
    }
    monthlyIncome += _calculateAverageNonJobIncome(transactions);

    final monthlyExpenses = monthlyIncome - monthlySavings;
    final requiredMonthlySaving = targetAmount / months;
    final maxPossibleSaving = monthlyIncome * 0.5; // Assume max 50% savings rate

    FeasibilityLevel level;
    String assessment;
    List<String> recommendations = [];
    double projectedMonths;

    if (monthlySavings >= requiredMonthlySaving) {
      level = FeasibilityLevel.easy;
      assessment = 'Très réalisable à votre rythme actuel';
      projectedMonths = targetAmount / monthlySavings;
    } else if (requiredMonthlySaving <= maxPossibleSaving) {
      level = FeasibilityLevel.challenging;
      assessment = 'Réalisable avec des ajustements';
      projectedMonths = targetAmount / (monthlySavings * 1.2);

      final gap = requiredMonthlySaving - monthlySavings;
      recommendations.add('Réduisez vos dépenses de ${gap.toStringAsFixed(0)} FCFA/mois');

      // Suggest specific cuts
      final budgets = generateSmartBudgets();
      final discretionary = budgets.entries
          .where((e) => !_isEssentialCategory(e.key) && e.key != 'Épargne')
          .toList()
        ..sort((a, b) => b.value.recommendedAmount.compareTo(a.value.recommendedAmount));

      if (discretionary.isNotEmpty) {
        recommendations.add('Ciblez ${discretionary.first.key} (${discretionary.first.value.recommendedAmount.toStringAsFixed(0)} FCFA/mois)');
      }
    } else if (requiredMonthlySaving <= monthlyIncome * 0.8) {
      level = FeasibilityLevel.difficult;
      assessment = 'Difficile mais pas impossible';
      projectedMonths = targetAmount / maxPossibleSaving;

      recommendations.add('Envisagez d\'augmenter vos revenus');
      recommendations.add('Réduisez drastiquement les dépenses non-essentielles');
      recommendations.add('Allongez votre délai à ${(targetAmount / monthlySavings).ceil()} mois');
    } else {
      level = FeasibilityLevel.unrealistic;
      assessment = 'Objectif très ambitieux pour ce délai';
      projectedMonths = targetAmount / monthlySavings;

      final realisticMonths = (targetAmount / (monthlyIncome * 0.3)).ceil();
      recommendations.add('Délai réaliste: $realisticMonths mois');
      recommendations.add('Ou réduisez l\'objectif à ${(months * monthlySavings).toStringAsFixed(0)} FCFA');
    }

    return GoalFeasibility(
      targetAmount: targetAmount,
      targetMonths: months,
      currentMonthlySavings: monthlySavings,
      requiredMonthlySavings: requiredMonthlySaving,
      feasibilityLevel: level,
      assessment: assessment,
      projectedMonths: projectedMonths,
      recommendations: recommendations,
      savingsRateNeeded: monthlyIncome > 0
          ? (requiredMonthlySaving / monthlyIncome) * 100
          : 100,
      currentSavingsRate: monthlyIncome > 0
          ? (monthlySavings / monthlyIncome) * 100
          : 0,
    );
  }

  double _calculateAverageMonthlySavings(List<LocalTransaction> transactions) {
    if (transactions.isEmpty) return 0;

    final now = DateTime.now();
    final monthlyNet = <String, double>{};

    for (final tx in transactions) {
      final key = '${tx.date.year}-${tx.date.month}';
      monthlyNet.putIfAbsent(key, () => 0);

      if (tx.type == TransactionType.income) {
        monthlyNet[key] = monthlyNet[key]! + tx.amount;
      } else {
        monthlyNet[key] = monthlyNet[key]! - tx.amount;
      }
    }

    if (monthlyNet.isEmpty) return 0;

    // Only count positive months (actual savings)
    final positiveSavings = monthlyNet.values.where((v) => v > 0);
    if (positiveSavings.isEmpty) return 0;

    return positiveSavings.reduce((a, b) => a + b) / monthlyNet.length;
  }

  /// Clear all caches to force recalculation
  void invalidateCache() {
    _cachedForecast = null;
    _cachedAlerts = null;
    _cachedBudgets = null;
    _lastAnalysis = null;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DATA CLASSES
// ══════════════════════════════════════════════════════════════════════════════

class CategorySuggestion {
  final TransactionCategory? category;
  final String? categoryId;
  final double confidence;
  final String reason;

  CategorySuggestion({
    this.category,
    this.categoryId,
    required this.confidence,
    required this.reason,
  });
}

@HiveType(typeId: 20)
class CategoryPattern extends HiveObject {
  @HiveField(0)
  TransactionCategory category;

  @HiveField(1)
  String? categoryId;

  @HiveField(2)
  TransactionType type;

  @HiveField(3)
  List<String> keywords;

  @HiveField(4)
  double confidence;

  @HiveField(5)
  int usageCount;

  CategoryPattern({
    required this.category,
    this.categoryId,
    required this.type,
    required this.keywords,
    required this.confidence,
    required this.usageCount,
  });
}

@HiveType(typeId: 21)
class UserBehavior extends HiveObject {
  @HiveField(0)
  String behaviorType;

  @HiveField(1)
  Map<String, dynamic> data;

  @HiveField(2)
  DateTime recordedAt;

  UserBehavior({
    required this.behaviorType,
    required this.data,
    required this.recordedAt,
  });
}

class CashFlowForecast {
  final DateTime generatedAt;
  final Map<DateTime, DailyPrediction> predictions;
  final ForecastSummary summary;

  CashFlowForecast({
    required this.generatedAt,
    required this.predictions,
    required this.summary,
  });
}

class DailyPrediction {
  final DateTime date;
  final double predictedIncome;
  final double predictedExpense;
  final double predictedBalance;
  final double confidence;
  final List<String> factors;

  DailyPrediction({
    required this.date,
    required this.predictedIncome,
    required this.predictedExpense,
    required this.predictedBalance,
    required this.confidence,
    required this.factors,
  });
}

class ForecastSummary {
  final double lowestBalance;
  final DateTime lowestBalanceDate;
  final double endBalance;
  final double totalPredictedExpenses;
  final double totalPredictedIncome;
  final RiskLevel riskLevel;
  final List<String> warnings;

  ForecastSummary({
    required this.lowestBalance,
    required this.lowestBalanceDate,
    required this.endBalance,
    required this.totalPredictedExpenses,
    required this.totalPredictedIncome,
    required this.riskLevel,
    required this.warnings,
  });
}

enum RiskLevel { low, medium, high, critical, unknown }

class DailyAverages {
  final double income;
  final double expense;

  DailyAverages({required this.income, required this.expense});
}

class ProactiveAlert {
  final AlertType type;
  final String title;
  final String message;
  final AlertSeverity severity;
  final String actionSuggestion;
  final String icon;

  ProactiveAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.actionSuggestion,
    required this.icon,
  });
}

enum AlertType {
  cashFlowCritical,
  cashFlowWarning,
  spendingPace,
  goalOffTrack,
  goalAhead,
  categoryOverspend,
  billReminder,
}

enum AlertSeverity { low, medium, high, critical, positive }

class SpendingPace {
  final int daysElapsed;
  final int daysRemaining;
  final double currentSpending;
  final double expectedSpending;
  final double percentOfExpected;
  final bool isOverPace;

  SpendingPace({
    required this.daysElapsed,
    required this.daysRemaining,
    required this.currentSpending,
    required this.expectedSpending,
    required this.percentOfExpected,
    required this.isOverPace,
  });
}

class GoalProgress {
  final SavingsGoal goal;
  final double currentSavings;
  final double currentProgress;
  final double expectedProgress;
  final bool isOffTrack;
  final bool isAhead;
  final double dailyNeeded;
  final int daysRemaining;

  GoalProgress({
    required this.goal,
    required this.currentSavings,
    required this.currentProgress,
    required this.expectedProgress,
    required this.isOffTrack,
    required this.isAhead,
    required this.dailyNeeded,
    required this.daysRemaining,
  });
}

class SmartBudget {
  final String category;
  final double recommendedAmount;
  final double historicalAverage;
  final double percentOfIncome;
  final String reasoning;
  final BudgetStrategy strategy;
  final BudgetFlexibility flexibility;

  SmartBudget({
    required this.category,
    required this.recommendedAmount,
    required this.historicalAverage,
    required this.percentOfIncome,
    required this.reasoning,
    required this.strategy,
    required this.flexibility,
  });
}

enum BudgetStrategy { essential, maintain, reduce, grow }
enum BudgetFlexibility { strict, flexible, target }

class CategoryStats {
  final double average;
  final double variance;
  final double min;
  final double max;
  final int dataPoints;

  CategoryStats({
    required this.average,
    required this.variance,
    required this.min,
    required this.max,
    required this.dataPoints,
  });
}

class GoalFeasibility {
  final double targetAmount;
  final int targetMonths;
  final double currentMonthlySavings;
  final double requiredMonthlySavings;
  final FeasibilityLevel feasibilityLevel;
  final String assessment;
  final double projectedMonths;
  final List<String> recommendations;
  final double savingsRateNeeded;
  final double currentSavingsRate;

  GoalFeasibility({
    required this.targetAmount,
    required this.targetMonths,
    required this.currentMonthlySavings,
    required this.requiredMonthlySavings,
    required this.feasibilityLevel,
    required this.assessment,
    required this.projectedMonths,
    required this.recommendations,
    required this.savingsRateNeeded,
    required this.currentSavingsRate,
  });
}

enum FeasibilityLevel { easy, challenging, difficult, unrealistic }
