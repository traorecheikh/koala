// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_pattern.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinancialPatternAdapter extends TypeAdapter<FinancialPattern> {
  @override
  final typeId = 32;

  @override
  FinancialPattern read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinancialPattern(
      patternType: fields[0] as String,
      description: fields[1] as String,
      confidence: (fields[2] as num).toDouble(),
      parameters: (fields[3] as Map).cast<String, String>(),
      isActive: fields[4] == null ? true : fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FinancialPattern obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.patternType)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.confidence)
      ..writeByte(3)
      ..write(obj.parameters)
      ..writeByte(4)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialPatternAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
