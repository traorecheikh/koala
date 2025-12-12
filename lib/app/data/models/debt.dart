import 'package:hive_ce/hive.dart';

part 'debt.g.dart';

@HiveType(typeId: 41)
enum DebtType {
  @HiveField(0)
  lent, // I lent money (Asset)
  @HiveField(1)
  borrowed, // I borrowed money (Liability)
}

@HiveType(typeId: 42)
class Debt extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String personName;

  @HiveField(2)
  double originalAmount;

  @HiveField(3)
  double remainingAmount;

  @HiveField(4)
  DebtType type;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  List<String> transactionIds; // IDs of repayment transactions

  Debt({
    required this.id,
    required this.personName,
    required this.originalAmount,
    required this.remainingAmount,
    required this.type,
    this.dueDate,
    required this.createdAt,
    this.transactionIds = const [],
  });
}
