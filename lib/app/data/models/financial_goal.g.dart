// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinancialGoalAdapter extends TypeAdapter<FinancialGoal> {
  @override
  final typeId = 50;

  @override
  FinancialGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinancialGoal(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String?,
      targetAmount: (fields[3] as num).toDouble(),
      currentAmount: fields[4] == null ? 0.0 : (fields[4] as num).toDouble(),
      type: fields[5] == null ? GoalType.savings : fields[5] as GoalType,
      status: fields[6] == null ? GoalStatus.active : fields[6] as GoalStatus,
      createdAt: fields[7] as DateTime?,
      targetDate: fields[8] as DateTime?,
      completedAt: fields[9] as DateTime?,
      linkedDebtId: fields[10] as String?,
      linkedCategoryId: fields[11] as String?,
      milestones: (fields[12] as List?)?.cast<GoalMilestone>(),
      iconKey: (fields[13] as num?)?.toInt(),
      colorValue: (fields[14] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, FinancialGoal obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.targetAmount)
      ..writeByte(4)
      ..write(obj.currentAmount)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.targetDate)
      ..writeByte(9)
      ..write(obj.completedAt)
      ..writeByte(10)
      ..write(obj.linkedDebtId)
      ..writeByte(11)
      ..write(obj.linkedCategoryId)
      ..writeByte(12)
      ..write(obj.milestones)
      ..writeByte(13)
      ..write(obj.iconKey)
      ..writeByte(14)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalMilestoneAdapter extends TypeAdapter<GoalMilestone> {
  @override
  final typeId = 53;

  @override
  GoalMilestone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalMilestone(
      id: fields[0] as String?,
      title: fields[1] as String,
      targetAmount: (fields[2] as num).toDouble(),
      isCompleted: fields[3] == null ? false : fields[3] as bool,
      completedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, GoalMilestone obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.targetAmount)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalMilestoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final typeId = 51;

  @override
  GoalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalType.savings;
      case 1:
        return GoalType.debtPayoff;
      case 2:
        return GoalType.purchase;
      case 3:
        return GoalType.custom;
      default:
        return GoalType.savings;
    }
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    switch (obj) {
      case GoalType.savings:
        writer.writeByte(0);
      case GoalType.debtPayoff:
        writer.writeByte(1);
      case GoalType.purchase:
        writer.writeByte(2);
      case GoalType.custom:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalStatusAdapter extends TypeAdapter<GoalStatus> {
  @override
  final typeId = 52;

  @override
  GoalStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalStatus.active;
      case 1:
        return GoalStatus.completed;
      case 2:
        return GoalStatus.paused;
      case 3:
        return GoalStatus.abandoned;
      default:
        return GoalStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, GoalStatus obj) {
    switch (obj) {
      case GoalStatus.active:
        writer.writeByte(0);
      case GoalStatus.completed:
        writer.writeByte(1);
      case GoalStatus.paused:
        writer.writeByte(2);
      case GoalStatus.abandoned:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
