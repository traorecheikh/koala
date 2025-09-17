import 'package:json_annotation/json_annotation.dart';

part 'notification_template.g.dart';

@JsonSerializable()
class NotificationTemplate {
  final String templateName;
  final Map<String, dynamic>? params;

  NotificationTemplate({required this.templateName, this.params});

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) =>
      _$NotificationTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationTemplateToJson(this);
}