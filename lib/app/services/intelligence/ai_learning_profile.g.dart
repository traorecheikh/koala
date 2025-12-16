// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_learning_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AILearningProfileAdapter extends TypeAdapter<AILearningProfile> {
  @override
  final typeId = 20;

  @override
  AILearningProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AILearningProfile(
      dismissedAlertCounts: (fields[0] as Map?)?.cast<String, int>(),
      mutedAlertsUntil: (fields[1] as Map?)?.cast<String, DateTime>(),
      categoryPreferences: (fields[2] as Map?)?.cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AILearningProfile obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dismissedAlertCounts)
      ..writeByte(1)
      ..write(obj.mutedAlertsUntil)
      ..writeByte(2)
      ..write(obj.categoryPreferences);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AILearningProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
