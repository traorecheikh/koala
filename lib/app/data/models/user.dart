import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String phone;
  final double salary;
  @JsonKey(name: 'pay_day')
  final int payDay;
  @JsonKey(name: 'opening_balance')
  final double openingBalance;
  @JsonKey(name: 'current_balance')
  final double currentBalance;
  final String currency;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.salary,
    required this.payDay,
    required this.openingBalance,
    required this.currentBalance,
    required this.currency,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}