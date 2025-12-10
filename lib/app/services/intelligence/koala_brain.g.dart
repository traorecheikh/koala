// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'koala_brain.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryPatternAdapter extends TypeAdapter<CategoryPattern> {
  @override
  final int typeId = 20;

  @override
  CategoryPattern read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryPattern(
      category: fields[0] as TransactionCategory,
      categoryId: fields[1] as String?,
      type: fields[2] as TransactionType,
      keywords: (fields[3] as List).cast<String>(),
      confidence: fields[4] as double,
      usageCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryPattern obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.keywords)
      ..writeByte(4)
      ..write(obj.confidence)
      ..writeByte(5)
      ..write(obj.usageCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryPatternAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserBehaviorAdapter extends TypeAdapter<UserBehavior> {
  @override
  final int typeId = 21;

  @override
  UserBehavior read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserBehavior(
      behaviorType: fields[0] as String,
      data: (fields[1] as Map).cast<String, dynamic>(),
      recordedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserBehavior obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.behaviorType)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.recordedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBehaviorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
