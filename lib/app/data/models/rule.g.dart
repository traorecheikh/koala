// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rule _$RuleFromJson(Map<String, dynamic> json) => Rule(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  pattern: json['pattern'] as Map<String, dynamic>,
  category: json['category'] as String,
  priority: (json['priority'] as num).toInt(),
);

Map<String, dynamic> _$RuleToJson(Rule instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'pattern': instance.pattern,
  'category': instance.category,
  'priority': instance.priority,
};
