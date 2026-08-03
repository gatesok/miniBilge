import 'package:freezed_annotation/freezed_annotation.dart';

part 'entertainment_stats.freezed.dart';
part 'entertainment_stats.g.dart';

/// Eğlence quizi (GameType='fun') kümülatif istatistikleri (premium).
@freezed
class EntertainmentStats with _$EntertainmentStats {
  const factory EntertainmentStats({
    @JsonKey(name: 'ChildId') required String childId,
    @JsonKey(name: 'TotalPlayed') required int totalPlayed,
    @JsonKey(name: 'TotalWon') required int totalWon,
    @JsonKey(name: 'PerfectWins') required int perfectWins,
    @JsonKey(name: 'AverageSuccessRate') required double averageSuccessRate,
    @JsonKey(name: 'Categories')
    @Default(<EntertainmentCategoryStat>[])
    List<EntertainmentCategoryStat> categories,
  }) = _EntertainmentStats;

  factory EntertainmentStats.fromJson(Map<String, dynamic> json) =>
      _$EntertainmentStatsFromJson(json);
}

@freezed
class EntertainmentCategoryStat with _$EntertainmentCategoryStat {
  const factory EntertainmentCategoryStat({
    @JsonKey(name: 'CategoryKey') required String categoryKey,
    @JsonKey(name: 'CategoryName') required String categoryName,
    @JsonKey(name: 'Played') required int played,
    @JsonKey(name: 'Won') required int won,
    @JsonKey(name: 'AverageSuccessRate') required double averageSuccessRate,
  }) = _EntertainmentCategoryStat;

  factory EntertainmentCategoryStat.fromJson(Map<String, dynamic> json) =>
      _$EntertainmentCategoryStatFromJson(json);
}
