// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'envelope.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnvelopeAdapter extends TypeAdapter<Envelope> {
  @override
  final typeId = 70;

  @override
  Envelope read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Envelope(
      id: fields[0] as String?,
      name: fields[1] as String,
      targetAmount: fields[2] == null ? 0.0 : (fields[2] as num).toDouble(),
      currentAmount: fields[3] == null ? 0.0 : (fields[3] as num).toDouble(),
      icon: fields[4] as String?,
      color: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
      targetDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Envelope obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.targetAmount)
      ..writeByte(3)
      ..write(obj.currentAmount)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.targetDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvelopeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
