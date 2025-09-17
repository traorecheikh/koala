import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user_model.g.dart';

/// User model for storing user profile and financial information
@HiveType(typeId: 0)
@JsonSerializable()
class UserModel extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'name')
  final String name;

  @HiveField(2)
  @JsonKey(name: 'phone')
  final String phone;

  @HiveField(3)
  @JsonKey(name: 'email')
  final String? email;

  @HiveField(4)
  @JsonKey(name: 'monthly_salary')
  final double monthlySalary;

  @HiveField(5)
  @JsonKey(name: 'current_balance')
  final double currentBalance;

  @HiveField(6)
  @JsonKey(name: 'pay_day')
  final int payDay;

  @HiveField(7)
  @JsonKey(name: 'biometric_enabled')
  final bool biometricEnabled;

  @HiveField(8)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(9)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  UserModel({
    String? id,
    required this.name,
    required this.phone,
    this.email,
    required this.monthlySalary,
    required this.currentBalance,
    required this.payDay,
    this.biometricEnabled = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    double? monthlySalary,
    double? currentBalance,
    int? payDay,
    bool? biometricEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      currentBalance: currentBalance ?? this.currentBalance,
      payDay: payDay ?? this.payDay,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, phone: $phone, balance: $currentBalance)';
  }
}
