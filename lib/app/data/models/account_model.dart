import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'account_model.g.dart';

/// Account model for storing user financial accounts
@HiveType(typeId: 1)
@JsonSerializable()
class AccountModel extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'user_id')
  final String userId;

  @HiveField(2)
  @JsonKey(name: 'name')
  final String name;

  @HiveField(3)
  @JsonKey(name: 'provider')
  final String provider;

  @HiveField(4)
  @JsonKey(name: 'balance')
  final double balance;

  @HiveField(5)
  @JsonKey(name: 'account_type')
  final String accountType;

  @HiveField(6)
  @JsonKey(name: 'is_active')
  final bool isActive;

  @HiveField(7)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(8)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  AccountModel({
    String? id,
    required this.userId,
    required this.name,
    required this.provider,
    this.balance = 0.0,
    this.accountType = 'savings',
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountModelToJson(this);

  /// Create a copy with updated fields
  AccountModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? provider,
    double? balance,
    String? accountType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      balance: balance ?? this.balance,
      accountType: accountType ?? this.accountType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'AccountModel(id: $id, name: $name, balance: $balance)';
  }
}
