import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final String id;
  final String provider;
  final String name;
  final double balance;
  final Map<String, dynamic>? details;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Account({
    required this.id,
    required this.provider,
    required this.name,
    required this.balance,
    this.details,
    required this.createdAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
  Map<String, dynamic> toJson() => _$AccountToJson(this);
}