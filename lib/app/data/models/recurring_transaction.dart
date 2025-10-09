import 'package:hive_ce/hive.dart';

part 'recurring_transaction.g.dart';

@HiveType(typeId: 3)
enum Frequency {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  monthly,
}

@HiveType(typeId: 4)
class RecurringTransaction extends HiveObject {
  @HiveField(0)
  double amount;

  @HiveField(1)
  String description;

  @HiveField(2)
  Frequency frequency;

  @HiveField(3)
  List<int> daysOfWeek; // 1 for Monday, 7 for Sunday

  @HiveField(4)
  int dayOfMonth; // For monthly recurrence

  @HiveField(5)
  DateTime lastGeneratedDate;

  RecurringTransaction({
    required this.amount,
    required this.description,
    required this.frequency,
    this.daysOfWeek = const [],
    this.dayOfMonth = 1,
    required this.lastGeneratedDate,
  });
}
