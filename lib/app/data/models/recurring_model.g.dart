// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringModelAdapter extends TypeAdapter<RecurringModel> {
  @override
  final typeId = 6;

  @override
  RecurringModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringModel(
      id: fields[0] as String?,
      userId: fields[1] as String,
      name: fields[2] as String,
      amount: (fields[3] as num).toDouble(),
      frequency: fields[4] as RecurrenceFrequency,
      category: fields[5] == null ? '' : fields[5] as String,
      accountId: fields[6] as String?,
      nextRun: fields[7] as DateTime,
      isActive: fields[8] == null ? true : fields[8] as bool,
      notificationsEnabled: fields[9] == null ? true : fields[9] as bool,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.accountId)
      ..writeByte(7)
      ..write(obj.nextRun)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.notificationsEnabled)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceFrequencyAdapter extends TypeAdapter<RecurrenceFrequency> {
  @override
  final typeId = 7;

  @override
  RecurrenceFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrenceFrequency.daily;
      case 1:
        return RecurrenceFrequency.weekly;
      case 2:
        return RecurrenceFrequency.monthly;
      case 3:
        return RecurrenceFrequency.yearly;
      default:
        return RecurrenceFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrenceFrequency obj) {
    switch (obj) {
      case RecurrenceFrequency.daily:
        writer.writeByte(0);
      case RecurrenceFrequency.weekly:
        writer.writeByte(1);
      case RecurrenceFrequency.monthly:
        writer.writeByte(2);
      case RecurrenceFrequency.yearly:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringModel _$RecurringModelFromJson(Map<String, dynamic> json) =>
    RecurringModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      frequency: $enumDecode(_$RecurrenceFrequencyEnumMap, json['frequency']),
      category: json['category'] as String? ?? '',
      accountId: json['account_id'] as String?,
      nextRun: DateTime.parse(json['next_run'] as String),
      isActive: json['is_active'] as bool? ?? true,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$RecurringModelToJson(RecurringModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'amount': instance.amount,
      'frequency': _$RecurrenceFrequencyEnumMap[instance.frequency]!,
      'category': instance.category,
      'account_id': instance.accountId,
      'next_run': instance.nextRun.toIso8601String(),
      'is_active': instance.isActive,
      'notifications_enabled': instance.notificationsEnabled,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$RecurrenceFrequencyEnumMap = {
  RecurrenceFrequency.daily: 'daily',
  RecurrenceFrequency.weekly: 'weekly',
  RecurrenceFrequency.monthly: 'monthly',
  RecurrenceFrequency.yearly: 'yearly',
};
