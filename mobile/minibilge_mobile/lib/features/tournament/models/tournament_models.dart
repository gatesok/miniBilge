import 'package:freezed_annotation/freezed_annotation.dart';

part 'tournament_models.freezed.dart';
part 'tournament_models.g.dart';

/// P7-M05: Yetişkin haftalık eğlence turnuvası — bir kategorinin bu haftaki sıralaması.
@freezed
class TournamentWeek with _$TournamentWeek {
  const factory TournamentWeek({
    @JsonKey(name: 'CategoryKey') required String categoryKey,
    @JsonKey(name: 'CategoryLabel') required String categoryLabel,
    @JsonKey(name: 'CategoryEmoji') required String categoryEmoji,
    @JsonKey(name: 'WeekStart') required String weekStart,
    @JsonKey(name: 'Entries')
    @Default(<TournamentLeaderboardEntry>[])
    List<TournamentLeaderboardEntry> entries,
    @JsonKey(name: 'Me') TournamentLeaderboardEntry? me,
  }) = _TournamentWeek;

  factory TournamentWeek.fromJson(Map<String, dynamic> json) =>
      _$TournamentWeekFromJson(json);
}

@freezed
class TournamentLeaderboardEntry with _$TournamentLeaderboardEntry {
  const factory TournamentLeaderboardEntry({
    @JsonKey(name: 'ChildProfileId') required String childProfileId,
    @JsonKey(name: 'ChildName') required String childName,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'Points') required int points,
    @JsonKey(name: 'Wins') required int wins,
    @JsonKey(name: 'GamesPlayed') required int gamesPlayed,
    @JsonKey(name: 'Rank') required int rank,
  }) = _TournamentLeaderboardEntry;

  factory TournamentLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$TournamentLeaderboardEntryFromJson(json);
}

@freezed
class TournamentCategory with _$TournamentCategory {
  const factory TournamentCategory({
    @JsonKey(name: 'Key') required String key,
    @JsonKey(name: 'Label') required String label,
    @JsonKey(name: 'Emoji') required String emoji,
  }) = _TournamentCategory;

  factory TournamentCategory.fromJson(Map<String, dynamic> json) =>
      _$TournamentCategoryFromJson(json);
}
