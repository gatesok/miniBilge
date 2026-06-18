import 'package:freezed_annotation/freezed_annotation.dart';
import 'subject_summary.dart';

part 'daily_summary.freezed.dart';
part 'daily_summary.g.dart';

@freezed
class DailySummary with _$DailySummary {
  const factory DailySummary({
    @JsonKey(name: 'ChildId') required String childId,
    @JsonKey(name: 'Date') required DateTime date,
    @JsonKey(name: 'TotalQuestionsAnswered') required int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') required int correctAnswers,
    @JsonKey(name: 'WrongAnswers') required int wrongAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required double correctAnswerRate,
    @JsonKey(name: 'LevelsCompleted') required int levelsCompleted,
    @JsonKey(name: 'PointsEarned') required int pointsEarned,
    @JsonKey(name: 'StarsEarned') required int starsEarned,
    @JsonKey(name: 'SubjectBreakdown') @Default([]) List<SubjectSummary> subjectBreakdown,
  }) = _DailySummary;

  factory DailySummary.fromJson(Map<String, dynamic> json) =>
      _$DailySummaryFromJson(json);
}
