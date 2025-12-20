import 'package:isar_plus/isar_plus.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:koaa/app/services/isar_service.dart';

part 'savings_goal.g.dart';

@Collection()
@HiveType(typeId: 11)
class SavingsGoal {
  @Id()
  @HiveField(0)
  String id;

  @Index()
  @HiveField(3)
  int year;

  @Index()
  @HiveField(4)
  int month;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.targetAmount,
    required this.year,
    required this.month,
    required this.createdAt,
  });

  /// Factory constructor for creating with auto-generated ID and timestamp
  factory SavingsGoal.create({
    required double targetAmount,
    required int year,
    required int month,
  }) {
    return SavingsGoal(
      id: const Uuid().v4(),
      targetAmount: targetAmount,
      year: year,
      month: month,
      createdAt: DateTime.now(),
    );
  }

  /// Save this savings goal to Isar
  Future<void> save() async {
    await IsarService.updateSavingsGoal(this);
  }

  /// Delete this savings goal from Isar
  Future<void> delete() async {
    await IsarService.deleteSavingsGoal(id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetAmount': targetAmount,
      'year': year,
      'month': month,
      'createdAt': createdAt.toIso8601String(),
    };
  }

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
