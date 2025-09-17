// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String,
  accountId: json['account_id'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  merchant: json['merchant'] as String?,
  description: json['description'] as String?,
  category: json['category'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  linkedLoanId: json['linked_loan_id'] as String?,
  annotation: json['annotation'] as String?,
  receiptUrl: json['receipt_url'] as String?,
  imported: json['imported'] as bool?,
  affectsBalance: json['affects_balance'] as bool?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'amount': instance.amount,
      'currency': instance.currency,
      'timestamp': instance.timestamp.toIso8601String(),
      'merchant': instance.merchant,
      'description': instance.description,
      'category': instance.category,
      'tags': instance.tags,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'linked_loan_id': instance.linkedLoanId,
      'annotation': instance.annotation,
      'receipt_url': instance.receiptUrl,
      'imported': instance.imported,
      'affects_balance': instance.affectsBalance,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.income: 'income',
  TransactionType.transfer: 'transfer',
  TransactionType.loan: 'loan',
  TransactionType.repayment: 'repayment',
};
