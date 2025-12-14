import 'package:hive_ce/hive.dart';

part 'financial_pattern.g.dart';

@HiveType(typeId: 32)
class FinancialPattern extends HiveObject {
  @HiveField(0)
  String patternType; // Recurring, Merchant, Burst, etc.

  @HiveField(1)
  String description;

  @HiveField(2)
  double confidence;

  @HiveField(3)
  Map<String, String> parameters;

  @HiveField(4)
  bool isActive;

  FinancialPattern({
    required this.patternType,
    required this.description,
    required this.confidence,
    required this.parameters,
    this.isActive = true,
  });
}
