// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_answer_attempt_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaveAnswerAttemptRequestImpl _$$SaveAnswerAttemptRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SaveAnswerAttemptRequestImpl(
  childId: json['ChildId'] as String,
  questionId: json['QuestionId'] as String,
  submittedAnswer: json['SubmittedAnswer'] as String,
  isCorrect: json['IsCorrect'] as bool,
  timeTakenSeconds: (json['TimeTakenSeconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$$SaveAnswerAttemptRequestImplToJson(
  _$SaveAnswerAttemptRequestImpl instance,
) => <String, dynamic>{
  'ChildId': instance.childId,
  'QuestionId': instance.questionId,
  'SubmittedAnswer': instance.submittedAnswer,
  'IsCorrect': instance.isCorrect,
  'TimeTakenSeconds': instance.timeTakenSeconds,
};
