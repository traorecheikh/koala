// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  id: json['id'] as String,
  userId: json['userId'] as String,
  fcmToken: json['fcmToken'] as String,
  platform: json['platform'] as String,
  lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'fcmToken': instance.fcmToken,
  'platform': instance.platform,
  'lastSeenAt': instance.lastSeenAt.toIso8601String(),
  'metadata': instance.metadata,
};
