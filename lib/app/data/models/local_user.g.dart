// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalUserAdapter extends TypeAdapter<LocalUser> {
  @override
  final typeId = 0;

  @override
  LocalUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalUser(
      fullName: fields[0] as String,
      salary: (fields[1] as num).toDouble(),
      payday: (fields[2] as num).toInt(),
      age: (fields[3] as num).toInt(),
      budgetingType: fields[4] as String,
      firstLaunchDate: fields[5] as DateTime?,
      hasCompletedCatchUp: fields[6] == null ? false : fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocalUser obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.fullName)
      ..writeByte(1)
      ..write(obj.salary)
      ..writeByte(2)
      ..write(obj.payday)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.budgetingType)
      ..writeByte(5)
      ..write(obj.firstLaunchDate)
      ..writeByte(6)
      ..write(obj.hasCompletedCatchUp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
