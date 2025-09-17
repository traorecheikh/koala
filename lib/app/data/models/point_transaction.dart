import 'package:json_annotation/json_annotation.dart';

part 'point_transaction.g.dart';

@JsonSerializable()
class PointTransaction {
  final String id;
  final String userId;
  final int change;
  final String reason;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  PointTransaction({
    required this.id,
    required this.userId,
    required this.change,
    required this.reason,
    this.metadata,
    required this.createdAt,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) =>
      _$PointTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$PointTransactionToJson(this);
}