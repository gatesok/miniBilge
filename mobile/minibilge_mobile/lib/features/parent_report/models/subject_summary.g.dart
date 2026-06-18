// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubjectSummaryImpl _$$SubjectSummaryImplFromJson(Map<String, dynamic> json) =>
    _$SubjectSummaryImpl(
      subjectName: json['SubjectName'] as String,
      totalQuestions: (json['TotalQuestions'] as num).toInt(),
      correctAnswers: (json['CorrectAnswers'] as num).toInt(),
      wrongAnswers: (json['WrongAnswers'] as num).toInt(),
      correctAnswerRate: (json['CorrectAnswerRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$SubjectSummaryImplToJson(
  _$SubjectSummaryImpl instance,
) => <String, dynamic>{
  'SubjectName': instance.subjectName,
  'TotalQuestions': instance.totalQuestions,
  'CorrectAnswers': instance.correctAnswers,
  'WrongAnswers': instance.wrongAnswers,
  'CorrectAnswerRate': instance.correctAnswerRate,
};
