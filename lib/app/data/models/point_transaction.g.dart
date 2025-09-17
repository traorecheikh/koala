// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointTransaction _$PointTransactionFromJson(Map<String, dynamic> json) =>
    PointTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      change: (json['change'] as num).toInt(),
      reason: json['reason'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PointTransactionToJson(PointTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'change': instance.change,
      'reason': instance.reason,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
    };
