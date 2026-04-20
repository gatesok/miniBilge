import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_answer_response.freezed.dart';
part 'submit_answer_response.g.dart';

@freezed
class SubmitAnswerResponse with _$SubmitAnswerResponse {
  const factory SubmitAnswerResponse({
    @JsonKey(name: 'IsCorrect') required bool isCorrect,
    @JsonKey(name: 'CorrectAnswer') required String correctAnswer,
    @JsonKey(name: 'Explanation') String? explanation,
  }) = _SubmitAnswerResponse;

  factory SubmitAnswerResponse.fromJson(Map<String, dynamic> json) =>
      _$SubmitAnswerResponseFromJson(json);
}
