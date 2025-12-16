// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ml_model_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MLModelStateAdapter extends TypeAdapter<MLModelState> {
  @override
  final typeId = 30;

  @override
  MLModelState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MLModelState(
      modelName: fields[0] as String,
      weights: (fields[1] as List).cast<double>(),
      trainedAt: fields[2] as DateTime,
      trainingDataCount: (fields[3] as num).toInt(),
      validationScore: (fields[4] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, MLModelState obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.modelName)
      ..writeByte(1)
      ..write(obj.weights)
      ..writeByte(2)
      ..write(obj.trainedAt)
      ..writeByte(3)
      ..write(obj.trainingDataCount)
      ..writeByte(4)
      ..write(obj.validationScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MLModelStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
