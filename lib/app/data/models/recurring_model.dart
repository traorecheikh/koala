import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'recurring_model.g.dart';

/// Recurrence frequency enumeration
@HiveType(typeId: 7)
enum RecurrenceFrequency {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  monthly,

  @HiveField(3)
  yearly,
}

/// Recurring transaction model
@HiveType(typeId: 6)
@JsonSerializable()
class RecurringModel extends HiveObject {
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
  @JsonKey(name: 'amount')
  final double amount;

  @HiveField(4)
  @JsonKey(name: 'frequency')
  final RecurrenceFrequency frequency;

  @HiveField(5)
  @JsonKey(name: 'category')
  final String category;

  @HiveField(6)
  @JsonKey(name: 'account_id')
  final String? accountId;

  @HiveField(7)
  @JsonKey(name: 'next_run')
  final DateTime nextRun;

  @HiveField(8)
  @JsonKey(name: 'is_active')
  final bool isActive;

  @HiveField(9)
  @JsonKey(name: 'notifications_enabled')
  final bool notificationsEnabled;

  @HiveField(10)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(11)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  RecurringModel({
    String? id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.frequency,
    this.category = '',
    this.accountId,
    required this.nextRun,
    this.isActive = true,
    this.notificationsEnabled = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory RecurringModel.fromJson(Map<String, dynamic> json) =>
      _$RecurringModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringModelToJson(this);

  /// Get frequency display text
  String get frequencyText {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return 'Quotidien';
      case RecurrenceFrequency.weekly:
        return 'Hebdomadaire';
      case RecurrenceFrequency.monthly:
        return 'Mensuel';
      case RecurrenceFrequency.yearly:
        return 'Annuel';
    }
  }

  /// Calculate next run date based on frequency
  DateTime calculateNextRun() {
    final now = DateTime.now();
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return DateTime(now.year, now.month, now.day + 1);
      case RecurrenceFrequency.weekly:
        return DateTime(now.year, now.month, now.day + 7);
      case RecurrenceFrequency.monthly:
        return DateTime(now.year, now.month + 1, now.day);
      case RecurrenceFrequency.yearly:
        return DateTime(now.year + 1, now.month, now.day);
    }
  }

  /// Create a copy with updated fields
  RecurringModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    RecurrenceFrequency? frequency,
    String? category,
    String? accountId,
    DateTime? nextRun,
    bool? isActive,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      nextRun: nextRun ?? this.nextRun,
      isActive: isActive ?? this.isActive,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'RecurringModel(id: $id, name: $name, amount: $amount, frequency: $frequency)';
  }
}
