import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

enum TransactionType {
  expense,
  income,
  transfer,
  loan,
  repayment,
}

@JsonSerializable()
class Transaction {
  final String id;
  @JsonKey(name: 'account_id')
  final String accountId;
  final double amount;
  final String currency;
  final DateTime timestamp;
  final String? merchant;
  final String? description;
  final String? category;
  final List<String>? tags;
  final TransactionType type;
  @JsonKey(name: 'linked_loan_id')
  final String? linkedLoanId;
  final String? annotation;
  @JsonKey(name: 'receipt_url')
  final String? receiptUrl;
  final bool? imported;
  @JsonKey(name: 'affects_balance')
  final bool? affectsBalance;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.currency,
    required this.timestamp,
    this.merchant,
    this.description,
    this.category,
    this.tags,
    required this.type,
    this.linkedLoanId,
    this.annotation,
    this.receiptUrl,
    this.imported,
    this.affectsBalance,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}