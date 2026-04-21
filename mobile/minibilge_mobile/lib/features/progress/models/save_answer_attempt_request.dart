import 'package:freezed_annotation/freezed_annotation.dart';

part 'save_answer_attempt_request.freezed.dart';
part 'save_answer_attempt_request.g.dart';

@freezed
class SaveAnswerAttemptRequest with _$SaveAnswerAttemptRequest {
  const factory SaveAnswerAttemptRequest({
    @JsonKey(name: 'ChildId') required String childId,
    @JsonKey(name: 'QuestionId') required String questionId,
    @JsonKey(name: 'SubmittedAnswer') required String submittedAnswer,
    @JsonKey(name: 'IsCorrect') required bool isCorrect,
    @JsonKey(name: 'TimeTakenSeconds') int? timeTakenSeconds,
  }) = _SaveAnswerAttemptRequest;

  factory SaveAnswerAttemptRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveAnswerAttemptRequestFromJson(json);
}
