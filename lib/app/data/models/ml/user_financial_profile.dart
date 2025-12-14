import 'package:hive_ce/hive.dart';

part 'user_financial_profile.g.dart';

@HiveType(typeId: 31)
class UserFinancialProfile extends HiveObject {
  @HiveField(0)
  String personaType; // Saver, Spender, Planner, etc.

  @HiveField(1)
  double savingsRate;

  @HiveField(2)
  double consistencyScore;

  @HiveField(3)
  Map<String, double> categoryPreferences;

  @HiveField(4)
  List<String> detectedPatterns;

  UserFinancialProfile({
    required this.personaType,
    required this.savingsRate,
    required this.consistencyScore,
    required this.categoryPreferences,
    required this.detectedPatterns,
  });
}
