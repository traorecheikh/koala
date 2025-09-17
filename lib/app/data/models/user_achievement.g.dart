// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAchievement _$UserAchievementFromJson(Map<String, dynamic> json) =>
    UserAchievement(
      id: json['id'] as String,
      userId: json['userId'] as String,
      achievementId: json['achievementId'] as String,
      awardedAt: DateTime.parse(json['awardedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      achievement: Achievement.fromJson(
        json['achievement'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$UserAchievementToJson(UserAchievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'achievementId': instance.achievementId,
      'awardedAt': instance.awardedAt.toIso8601String(),
      'metadata': instance.metadata,
      'achievement': instance.achievement,
    };
