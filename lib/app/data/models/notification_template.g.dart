// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationTemplate _$NotificationTemplateFromJson(
  Map<String, dynamic> json,
) => NotificationTemplate(
  templateName: json['templateName'] as String,
  params: json['params'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$NotificationTemplateToJson(
  NotificationTemplate instance,
) => <String, dynamic>{
  'templateName': instance.templateName,
  'params': instance.params,
};
