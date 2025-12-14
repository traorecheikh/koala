// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobAdapter extends TypeAdapter<Job> {
  @override
  final typeId = 9;

  @override
  Job read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Job(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: (fields[2] as num).toDouble(),
      frequency: fields[3] as PaymentFrequency,
      paymentDate: fields[4] as DateTime,
      isActive: fields[5] == null ? true : fields[5] as bool,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Job obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.paymentDate)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentFrequencyAdapter extends TypeAdapter<PaymentFrequency> {
  @override
  final typeId = 10;

  @override
  PaymentFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentFrequency.weekly;
      case 1:
        return PaymentFrequency.biweekly;
      case 2:
        return PaymentFrequency.monthly;
      default:
        return PaymentFrequency.weekly;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentFrequency obj) {
    switch (obj) {
      case PaymentFrequency.weekly:
        writer.writeByte(0);
      case PaymentFrequency.biweekly:
        writer.writeByte(1);
      case PaymentFrequency.monthly:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

