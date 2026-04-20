// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_answer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubmitAnswerResponseImpl _$$SubmitAnswerResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$SubmitAnswerResponseImpl(
      isCorrect: json['IsCorrect'] as bool,
      correctAnswer: json['CorrectAnswer'] as String,
      explanation: json['Explanation'] as String?,
    );

Map<String, dynamic> _$$SubmitAnswerResponseImplToJson(
        _$SubmitAnswerResponseImpl instance) =>
    <String, dynamic>{
      'IsCorrect': instance.isCorrect,
      'CorrectAnswer': instance.correctAnswer,
      'Explanation': instance.explanation,
    };
