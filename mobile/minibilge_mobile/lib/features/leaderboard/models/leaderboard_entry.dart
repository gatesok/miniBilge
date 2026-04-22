import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_entry.freezed.dart';
part 'leaderboard_entry.g.dart';

@freezed
class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    @JsonKey(name: 'ChildProfileId') required String childProfileId,
    @JsonKey(name: 'ChildName') required String childName,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'TotalCoins') @Default(0) int totalCoins,
    @JsonKey(name: 'TotalScore') @Default(0) int totalScore,
    @JsonKey(name: 'TotalStars') @Default(0) int totalStars,
    @JsonKey(name: 'Rank') @Default(0) int rank,
    @JsonKey(name: 'GradeLevel') String? gradeLevel,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}
