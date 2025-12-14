// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtAdapter extends TypeAdapter<Debt> {
  @override
  final typeId = 42;

  @override
  Debt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Debt(
      id: fields[0] as String?,
      personName: fields[1] as String,
      originalAmount: (fields[2] as num).toDouble(),
      remainingAmount: (fields[3] as num?)?.toDouble(),
      type: fields[4] as DebtType,
      dueDate: fields[5] as DateTime?,
      createdAt: fields[6] as DateTime?,
      transactionIds:
          fields[7] == null ? const [] : (fields[7] as List).cast<String>(),
      minPayment: fields[8] == null ? 0.0 : (fields[8] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Debt obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personName)
      ..writeByte(2)
      ..write(obj.originalAmount)
      ..writeByte(3)
      ..write(obj.remainingAmount)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.transactionIds)
      ..writeByte(8)
      ..write(obj.minPayment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DebtTypeAdapter extends TypeAdapter<DebtType> {
  @override
  final typeId = 41;

  @override
  DebtType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DebtType.lent;
      case 1:
        return DebtType.borrowed;
      default:
        return DebtType.lent;
    }
  }

  @override
  void write(BinaryWriter writer, DebtType obj) {
    switch (obj) {
      case DebtType.lent:
        writer.writeByte(0);
      case DebtType.borrowed:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}


