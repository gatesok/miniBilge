import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_trend.freezed.dart';
part 'progress_trend.g.dart';

/// P6-B05: 30/90 günlük gelişim trendi (premium).
@freezed
class ProgressTrend with _$ProgressTrend {
  const factory ProgressTrend({
    @JsonKey(name: 'ChildId') required String childId,
    @JsonKey(name: 'Days') required int days,
    @JsonKey(name: 'PeriodStart') required DateTime periodStart,
    @JsonKey(name: 'PeriodEnd') required DateTime periodEnd,
    @JsonKey(name: 'TotalQuestionsAnswered') required int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') required int correctAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required double correctAnswerRate,
    @JsonKey(name: 'ActiveDays') required int activeDays,
    @JsonKey(name: 'LevelsCompleted') required int levelsCompleted,
    @JsonKey(name: 'TotalPointsEarned') required int totalPointsEarned,
    @JsonKey(name: 'TotalStarsEarned') required int totalStarsEarned,
    @JsonKey(name: 'WeeklyTrend') @Default([]) List<TrendPoint> weeklyTrend,
  }) = _ProgressTrend;

  factory ProgressTrend.fromJson(Map<String, dynamic> json) =>
      _$ProgressTrendFromJson(json);
}

@freezed
class TrendPoint with _$TrendPoint {
  const factory TrendPoint({
    @JsonKey(name: 'WeekStart') required DateTime weekStart,
    @JsonKey(name: 'WeekEnd') required DateTime weekEnd,
    @JsonKey(name: 'TotalQuestionsAnswered') required int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') required int correctAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required double correctAnswerRate,
    @JsonKey(name: 'ActiveDays') required int activeDays,
  }) = _TrendPoint;

  factory TrendPoint.fromJson(Map<String, dynamic> json) =>
      _$TrendPointFromJson(json);
}
