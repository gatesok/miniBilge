// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$LeaderboardEntryImpl(
      childProfileId: json['ChildProfileId'] as String,
      childName: json['ChildName'] as String,
      avatarImageUrl: json['AvatarImageUrl'] as String?,
      totalCoins: (json['TotalCoins'] as num?)?.toInt() ?? 0,
      totalScore: (json['TotalScore'] as num?)?.toInt() ?? 0,
      totalStars: (json['TotalStars'] as num?)?.toInt() ?? 0,
      rank: (json['Rank'] as num?)?.toInt() ?? 0,
      gradeLevel: json['GradeLevel'] as String?,
    );

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
        _$LeaderboardEntryImpl instance) =>
    <String, dynamic>{
      'ChildProfileId': instance.childProfileId,
      'ChildName': instance.childName,
      'AvatarImageUrl': instance.avatarImageUrl,
      'TotalCoins': instance.totalCoins,
      'TotalScore': instance.totalScore,
      'TotalStars': instance.totalStars,
      'Rank': instance.rank,
      'GradeLevel': instance.gradeLevel,
    };
