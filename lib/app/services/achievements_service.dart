import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/challenge.dart';
import 'package:koaa/app/data/models/challenge_definitions.dart';

import 'package:koaa/app/modules/challenges/widgets/achievement_toast.dart';
import 'package:koaa/app/modules/challenges/widgets/streak_popup.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:logger/logger.dart';

class AchievementsService extends GetxService {
  final _logger = Logger();
  late Box<UserBadge> _userBadgeBox;
  late Box<UserChallenge> _userChallengeBox;
  final _financialContext = Get.find<FinancialContextService>();

  final RxList<UserBadge> earnedBadges = <UserBadge>[].obs;
  final RxInt currentStreak = 0.obs;

  late Box _settingsBox;

  @override
  void onInit() {
    super.onInit();
    _initBoxes();
    _setupListeners();
  }

  Future<void> _initBoxes() async {
    _userBadgeBox = Hive.box<UserBadge>('userBadgeBox');
    _userChallengeBox = Hive.box<UserChallenge>('userChallengeBox');
    // Ensure settings box is open for streak tracking
    if (!Hive.isBoxOpen('settingsBox')) {
      _settingsBox = await Hive.openBox('settingsBox');
    } else {
      _settingsBox = Hive.box('settingsBox');
    }

    earnedBadges.assignAll(_userBadgeBox.values.toList());
    currentStreak.value = _settingsBox.get('currentStreak', defaultValue: 0);
  }

  void _setupListeners() {
    // Listen to all transactions to trigger checks
    ever(_financialContext.allTransactions,
        (_) => _checkTransactionMilestones());

    // Listen for budget updates
    ever(_financialContext.allBudgets, (_) => _checkBudgetMilestones());

    // Listen for savings goals
    ever(_financialContext.allGoals, (_) => _checkSavingsMilestones());

    // Check streak on startup
    _checkDailyStreak();
  }

  /// --------------------------------------------------------------------------
  /// LOGIC: STREAKS
  /// --------------------------------------------------------------------------
  Future<void> _checkDailyStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastStreakDateStr = _settingsBox.get('lastStreakDate');
    DateTime? lastStreakDate;
    if (lastStreakDateStr != null) {
      lastStreakDate = DateTime.parse(lastStreakDateStr);
    }

    if (lastStreakDate == null) {
      // First time
      _settingsBox.put('lastStreakDate', today.toIso8601String());
      _settingsBox.put('currentStreak', 1);
      currentStreak.value = 1;
      return;
    }

    if (lastStreakDate.isAtSameMomentAs(today)) {
      // Already counted today
      return;
    }

    final difference = today.difference(lastStreakDate).inDays;

    if (difference == 1) {
      // Streak continues
      final newStreak = (currentStreak.value) + 1;
      _settingsBox.put('currentStreak', newStreak);
      currentStreak.value = newStreak;

      // Show Popup for streaks > 1
      Future.delayed(const Duration(seconds: 1), () {
        StreakPopup.show(newStreak);
      });

      // Check for streak achievements
      if (newStreak >= 3) _unlockChallenge('st_01');
      if (newStreak >= 7) _unlockChallenge('st_02');
      if (newStreak >= 30) _unlockChallenge('st_04');
    } else {
      // Streak broken
      _settingsBox.put('currentStreak', 1);
      currentStreak.value = 1;
    }

    // Update last date
    _settingsBox.put('lastStreakDate', today.toIso8601String());
  }

  /// --------------------------------------------------------------------------
  /// LOGIC: MILESTONES
  /// --------------------------------------------------------------------------
  void _checkTransactionMilestones() {
    final count = _financialContext.allTransactions.length;

    // 1. One-Time: First Transaction
    if (count >= 1) _unlockChallenge('ot_01');

    // 2. Milestones
    if (count >= 100) _unlockChallenge('ot_06');
    if (count >= 500) _unlockChallenge('ot_07');
  }

  void _checkBudgetMilestones() {
    if (_financialContext.allBudgets.isNotEmpty) {
      _unlockChallenge('ot_02'); // First budget
    }
  }

  void _checkSavingsMilestones() {
    if (_financialContext.allGoals.isNotEmpty) {
      _unlockChallenge('ot_03'); // First goal
    }

    // Check for million
    final totalSavings =
        _financialContext.allGoals.fold(0.0, (sum, g) => sum + g.currentAmount);
    if (totalSavings >= 1000000) _unlockChallenge('sv_10');
  }

  /// --------------------------------------------------------------------------
  /// CORE: UNLOCKING
  /// --------------------------------------------------------------------------
  void _unlockChallenge(String challengeId) {
    // Check if already completed
    final existingParams = _userChallengeBox.values
        .where((c) => c.challengeId == challengeId && c.isCompleted);
    if (existingParams.isNotEmpty) return;

    // Find definition
    final challenge =
        ChallengeDefinitions.all.firstWhereOrNull((c) => c.id == challengeId);
    if (challenge == null) return;

    _logger.i('🏆 Achievement Unlocked: ${challenge.title}');

    // Create UserChallenge record
    final userChallenge = UserChallenge(
      challengeId: challengeId,
      startedAt: DateTime.now(),
      completedAt: DateTime.now(),
      currentProgress: challenge.targetValue,
      isActive: false,
    );
    _userChallengeBox.add(userChallenge);

    // Provide Reward (Badge or Points)
    if (challenge.badgeId != null) {
      _awardBadge(challenge.badgeId!, challengeId);
    }

    // Trigger UI Notification (Toast)
    _showAchievementNotification(challenge);
  }

  void _awardBadge(String badgeId, String challengeId) {
    if (earnedBadges.any((b) => b.badgeId == badgeId)) return;

    final badge = UserBadge(badgeId: badgeId, challengeId: challengeId);
    _userBadgeBox.add(badge);
    earnedBadges.add(badge);
    _logger.i('🎖️ Badge Awarded: $badgeId');
  }

  void _showAchievementNotification(Challenge challenge) {
    AchievementToast.show(
      title: 'Succès Déverrouillé !',
      description: challenge.title,
      points: challenge.rewardPoints,
    );
  }
}
