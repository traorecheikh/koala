// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InsightResponse _$InsightResponseFromJson(Map<String, dynamic> json) =>
    InsightResponse(
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => Suggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InsightResponseToJson(InsightResponse instance) =>
    <String, dynamic>{'suggestions': instance.suggestions};

Suggestion _$SuggestionFromJson(Map<String, dynamic> json) => Suggestion(
  title: json['title'] as String,
  estimatedMonthlySaving: (json['estimated_monthly_saving'] as num).toDouble(),
  priority: json['priority'] as String,
  steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$SuggestionToJson(Suggestion instance) =>
    <String, dynamic>{
      'title': instance.title,
      'estimated_monthly_saving': instance.estimatedMonthlySaving,
      'priority': instance.priority,
      'steps': instance.steps,
    };
