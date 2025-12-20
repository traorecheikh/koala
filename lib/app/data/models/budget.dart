import 'package:isar_plus/isar_plus.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:koaa/app/services/isar_service.dart';

part 'budget.g.dart';

@Collection()
@HiveType(typeId: 40)
class Budget {
  @Id()
  @HiveField(0)
  String id;

  @Index()
  @HiveField(1)
  String categoryId; // Links to Category model

  @HiveField(2)
  double amount; // The limit

  @HiveField(5)
  int year;

  @HiveField(6)
  int month;

  @HiveField(7)
  bool rolloverEnabled;

  Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.year,
    required this.month,
    this.rolloverEnabled = false,
  });

  /// Factory constructor for creating with auto-generated ID
  factory Budget.create({
    required String categoryId,
    required double amount,
    required int year,
    required int month,
    bool rolloverEnabled = false,
  }) {
    return Budget(
      id: const Uuid().v4(),
      categoryId: categoryId,
      amount: amount,
      year: year,
      month: month,
      rolloverEnabled: rolloverEnabled,
    );
  }

  /// Save this budget to Isar
  Future<void> save() async {
    IsarService.updateBudget(this);
  }

  /// Delete this budget from Isar
  Future<void> delete() async {
    IsarService.deleteBudget(id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'year': year,
      'month': month,
      'rolloverEnabled': rolloverEnabled,
    };
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    double? amount,
    int? year,
    int? month,
    bool? rolloverEnabled,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      year: year ?? this.year,
      month: month ?? this.month,
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
    );
  }
}
