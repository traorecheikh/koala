import 'package:hive_ce/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 40)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId; // Links to Category model

  @HiveField(2)
  double amount; // The limit

  @HiveField(3)
  String period; // 'monthly', 'weekly'

  @HiveField(4)
  DateTime startDate;

  Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.period = 'monthly',
    required this.startDate,
  });
}
