import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_history.freezed.dart';
part 'challenge_history.g.dart';

/// Meydan okuma geçmişinin kategori bazlı özeti (son 3 ay, rakip bilgisi yok) — premium.
@freezed
class ChallengeHistory with _$ChallengeHistory {
  const factory ChallengeHistory({
    @JsonKey(name: 'ChildId') required String childId,
    @JsonKey(name: 'TotalCompleted') required int totalCompleted,
    @JsonKey(name: 'Won') required int won,
    @JsonKey(name: 'Lost') required int lost,
    @JsonKey(name: 'Tie') required int tie,
    @JsonKey(name: 'Categories')
    @Default(<ChallengeCategoryStat>[])
    List<ChallengeCategoryStat> categories,
  }) = _ChallengeHistory;

  factory ChallengeHistory.fromJson(Map<String, dynamic> json) =>
      _$ChallengeHistoryFromJson(json);
}

@freezed
class ChallengeCategoryStat with _$ChallengeCategoryStat {
  const factory ChallengeCategoryStat({
    @JsonKey(name: 'Category') required String category,
    @JsonKey(name: 'Played') required int played,
    @JsonKey(name: 'Won') required int won,
    @JsonKey(name: 'Lost') required int lost,
    @JsonKey(name: 'Tie') required int tie,
    @JsonKey(name: 'WinRate') required double winRate,
  }) = _ChallengeCategoryStat;

  factory ChallengeCategoryStat.fromJson(Map<String, dynamic> json) =>
      _$ChallengeCategoryStatFromJson(json);
}
