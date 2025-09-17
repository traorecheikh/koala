// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Loan _$LoanFromJson(Map<String, dynamic> json) => Loan(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  principal: (json['principal'] as num).toDouble(),
  interestRate: (json['interest_rate'] as num).toDouble(),
  startDate: DateTime.parse(json['start_date'] as String),
  termMonths: (json['term_months'] as num).toInt(),
  monthlyDue: (json['monthly_due'] as num).toDouble(),
  remainingBalance: (json['remaining_balance'] as num).toDouble(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$LoanToJson(Loan instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'principal': instance.principal,
  'interest_rate': instance.interestRate,
  'start_date': instance.startDate.toIso8601String(),
  'term_months': instance.termMonths,
  'monthly_due': instance.monthlyDue,
  'remaining_balance': instance.remainingBalance,
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
};
