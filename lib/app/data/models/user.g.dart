// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  salary: (json['salary'] as num).toDouble(),
  payDay: (json['pay_day'] as num).toInt(),
  openingBalance: (json['opening_balance'] as num).toDouble(),
  currentBalance: (json['current_balance'] as num).toDouble(),
  currency: json['currency'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'salary': instance.salary,
  'pay_day': instance.payDay,
  'opening_balance': instance.openingBalance,
  'current_balance': instance.currentBalance,
  'currency': instance.currency,
  'created_at': instance.createdAt.toIso8601String(),
};
