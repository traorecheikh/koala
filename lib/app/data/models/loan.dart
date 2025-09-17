import 'package:json_annotation/json_annotation.dart';

part 'loan.g.dart';

@JsonSerializable()
class Loan {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final double principal;
  @JsonKey(name: 'interest_rate')
  final double interestRate;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'term_months')
  final int termMonths;
  @JsonKey(name: 'monthly_due')
  final double monthlyDue;
  @JsonKey(name: 'remaining_balance')
  final double remainingBalance;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Loan({
    required this.id,
    required this.userId,
    required this.principal,
    required this.interestRate,
    required this.startDate,
    required this.termMonths,
    required this.monthlyDue,
    required this.remainingBalance,
    this.notes,
    required this.createdAt,
  });

  factory Loan.fromJson(Map<String, dynamic> json) => _$LoanFromJson(json);
  Map<String, dynamic> toJson() => _$LoanToJson(this);
}