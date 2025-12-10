import 'package:hive_ce/hive.dart';

part 'savings_goal.g.dart';

@HiveType(typeId: 11)
class SavingsGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  int year;

  @HiveField(3)
  int month;

  @HiveField(4)
  DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.targetAmount,
    required this.year,
    required this.month,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  SavingsGoal copyWith({
    String? id,
    double? targetAmount,
    int? year,
    int? month,
    DateTime? createdAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      targetAmount: targetAmount ?? this.targetAmount,
      year: year ?? this.year,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
