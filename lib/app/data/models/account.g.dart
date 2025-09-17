// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  id: json['id'] as String,
  provider: json['provider'] as String,
  name: json['name'] as String,
  balance: (json['balance'] as num).toDouble(),
  details: json['details'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'id': instance.id,
  'provider': instance.provider,
  'name': instance.name,
  'balance': instance.balance,
  'details': instance.details,
  'created_at': instance.createdAt.toIso8601String(),
};
