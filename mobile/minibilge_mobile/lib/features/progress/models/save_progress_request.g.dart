// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_progress_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaveProgressRequestImpl _$$SaveProgressRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SaveProgressRequestImpl(
  childId: json['ChildId'] as String,
  levelId: json['LevelId'] as String,
  correctCount: (json['CorrectCount'] as num).toInt(),
  totalQuestions: (json['TotalQuestions'] as num).toInt(),
  successPercentage: (json['SuccessPercentage'] as num).toDouble(),
  subjectName: json['SubjectName'] as String?,
  englishLevel: json['EnglishLevel'] as String?,
  quizDurationSeconds: (json['QuizDurationSeconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$$SaveProgressRequestImplToJson(
  _$SaveProgressRequestImpl instance,
) => <String, dynamic>{
  'ChildId': instance.childId,
  'LevelId': instance.levelId,
  'CorrectCount': instance.correctCount,
  'TotalQuestions': instance.totalQuestions,
  'SuccessPercentage': instance.successPercentage,
  'SubjectName': instance.subjectName,
  'EnglishLevel': instance.englishLevel,
  'QuizDurationSeconds': instance.quizDurationSeconds,
};
