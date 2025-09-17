import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';

@JsonSerializable()
class Device {
  final String id;
  final String userId;
  final String fcmToken;
  final String platform;
  final DateTime lastSeenAt;
  final Map<String, dynamic>? metadata;

  Device({
    required this.id,
    required this.userId,
    required this.fcmToken,
    required this.platform,
    required this.lastSeenAt,
    this.metadata,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}