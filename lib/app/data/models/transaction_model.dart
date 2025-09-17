import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'transaction_model.g.dart';

/// Transaction type enumeration
@HiveType(typeId: 3)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,

  @HiveField(2)
  transfer,

  @HiveField(3)
  loan,

  @HiveField(4)
  repayment,
}

/// Transaction model for storing financial transactions
@HiveType(typeId: 2)
@JsonSerializable()
class TransactionModel extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'user_id')
  final String userId;

  @HiveField(2)
  @JsonKey(name: 'account_id')
  final String? accountId;

  @HiveField(3)
  @JsonKey(name: 'amount')
  final double amount;

  @HiveField(4)
  @JsonKey(name: 'type')
  final TransactionType type;

  @HiveField(5)
  @JsonKey(name: 'description')
  final String description;

  @HiveField(6)
  @JsonKey(name: 'merchant')
  final String? merchant;

  @HiveField(7)
  @JsonKey(name: 'category')
  final String category;

  @HiveField(8)
  @JsonKey(name: 'tags')
  final List<String> tags;

  @HiveField(9)
  @JsonKey(name: 'date')
  final DateTime date;

  @HiveField(10)
  @JsonKey(name: 'affects_balance')
  final bool affectsBalance;

  @HiveField(11)
  @JsonKey(name: 'recurring_id')
  final String? recurringId;

  @HiveField(12)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(13)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  TransactionModel({
    String? id,
    required this.userId,
    this.accountId,
    required this.amount,
    required this.type,
    required this.description,
    this.merchant,
    this.category = '',
    this.tags = const [],
    required this.date,
    this.affectsBalance = true,
    this.recurringId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  /// Create a copy with updated fields
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? accountId,
    double? amount,
    TransactionType? type,
    String? description,
    String? merchant,
    String? category,
    List<String>? tags,
    DateTime? date,
    bool? affectsBalance,
    String? recurringId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      date: date ?? this.date,
      affectsBalance: affectsBalance ?? this.affectsBalance,
      recurringId: recurringId ?? this.recurringId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Get transaction amount with sign based on type
  double get signedAmount {
    switch (type) {
      case TransactionType.income:
        return amount;
      case TransactionType.expense:
        return -amount;
      case TransactionType.transfer:
        return amount; // Depends on perspective
      case TransactionType.loan:
        return amount; // Money received
      case TransactionType.repayment:
        return -amount; // Money paid
    }
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, type: $type, amount: $amount, description: $description)';
  }
}
