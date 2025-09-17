import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'loan_model.g.dart';

/// Loan status enumeration
@HiveType(typeId: 5)
enum LoanStatus {
  @HiveField(0)
  active,

  @HiveField(1)
  completed,

  @HiveField(2)
  defaulted,

  @HiveField(3)
  pending,
}

/// Loan model for tracking loans and repayments
@HiveType(typeId: 4)
@JsonSerializable()
class LoanModel extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'user_id')
  final String userId;

  @HiveField(2)
  @JsonKey(name: 'title')
  final String? title;

  @HiveField(3)
  @JsonKey(name: 'principal_amount')
  final double principalAmount;

  @HiveField(4)
  @JsonKey(name: 'remaining_amount')
  final double remainingAmount;

  @HiveField(5)
  @JsonKey(name: 'interest_rate')
  final double interestRate;

  @HiveField(6)
  @JsonKey(name: 'monthly_payment')
  final double monthlyPayment;

  @HiveField(7)
  @JsonKey(name: 'start_date')
  final DateTime startDate;

  @HiveField(8)
  @JsonKey(name: 'end_date')
  final DateTime endDate;

  @HiveField(9)
  @JsonKey(name: 'next_payment_date')
  final DateTime nextPaymentDate;

  @HiveField(10)
  @JsonKey(name: 'status')
  final LoanStatus status;

  @HiveField(11)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(12)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  LoanModel({
    String? id,
    required this.userId,
    this.title,
    required this.principalAmount,
    required this.remainingAmount,
    this.interestRate = 0.0,
    required this.monthlyPayment,
    required this.startDate,
    required this.endDate,
    required this.nextPaymentDate,
    this.status = LoanStatus.active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory LoanModel.fromJson(Map<String, dynamic> json) =>
      _$LoanModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoanModelToJson(this);

  /// Check if loan is active
  bool get isActive => status == LoanStatus.active;

  /// Get loan progress percentage (0.0 to 1.0)
  double get progress {
    if (principalAmount == 0) return 1.0;
    return (principalAmount - remainingAmount) / principalAmount;
  }

  /// Create a copy with updated fields
  LoanModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? principalAmount,
    double? remainingAmount,
    double? interestRate,
    double? monthlyPayment,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextPaymentDate,
    LoanStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      principalAmount: principalAmount ?? this.principalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      interestRate: interestRate ?? this.interestRate,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'LoanModel(id: $id, principal: $principalAmount, remaining: $remainingAmount, status: $status)';
  }
}
