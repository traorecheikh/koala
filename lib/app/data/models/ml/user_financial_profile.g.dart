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
      weekendRatio: fields[5] == null ? 0.0 : (fields[5] as num).toDouble(),
      nightRatio: fields[6] == null ? 0.0 : (fields[6] as num).toDouble(),
      dominantCategory: fields[7] == null ? 'Autre' : fields[7] as String,
      averageAmount: fields[8] == null ? 0.0 : (fields[8] as num).toDouble(),
      dataQuality: fields[9] == null ? 'low' : fields[9] as String,
      transactionCount: fields[10] == null ? 0 : (fields[10] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, UserFinancialProfile obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.personaType)
      ..writeByte(1)
      ..write(obj.savingsRate)
      ..writeByte(2)
      ..write(obj.consistencyScore)
      ..writeByte(3)
      ..write(obj.categoryPreferences)
      ..writeByte(4)
      ..write(obj.detectedPatterns)
      ..writeByte(5)
      ..write(obj.weekendRatio)
      ..writeByte(6)
      ..write(obj.nightRatio)
      ..writeByte(7)
      ..write(obj.dominantCategory)
      ..writeByte(8)
      ..write(obj.averageAmount)
      ..writeByte(9)
      ..write(obj.dataQuality)
      ..writeByte(10)
      ..write(obj.transactionCount);
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
