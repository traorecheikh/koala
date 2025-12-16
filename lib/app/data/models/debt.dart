import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

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
  final String id;

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

  @HiveField(8)
  double minPayment; // Renamed from monthlyPayment to minPayment

  @HiveField(9)
  int? dueDayOfMonth; // For monthly repayment schedules

  Debt({
    String? id,
    required this.personName,
    required this.originalAmount,
    double? remainingAmount,
    required this.type,
    this.dueDate,
    DateTime? createdAt,
    this.transactionIds = const [],
    this.minPayment = 0.0,
    this.dueDayOfMonth,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        remainingAmount = remainingAmount ?? originalAmount;

  bool get isPaidOff => remainingAmount <= 0;

  double get paidAmount => originalAmount - remainingAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personName': personName,
      'originalAmount': originalAmount,
      'remainingAmount': remainingAmount,
      'type': type.toString().split('.').last,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'transactionIds': transactionIds,
      'minPayment': minPayment,
      'dueDayOfMonth': dueDayOfMonth,
    };
  }

  Debt copyWith({
    String? id,
    String? personName,
    double? originalAmount,
    double? remainingAmount,
    DebtType? type,
    DateTime? dueDate,
    DateTime? createdAt,
    List<String>? transactionIds,
    double? minPayment,
    int? dueDayOfMonth,
  }) {
    return Debt(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      originalAmount: originalAmount ?? this.originalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      transactionIds: transactionIds ?? this.transactionIds,
      minPayment: minPayment ?? this.minPayment,
      dueDayOfMonth: dueDayOfMonth ?? this.dueDayOfMonth,
    );
  }
}
