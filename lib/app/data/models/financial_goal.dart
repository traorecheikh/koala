import 'package:isar_plus/isar_plus.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:koaa/app/services/isar_service.dart';

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

@Collection()
@HiveType(typeId: 50)
class FinancialGoal {
  @Id()
  @HiveField(0)
  String id;

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
  DateTime createdAt;

  @HiveField(8)
  DateTime? targetDate;

  @HiveField(9)
  DateTime? completedAt;

  @HiveField(10)
  String? linkedDebtId;

  @HiveField(11)
  String? linkedCategoryId;

  @Ignore()
  @HiveField(12)
  List<GoalMilestone> milestones;

  @HiveField(13)
  int? iconKey;

  @HiveField(14)
  int? colorValue;

  FinancialGoal({
    required this.id,
    required this.title,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.type = GoalType.savings,
    this.status = GoalStatus.active,
    required this.createdAt,
    this.targetDate,
    this.completedAt,
    this.linkedDebtId,
    this.linkedCategoryId,
    List<GoalMilestone>? milestones,
    this.iconKey,
    this.colorValue,
  }) : milestones = milestones ?? <GoalMilestone>[];

  /// Factory constructor for creating with auto-generated ID and timestamp
  factory FinancialGoal.create({
    required String title,
    String? description,
    required double targetAmount,
    double currentAmount = 0.0,
    GoalType type = GoalType.savings,
    GoalStatus status = GoalStatus.active,
    DateTime? targetDate,
    DateTime? completedAt,
    String? linkedDebtId,
    String? linkedCategoryId,
    List<GoalMilestone>? milestones,
    int? iconKey,
    int? colorValue,
  }) {
    return FinancialGoal(
      id: const Uuid().v4(),
      title: title,
      description: description,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      type: type,
      status: status,
      createdAt: DateTime.now(),
      targetDate: targetDate,
      completedAt: completedAt,
      linkedDebtId: linkedDebtId,
      linkedCategoryId: linkedCategoryId,
      milestones: milestones,
      iconKey: iconKey,
      colorValue: colorValue,
    );
  }

  /// Save this goal to Isar
  Future<void> save() async {
    IsarService.updateGoal(this);
  }

  /// Delete this goal from Isar
  Future<void> delete() async {
    IsarService.deleteGoal(id);
  }

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
