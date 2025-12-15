// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeAdapter extends TypeAdapter<Challenge> {
  @override
  final typeId = 62;

  @override
  Challenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Challenge(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as ChallengeType,
      difficulty: fields[4] as ChallengeDifficulty,
      iconKey: fields[5] as String,
      targetValue: (fields[6] as num).toInt(),
      targetUnit: fields[7] as String,
      rewardPoints: (fields[8] as num).toInt(),
      badgeId: fields[9] as String?,
      durationDays: fields[10] == null ? 0 : (fields[10] as num).toInt(),
      isRepeatable: fields[11] == null ? false : fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Challenge obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.iconKey)
      ..writeByte(6)
      ..write(obj.targetValue)
      ..writeByte(7)
      ..write(obj.targetUnit)
      ..writeByte(8)
      ..write(obj.rewardPoints)
      ..writeByte(9)
      ..write(obj.badgeId)
      ..writeByte(10)
      ..write(obj.durationDays)
      ..writeByte(11)
      ..write(obj.isRepeatable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserChallengeAdapter extends TypeAdapter<UserChallenge> {
  @override
  final typeId = 63;

  @override
  UserChallenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserChallenge(
      id: fields[0] as String?,
      challengeId: fields[1] as String,
      startedAt: fields[2] as DateTime?,
      completedAt: fields[3] as DateTime?,
      currentProgress: fields[4] == null ? 0 : (fields[4] as num).toInt(),
      isActive: fields[5] == null ? true : fields[5] as bool,
      isFailed: fields[6] == null ? false : fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserChallenge obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.challengeId)
      ..writeByte(2)
      ..write(obj.startedAt)
      ..writeByte(3)
      ..write(obj.completedAt)
      ..writeByte(4)
      ..write(obj.currentProgress)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.isFailed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserChallengeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BadgeAdapter extends TypeAdapter<Badge> {
  @override
  final typeId = 64;

  @override
  Badge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Badge(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      iconAsset: fields[3] as String,
      tier: fields[4] == null ? 1 : (fields[4] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Badge obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconAsset)
      ..writeByte(4)
      ..write(obj.tier);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserBadgeAdapter extends TypeAdapter<UserBadge> {
  @override
  final typeId = 65;

  @override
  UserBadge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserBadge(
      id: fields[0] as String?,
      badgeId: fields[1] as String,
      earnedAt: fields[2] as DateTime?,
      challengeId: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserBadge obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.badgeId)
      ..writeByte(2)
      ..write(obj.earnedAt)
      ..writeByte(3)
      ..write(obj.challengeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBadgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChallengeTypeAdapter extends TypeAdapter<ChallengeType> {
  @override
  final typeId = 60;

  @override
  ChallengeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChallengeType.spending;
      case 1:
        return ChallengeType.saving;
      case 2:
        return ChallengeType.budget;
      case 3:
        return ChallengeType.streak;
      case 4:
        return ChallengeType.oneTime;
      default:
        return ChallengeType.spending;
    }
  }

  @override
  void write(BinaryWriter writer, ChallengeType obj) {
    switch (obj) {
      case ChallengeType.spending:
        writer.writeByte(0);
      case ChallengeType.saving:
        writer.writeByte(1);
      case ChallengeType.budget:
        writer.writeByte(2);
      case ChallengeType.streak:
        writer.writeByte(3);
      case ChallengeType.oneTime:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChallengeDifficultyAdapter extends TypeAdapter<ChallengeDifficulty> {
  @override
  final typeId = 61;

  @override
  ChallengeDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChallengeDifficulty.easy;
      case 1:
        return ChallengeDifficulty.medium;
      case 2:
        return ChallengeDifficulty.hard;
      case 3:
        return ChallengeDifficulty.legendary;
      default:
        return ChallengeDifficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, ChallengeDifficulty obj) {
    switch (obj) {
      case ChallengeDifficulty.easy:
        writer.writeByte(0);
      case ChallengeDifficulty.medium:
        writer.writeByte(1);
      case ChallengeDifficulty.hard:
        writer.writeByte(2);
      case ChallengeDifficulty.legendary:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
