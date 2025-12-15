import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter/material.dart';
import 'package:koaa/app/data/models/challenge.dart';
import 'package:koaa/app/data/models/challenge_definitions.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/financial_context_service.dart';

class ChallengesController extends GetxController {
  late FinancialContextService _financialContext;
  late Box<UserChallenge> _userChallengeBox;
  late Box<UserBadge> _userBadgeBox;

  // Observable state
  final activeChallenges = <UserChallenge>[].obs;
  final completedChallenges = <UserChallenge>[].obs;
  final earnedBadges = <UserBadge>[].obs;
  final availableChallenges = <Challenge>[].obs;
  final totalPoints = 0.obs;
  final currentStreak = 0.obs;

  // All predefined challenges
  List<Challenge> get allChallenges => ChallengeDefinitions.all;

  @override
  void onInit() {
    super.onInit();
    _financialContext = Get.find<FinancialContextService>();
    _initializeBoxes();
    _loadUserData();

    // React to transaction changes to update challenge progress
    ever(_financialContext.allTransactions, (_) => evaluateAllChallenges());
  }

  Future<void> _initializeBoxes() async {
    _userChallengeBox = Hive.box<UserChallenge>('userChallengeBox');
    _userBadgeBox = Hive.box<UserBadge>('userBadgeBox');
  }

  void _loadUserData() {
    // Load active and completed challenges
    final allUserChallenges = _userChallengeBox.values.toList();
    activeChallenges.assignAll(
        allUserChallenges.where((c) => c.isActive && !c.isCompleted));
    completedChallenges
        .assignAll(allUserChallenges.where((c) => c.isCompleted));

    // Load earned badges
    earnedBadges.assignAll(_userBadgeBox.values.toList());

    // Calculate total points
    _calculateTotalPoints();

    // Update available challenges
    _updateAvailableChallenges();

    // Calculate current streak
    _calculateStreak();
  }

  void _calculateTotalPoints() {
    int points = 0;
    for (final uc in completedChallenges) {
      final challenge = getChallengeById(uc.challengeId);
      if (challenge != null) {
        points += challenge.rewardPoints;
      }
    }
    totalPoints.value = points;
  }

  void _updateAvailableChallenges() {
    final activeIds = activeChallenges.map((c) => c.challengeId).toSet();
    final completedNonRepeatableIds = completedChallenges
        .where((c) {
          final challenge = getChallengeById(c.challengeId);
          return challenge != null && !challenge.isRepeatable;
        })
        .map((c) => c.challengeId)
        .toSet();

    availableChallenges.assignAll(
      allChallenges.where((c) =>
          !activeIds.contains(c.id) &&
          !completedNonRepeatableIds.contains(c.id)),
    );
  }

  void _calculateStreak() {
    final transactions = _financialContext.allTransactions.toList();
    if (transactions.isEmpty) {
      currentStreak.value = 0;
      return;
    }

    // Check consecutive days with transactions
    final now = DateTime.now();
    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    while (true) {
      final hasTransactionOnDay = transactions.any((t) =>
          t.date.year == checkDate.year &&
          t.date.month == checkDate.month &&
          t.date.day == checkDate.day);

      if (hasTransactionOnDay) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    currentStreak.value = streak;
  }

  Challenge? getChallengeById(String id) {
    try {
      return allChallenges.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Start a challenge
  Future<void> startChallenge(String challengeId) async {
    final challenge = getChallengeById(challengeId);
    if (challenge == null) return;

    // Check if already active
    if (activeChallenges.any((c) => c.challengeId == challengeId)) return;

    final userChallenge = UserChallenge(
      challengeId: challengeId,
      startedAt: DateTime.now(),
    );

    await _userChallengeBox.put(userChallenge.id, userChallenge);
    activeChallenges.add(userChallenge);
    _updateAvailableChallenges();
  }

  /// Abandon a challenge
  Future<void> abandonChallenge(String userChallengeId) async {
    final index = activeChallenges.indexWhere((c) => c.id == userChallengeId);
    if (index == -1) return;

    final userChallenge = activeChallenges[index];
    userChallenge.isActive = false;
    userChallenge.isFailed = true;
    await _userChallengeBox.put(userChallenge.id, userChallenge);

    activeChallenges.removeAt(index);
    _updateAvailableChallenges();
  }

  /// Evaluate all active challenges
  void evaluateAllChallenges() {
    _calculateStreak();

    for (final userChallenge in List.from(activeChallenges)) {
      _evaluateChallenge(userChallenge);
    }

    // Also check one-time achievements
    _checkOneTimeAchievements();
  }

  void _evaluateChallenge(UserChallenge userChallenge) {
    final challenge = getChallengeById(userChallenge.challengeId);
    if (challenge == null) return;

    int progress = 0;

    switch (challenge.type) {
      case ChallengeType.spending:
        progress = _evaluateSpendingChallenge(challenge, userChallenge);
        break;
      case ChallengeType.saving:
        progress = _evaluateSavingChallenge(challenge, userChallenge);
        break;
      case ChallengeType.budget:
        progress = _evaluateBudgetChallenge(challenge, userChallenge);
        break;
      case ChallengeType.streak:
        progress = currentStreak.value;
        break;
      case ChallengeType.oneTime:
        progress = _evaluateOneTimeChallenge(challenge);
        break;
    }

    userChallenge.currentProgress = progress;

    // Check completion
    if (progress >= challenge.targetValue) {
      _completeChallenge(userChallenge, challenge);
    } else {
      // Check for failure (time expired)
      if (challenge.durationDays > 0) {
        final daysSinceStart =
            DateTime.now().difference(userChallenge.startedAt).inDays;
        if (daysSinceStart >= challenge.durationDays &&
            progress < challenge.targetValue) {
          _failChallenge(userChallenge);
        }
      }
    }

    _userChallengeBox.put(userChallenge.id, userChallenge);
  }

  int _evaluateSpendingChallenge(
      Challenge challenge, UserChallenge userChallenge) {
    final transactions = _financialContext.allTransactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.isAfter(userChallenge.startedAt))
        .toList();

    switch (challenge.id) {
      case 'sp_01': // Frugal Day - no spending for 24h
      case 'sp_02': // No-spend weekend
      case 'sp_06': // Expense freeze
        // Count consecutive no-spend days since start
        int noSpendDays = 0;
        DateTime checkDate = DateTime(userChallenge.startedAt.year,
            userChallenge.startedAt.month, userChallenge.startedAt.day);
        final now = DateTime.now();

        while (!checkDate.isAfter(now)) {
          final dayTransactions = transactions
              .where((t) =>
                  t.date.year == checkDate.year &&
                  t.date.month == checkDate.month &&
                  t.date.day == checkDate.day)
              .toList();

          if (dayTransactions.isEmpty) {
            noSpendDays++;
          } else {
            break; // Streak broken
          }
          checkDate = checkDate.add(const Duration(days: 1));
        }
        return noSpendDays;

      case 'sp_03': // Minimalist week - spend under 10K
        final totalSpent = transactions.fold(0.0, (sum, t) => sum + t.amount);
        // Return inverse progress (lower is better)
        return totalSpent <= challenge.targetValue ? challenge.targetValue : 0;

      default:
        return 0;
    }
  }

  int _evaluateSavingChallenge(
      Challenge challenge, UserChallenge userChallenge) {
    // Savings = Income - Expenses since challenge start
    final transactions = _financialContext.allTransactions
        .where((t) => t.date.isAfter(userChallenge.startedAt))
        .toList();

    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final saved = income - expenses;
    return saved.round();
  }

  int _evaluateBudgetChallenge(
      Challenge challenge, UserChallenge userChallenge) {
    // Check if all budgets are under limit
    final budgets = _financialContext.allBudgets.toList();
    if (budgets.isEmpty) return 0;

    int daysUnderBudget = 0;
    DateTime checkDate = DateTime(userChallenge.startedAt.year,
        userChallenge.startedAt.month, userChallenge.startedAt.day);
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    while (!checkDate.isAfter(now)) {
      bool allBudgetsOk = true;
      for (final budget in budgets) {
        // Calculate spending for this budget's category
        final spent = _financialContext.allTransactions
            .where((t) =>
                t.type == TransactionType.expense &&
                t.categoryId == budget.categoryId &&
                t.date.isAfter(startOfMonth))
            .fold(0.0, (sum, t) => sum + t.amount);
        if (spent > budget.amount) {
          allBudgetsOk = false;
          break;
        }
      }
      if (allBudgetsOk) {
        daysUnderBudget++;
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }

    return daysUnderBudget;
  }

  int _evaluateOneTimeChallenge(Challenge challenge) {
    switch (challenge.targetUnit) {
      case 'transactions':
        return _financialContext.allTransactions.length;
      case 'budgets':
        return _financialContext.allBudgets.length;
      case 'goals':
        return _financialContext.allGoals.length;
      case 'debts':
        return _financialContext.allDebts.where((d) => d.isPaidOff).length;
      case 'categories':
        return _financialContext.allTransactions
            .map((t) => t.categoryId)
            .where((id) => id != null)
            .toSet()
            .length;
      default:
        return 0;
    }
  }

  void _checkOneTimeAchievements() {
    for (final challenge
        in allChallenges.where((c) => c.type == ChallengeType.oneTime)) {
      // Skip if already completed
      if (completedChallenges.any((c) => c.challengeId == challenge.id))
        continue;

      final progress = _evaluateOneTimeChallenge(challenge);
      if (progress >= challenge.targetValue) {
        // Auto-complete one-time achievement
        final userChallenge = UserChallenge(
          challengeId: challenge.id,
          currentProgress: progress,
        );
        _completeChallenge(userChallenge, challenge);
        _userChallengeBox.put(userChallenge.id, userChallenge);
      }
    }
  }

  Future<void> _completeChallenge(
      UserChallenge userChallenge, Challenge challenge) async {
    userChallenge.completedAt = DateTime.now();
    userChallenge.isActive = false;
    userChallenge.currentProgress = challenge.targetValue;

    // Move from active to completed
    activeChallenges.removeWhere((c) => c.id == userChallenge.id);
    completedChallenges.add(userChallenge);

    // Add points
    totalPoints.value += challenge.rewardPoints;

    // Award badge if applicable
    if (challenge.badgeId != null) {
      await _awardBadge(challenge.badgeId!, userChallenge.challengeId);
    }

    // Celebrate!
    Get.snackbar(
      'Défi Complété! 🎉',
      challenge.title,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );

    _updateAvailableChallenges();
  }

  Future<void> _failChallenge(UserChallenge userChallenge) async {
    userChallenge.isActive = false;
    userChallenge.isFailed = true;
    activeChallenges.removeWhere((c) => c.id == userChallenge.id);
    _updateAvailableChallenges();
  }

  Future<void> _awardBadge(String badgeId, String challengeId) async {
    // Check if already earned
    if (earnedBadges.any((b) => b.badgeId == badgeId)) return;

    final userBadge = UserBadge(
      badgeId: badgeId,
      challengeId: challengeId,
    );

    await _userBadgeBox.put(userBadge.id, userBadge);
    earnedBadges.add(userBadge);
  }

  // Get display data for a challenge
  Map<String, dynamic> getChallengeDisplayData(Challenge challenge) {
    final userChallenge =
        activeChallenges.firstWhereOrNull((c) => c.challengeId == challenge.id);
    final completed = completedChallenges
        .firstWhereOrNull((c) => c.challengeId == challenge.id);

    return {
      'challenge': challenge,
      'isActive': userChallenge != null,
      'isCompleted': completed != null,
      'progress':
          userChallenge?.currentProgress ?? completed?.currentProgress ?? 0,
      'progressPercent':
          ((userChallenge?.currentProgress ?? 0) / challenge.targetValue)
              .clamp(0.0, 1.0),
    };
  }

  // Get challenges by type
  List<Challenge> getChallengesByType(ChallengeType type) {
    return allChallenges.where((c) => c.type == type).toList();
  }

  // Get challenges by difficulty
  List<Challenge> getChallengesByDifficulty(ChallengeDifficulty difficulty) {
    return allChallenges.where((c) => c.difficulty == difficulty).toList();
  }
}
