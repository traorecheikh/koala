import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

part 'financial_goal.g.dart';

@HiveType(typeId: 51)
enum GoalType {
  @HiveField(0)
  savings,
  @HiveField(1)
  debtPayoff,
  @HiveField(2)
  purchase,
  @HiveField(3)
  custom,
}

@HiveType(typeId: 52)
enum GoalStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  completed,
  @HiveField(2)
  paused,
  @HiveField(3)
  abandoned,
}

@HiveType(typeId: 50)
class FinancialGoal extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String? description;
  @HiveField(3)
  double targetAmount;
  @HiveField(4)
  double currentAmount;
  @HiveField(5)
  GoalType type;
  @HiveField(6)
  GoalStatus status;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  DateTime? targetDate;
  @HiveField(9)
  DateTime? completedAt;
  @HiveField(10)
  String? linkedDebtId;
  @HiveField(11)
  String? linkedCategoryId; // For purchase goals or specific savings categories
  @HiveField(12)
  List<GoalMilestone> milestones;
  @HiveField(13)
  int? iconKey; // For custom icons
  @HiveField(14)
  int? colorValue; // For custom color

  FinancialGoal({
    String? id,
    required this.title,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.type = GoalType.savings,
    this.status = GoalStatus.active,
    DateTime? createdAt,
    this.targetDate,
    this.completedAt,
    this.linkedDebtId,
    this.linkedCategoryId,
    List<GoalMilestone>? milestones,
    this.iconKey,
    this.colorValue,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        milestones = milestones ?? <GoalMilestone>[];

  double get progressPercentage =>
      (currentAmount / targetAmount * 100).clamp(0.0, 100.0);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'linkedDebtId': linkedDebtId,
      'linkedCategoryId': linkedCategoryId,
      'milestones': milestones.map((e) => e.toJson()).toList(),
      'iconKey': iconKey,
      'colorValue': colorValue,
    };
  }

  FinancialGoal copyWith({
    String? id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    GoalType? type,
    GoalStatus? status,
    DateTime? createdAt,
    DateTime? targetDate,
    DateTime? completedAt,
    String? linkedDebtId,
    String? linkedCategoryId,
    List<GoalMilestone>? milestones,
    int? iconKey,
    int? colorValue,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      completedAt: completedAt ?? this.completedAt,
      linkedDebtId: linkedDebtId ?? this.linkedDebtId,
      linkedCategoryId: linkedCategoryId ?? this.linkedCategoryId,
      milestones: milestones ?? this.milestones,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}

@HiveType(typeId: 53)
class GoalMilestone extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime? completedAt;

  GoalMilestone({
    String? id,
    required this.title,
    required this.targetAmount,
    this.isCompleted = false,
    this.completedAt,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  GoalMilestone copyWith({
    String? id,
    String? title,
    double? targetAmount,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return GoalMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
