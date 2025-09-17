import 'package:json_annotation/json_annotation.dart';
import 'package:koala/app/data/models/achievement.dart';

part 'user_achievement.g.dart';

@JsonSerializable()
class UserAchievement {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime awardedAt;
  final Map<String, dynamic>? metadata;
  final Achievement achievement;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.awardedAt,
    this.metadata,
    required this.achievement,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) =>
      _$UserAchievementFromJson(json);
  Map<String, dynamic> toJson() => _$UserAchievementToJson(this);
}