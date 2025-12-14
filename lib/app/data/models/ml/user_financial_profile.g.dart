// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_financial_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserFinancialProfileAdapter extends TypeAdapter<UserFinancialProfile> {
  @override
  final typeId = 31;

  @override
  UserFinancialProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserFinancialProfile(
      personaType: fields[0] as String,
      savingsRate: (fields[1] as num).toDouble(),
      consistencyScore: (fields[2] as num).toDouble(),
      categoryPreferences: (fields[3] as Map).cast<String, double>(),
      detectedPatterns: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserFinancialProfile obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.personaType)
      ..writeByte(1)
      ..write(obj.savingsRate)
      ..writeByte(2)
      ..write(obj.consistencyScore)
      ..writeByte(3)
      ..write(obj.categoryPreferences)
      ..writeByte(4)
      ..write(obj.detectedPatterns);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFinancialProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

