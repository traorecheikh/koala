import 'package:json_annotation/json_annotation.dart';

part 'rule.g.dart';

@JsonSerializable()
class Rule {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final Map<String, dynamic> pattern;
  final String category;
  final int priority;

  Rule({
    required this.id,
    required this.userId,
    required this.pattern,
    required this.category,
    required this.priority,
  });

  factory Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);
  Map<String, dynamic> toJson() => _$RuleToJson(this);
}