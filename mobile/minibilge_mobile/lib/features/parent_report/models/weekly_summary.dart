import 'package:freezed_annotation/freezed_annotation.dart';
import 'daily_summary.dart';
import 'subject_summary.dart';

part 'weekly_summary.freezed.dart';
part 'weekly_summary.g.dart';

@freezed
class WeeklySummary with _$WeeklySummary {
  const factory WeeklySummary({
    @JsonKey(name: 'ChildId') required String childId,
    @JsonKey(name: 'WeekStart') required DateTime weekStart,
    @JsonKey(name: 'WeekEnd') required DateTime weekEnd,
    @JsonKey(name: 'TotalQuestionsAnswered') required int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') required int correctAnswers,
    @JsonKey(name: 'WrongAnswers') required int wrongAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required double correctAnswerRate,
    @JsonKey(name: 'LevelsCompleted') required int levelsCompleted,
    @JsonKey(name: 'TotalPointsEarned') required int totalPointsEarned,
    @JsonKey(name: 'TotalStarsEarned') required int totalStarsEarned,
    @JsonKey(name: 'ActiveDays') required int activeDays,
    @JsonKey(name: 'DailyBreakdown') required List<DailySummary> dailyBreakdown,
    @JsonKey(name: 'SubjectBreakdown') @Default([]) List<SubjectSummary> subjectBreakdown,
  }) = _WeeklySummary;

  factory WeeklySummary.fromJson(Map<String, dynamic> json) =>
      _$WeeklySummaryFromJson(json);
}
