import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/services/intelligence/ai_learning_profile.dart';
import 'package:logger/logger.dart';

class AILearningService extends GetxService {
  final _logger = Logger();
  late Box<AILearningProfile> _box;
  late AILearningProfile _profile;

  static const String boxName = 'aiLearningBox';
  static const String profileKey = 'user_learning_profile';

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initStorage();
  }

  Future<void> _initStorage() async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox<AILearningProfile>(boxName);
    } else {
      _box = Hive.box<AILearningProfile>(boxName);
    }

    if (_box.isEmpty) {
      _profile = AILearningProfile();
      await _box.put(profileKey, _profile);
    } else {
      _profile = _box.get(profileKey) ?? AILearningProfile();
    }
    _logger.i('AILearningService initialized with profile.');
  }

  /// Record that the user dismissed an alert of a specific type.
  /// If dismissed 3 times, it mutes the alert for 30 days.
  Future<void> learnDismissal(String alertType) async {
    final currentCount = _profile.dismissedAlertCounts[alertType] ?? 0;
    final newCount = currentCount + 1;
    _profile.dismissedAlertCounts[alertType] = newCount;

    _logger.i('User dismissed alert "$alertType". Count: $newCount');

    // Threshold logic: 3 dismissals = Mute for 30 days
    if (newCount >= 3) {
      final muteUntil = DateTime.now().add(const Duration(days: 30));
      _profile.mutedAlertsUntil[alertType] = muteUntil;
      // Reset count so cycle can restart after unmute
      _profile.dismissedAlertCounts[alertType] = 0;
      _logger.i(
          'Alert "$alertType" muted until $muteUntil due to repeated dismissals.');
    }

    await _profile.save();
  }

  /// Check if we should show this alert based on past behavior.
  bool shouldShowAlert(String alertType) {
    // Check if muted
    final mutedUntil = _profile.mutedAlertsUntil[alertType];
    if (mutedUntil != null) {
      if (DateTime.now().isBefore(mutedUntil)) {
        // Still muted
        return false;
      } else {
        // Mute expired, clean up
        _profile.mutedAlertsUntil.remove(alertType);
        _profile.save(); // Fire and forget save
      }
    }

    return true;
  }

  /// Reset all learning data (e.g. for testing or user request)
  Future<void> resetLearning() async {
    _profile.dismissedAlertCounts.clear();
    _profile.mutedAlertsUntil.clear();
    _profile.categoryPreferences.clear();
    await _profile.save();
    _logger.i('AI Learning reset.');
  }
}
