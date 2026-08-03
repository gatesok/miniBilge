import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_history.freezed.dart';
part 'challenge_history.g.dart';

/// Meydan okuma geçmişi (rakip, kategori, sonuç) — premium.
@freezed
class ChallengeHistory with _$ChallengeHistory {
  const factory ChallengeHistory({
    @JsonKey(name: 'ChildId') required String childId,
    @JsonKey(name: 'TotalCompleted') required int totalCompleted,
    @JsonKey(name: 'Won') required int won,
    @JsonKey(name: 'Lost') required int lost,
    @JsonKey(name: 'Tie') required int tie,
    @JsonKey(name: 'Items')
    @Default(<ChallengeHistoryItem>[])
    List<ChallengeHistoryItem> items,
  }) = _ChallengeHistory;

  factory ChallengeHistory.fromJson(Map<String, dynamic> json) =>
      _$ChallengeHistoryFromJson(json);
}

@freezed
class ChallengeHistoryItem with _$ChallengeHistoryItem {
  const factory ChallengeHistoryItem({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'OpponentName') required String opponentName,
    @JsonKey(name: 'Category') required String category,
    @JsonKey(name: 'Result') required String result,
    @JsonKey(name: 'MyScore') required int myScore,
    @JsonKey(name: 'OpponentScore') required int opponentScore,
    @JsonKey(name: 'TotalQuestions') required int totalQuestions,
    @JsonKey(name: 'PlayedAt') required DateTime playedAt,
  }) = _ChallengeHistoryItem;

  factory ChallengeHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$ChallengeHistoryItemFromJson(json);
}
