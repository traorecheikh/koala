import 'package:json_annotation/json_annotation.dart';

part 'insight_response.g.dart';

@JsonSerializable()
class InsightResponse {
  final List<Suggestion> suggestions;

  InsightResponse({required this.suggestions});

  factory InsightResponse.fromJson(Map<String, dynamic> json) =>
      _$InsightResponseFromJson(json);
  Map<String, dynamic> toJson() => _$InsightResponseToJson(this);
}

@JsonSerializable()
class Suggestion {
  final String title;
  @JsonKey(name: 'estimated_monthly_saving')
  final double estimatedMonthlySaving;
  final String priority;
  final List<String> steps;

  Suggestion({
    required this.title,
    required this.estimatedMonthlySaving,
    required this.priority,
    required this.steps,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) =>
      _$SuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$SuggestionToJson(this);
}