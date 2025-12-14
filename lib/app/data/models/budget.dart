import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

part 'budget.g.dart';

@HiveType(typeId: 40)
class Budget extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String categoryId; // Links to Category model

  @HiveField(2)
  double amount; // The limit

  @HiveField(5)
  int year;

  @HiveField(6)
  int month;

  Budget({
    String? id,
    required this.categoryId,
    required this.amount,
    required this.year,
    required this.month,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'year': year,
      'month': month,
    };
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    double? amount,
    int? year,
    int? month,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }
}


