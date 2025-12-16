import 'package:hive_ce/hive.dart';

part 'ai_learning_profile.g.dart';

@HiveType(typeId: 20) // Use a new unique TypeID
class AILearningProfile extends HiveObject {
  @HiveField(0)
  Map<String, int> dismissedAlertCounts; // AlertType -> Count

  @HiveField(1)
  Map<String, DateTime> mutedAlertsUntil; // AlertType -> Unmute Date

  @HiveField(2)
  Map<String, String> categoryPreferences; // Merchant -> CategoryID

  AILearningProfile({
    Map<String, int>? dismissedAlertCounts,
    Map<String, DateTime>? mutedAlertsUntil,
    Map<String, String>? categoryPreferences,
  })  : dismissedAlertCounts = dismissedAlertCounts ?? {},
        mutedAlertsUntil = mutedAlertsUntil ?? {},
        categoryPreferences = categoryPreferences ?? {};
}
