import 'package:hive_ce/hive.dart';

part 'user_financial_profile.g.dart';

@HiveType(typeId: 31)
class UserFinancialProfile extends HiveObject {
  @HiveField(0)
  String personaType; // Saver, Spender, Planner, etc. or 'unknown'

  @HiveField(1)
  double savingsRate;

  @HiveField(2)
  double consistencyScore;

  @HiveField(3)
  Map<String, double> categoryPreferences;

  @HiveField(4)
  List<String> detectedPatterns;

  @HiveField(5)
  double weekendRatio;

  @HiveField(6)
  double nightRatio;

  @HiveField(7)
  String dominantCategory;

  @HiveField(8)
  double averageAmount;

  @HiveField(9)
  String dataQuality; // 'high', 'medium', 'low' - indicates data reliability

  @HiveField(10)
  int transactionCount; // Number of transactions used for profiling

  UserFinancialProfile({
    required this.personaType,
    required this.savingsRate,
    required this.consistencyScore,
    required this.categoryPreferences,
    required this.detectedPatterns,
    this.weekendRatio = 0.0,
    this.nightRatio = 0.0,
    this.dominantCategory = 'Autre',
    this.averageAmount = 0.0,
    this.dataQuality = 'low',
    this.transactionCount = 0,
  });
}
