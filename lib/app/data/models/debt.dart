import 'package:isar_plus/isar_plus.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:koaa/app/services/isar_service.dart';

part 'debt.g.dart';

@HiveType(typeId: 41)
enum DebtType {
  @HiveField(0)
  lent, // I lent money (Asset)
  @HiveField(1)
  borrowed, // I borrowed money (Liability)
}

@Collection()
@HiveType(typeId: 42)
class Debt {
  @Id()
  @HiveField(0)
  String id;

  @Index()
  @HiveField(1)
  String personName;

  @HiveField(2)
  double originalAmount;

  @HiveField(3)
  double remainingAmount;

  @Index()
  @HiveField(4)
  DebtType type;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  List<String> transactionIds; // IDs of repayment transactions

  @HiveField(8)
  double minPayment;

  @HiveField(9)
  int? dueDayOfMonth; // For monthly repayment schedules

  Debt({
    required this.id,
    required this.personName,
    required this.originalAmount,
    required this.remainingAmount,
    required this.type,
    this.dueDate,
    required this.createdAt,
    this.transactionIds = const [],
    this.minPayment = 0.0,
    this.dueDayOfMonth,
  });

  /// Factory constructor for creating with auto-generated ID and timestamp
  factory Debt.create({
    required String personName,
    required double originalAmount,
    double? remainingAmount,
    required DebtType type,
    DateTime? dueDate,
    List<String> transactionIds = const [],
    double minPayment = 0.0,
    int? dueDayOfMonth,
  }) {
    return Debt(
      id: const Uuid().v4(),
      personName: personName,
      originalAmount: originalAmount,
      remainingAmount: remainingAmount ?? originalAmount,
      type: type,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      transactionIds: transactionIds,
      minPayment: minPayment,
      dueDayOfMonth: dueDayOfMonth,
    );
  }

  /// Save this debt to Isar
  Future<void> save() async {
    IsarService.updateDebt(this);
  }

  /// Delete this debt from Isar
  Future<void> delete() async {
    IsarService.deleteDebt(id);
  }

  @Ignore()
  bool get isPaidOff => remainingAmount <= 0;

  @Ignore()
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
