import 'package:freezed_annotation/freezed_annotation.dart';

part 'save_progress_request.freezed.dart';
part 'save_progress_request.g.dart';

@freezed
class SaveProgressRequest with _$SaveProgressRequest {
  const factory SaveProgressRequest({
    @JsonKey(name: 'ChildId') required String childId,
    @JsonKey(name: 'LevelId') required String levelId,
    @JsonKey(name: 'CorrectCount') required int correctCount,
    @JsonKey(name: 'TotalQuestions') required int totalQuestions,
    @JsonKey(name: 'SuccessPercentage') required double successPercentage,
    @JsonKey(name: 'SubjectName') String? subjectName,
    @JsonKey(name: 'EnglishLevel') String? englishLevel,
    @JsonKey(name: 'QuizDurationSeconds') int? quizDurationSeconds,
  }) = _SaveProgressRequest;

  factory SaveProgressRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveProgressRequestFromJson(json);
}
