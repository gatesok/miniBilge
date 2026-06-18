import 'package:freezed_annotation/freezed_annotation.dart';

part 'subject_summary.freezed.dart';
part 'subject_summary.g.dart';

@freezed
class SubjectSummary with _$SubjectSummary {
  const factory SubjectSummary({
    @JsonKey(name: 'SubjectName') required String subjectName,
    @JsonKey(name: 'TotalQuestions') required int totalQuestions,
    @JsonKey(name: 'CorrectAnswers') required int correctAnswers,
    @JsonKey(name: 'WrongAnswers') required int wrongAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required double correctAnswerRate,
  }) = _SubjectSummary;

  factory SubjectSummary.fromJson(Map<String, dynamic> json) =>
      _$SubjectSummaryFromJson(json);
}
