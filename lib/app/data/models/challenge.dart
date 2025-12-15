import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

part 'challenge.g.dart';

/// Type of challenge
@HiveType(typeId: 60)
enum ChallengeType {
  @HiveField(0)
  spending,
  @HiveField(1)
  saving,
  @HiveField(2)
  budget,
  @HiveField(3)
  streak,
  @HiveField(4)
  oneTime,
}

/// Difficulty level affects rewards
@HiveType(typeId: 61)
enum ChallengeDifficulty {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard,
  @HiveField(3)
  legendary,
}

/// Challenge definition (predefined challenges)
@HiveType(typeId: 62)
class Challenge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final ChallengeType type;

  @HiveField(4)
  final ChallengeDifficulty difficulty;

  @HiveField(5)
  final String iconKey;

  @HiveField(6)
  final int targetValue;

  @HiveField(7)
  final String targetUnit; // "days", "FCFA", "transactions", "percent"

  @HiveField(8)
  final int rewardPoints;

  @HiveField(9)
  final String? badgeId;

  @HiveField(10)
  final int durationDays; // How long to complete (0 = no limit)

  @HiveField(11)
  final bool isRepeatable;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.iconKey,
    required this.targetValue,
    required this.targetUnit,
    required this.rewardPoints,
    this.badgeId,
    this.durationDays = 0,
    this.isRepeatable = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'difficulty': difficulty.name,
        'iconKey': iconKey,
        'targetValue': targetValue,
        'targetUnit': targetUnit,
        'rewardPoints': rewardPoints,
        'badgeId': badgeId,
        'durationDays': durationDays,
        'isRepeatable': isRepeatable,
      };
}

/// User's progress on a challenge
@HiveType(typeId: 63)
class UserChallenge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String challengeId;

  @HiveField(2)
  final DateTime startedAt;

  @HiveField(3)
  DateTime? completedAt;

  @HiveField(4)
  int currentProgress;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  bool isFailed;

  UserChallenge({
    String? id,
    required this.challengeId,
    DateTime? startedAt,
    this.completedAt,
    this.currentProgress = 0,
    this.isActive = true,
    this.isFailed = false,
  })  : id = id ?? const Uuid().v4(),
        startedAt = startedAt ?? DateTime.now();

  bool get isCompleted => completedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'challengeId': challengeId,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'currentProgress': currentProgress,
        'isActive': isActive,
        'isFailed': isFailed,
      };
}

/// Badge earned by completing challenges
@HiveType(typeId: 64)
class Badge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String iconAsset; // Path to asset

  @HiveField(4)
  final int tier; // 1=bronze, 2=silver, 3=gold, 4=platinum

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconAsset,
    this.tier = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconAsset': iconAsset,
        'tier': tier,
      };
}

/// User's earned badges
@HiveType(typeId: 65)
class UserBadge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String badgeId;

  @HiveField(2)
  final DateTime earnedAt;

  @HiveField(3)
  final String? challengeId; // Which challenge unlocked it

  UserBadge({
    String? id,
    required this.badgeId,
    DateTime? earnedAt,
    this.challengeId,
  })  : id = id ?? const Uuid().v4(),
        earnedAt = earnedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'badgeId': badgeId,
        'earnedAt': earnedAt.toIso8601String(),
        'challengeId': challengeId,
      };
}
