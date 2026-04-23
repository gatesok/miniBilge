// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailySummaryImpl _$$DailySummaryImplFromJson(Map<String, dynamic> json) =>
    _$DailySummaryImpl(
      childId: json['ChildId'] as String,
      date: DateTime.parse(json['Date'] as String),
      totalQuestionsAnswered: (json['TotalQuestionsAnswered'] as num).toInt(),
      correctAnswers: (json['CorrectAnswers'] as num).toInt(),
      wrongAnswers: (json['WrongAnswers'] as num).toInt(),
      correctAnswerRate: (json['CorrectAnswerRate'] as num).toDouble(),
      levelsCompleted: (json['LevelsCompleted'] as num).toInt(),
      pointsEarned: (json['PointsEarned'] as num).toInt(),
      starsEarned: (json['StarsEarned'] as num).toInt(),
    );

Map<String, dynamic> _$$DailySummaryImplToJson(_$DailySummaryImpl instance) =>
    <String, dynamic>{
      'ChildId': instance.childId,
      'Date': instance.date.toIso8601String(),
      'TotalQuestionsAnswered': instance.totalQuestionsAnswered,
      'CorrectAnswers': instance.correctAnswers,
      'WrongAnswers': instance.wrongAnswers,
      'CorrectAnswerRate': instance.correctAnswerRate,
      'LevelsCompleted': instance.levelsCompleted,
      'PointsEarned': instance.pointsEarned,
      'StarsEarned': instance.starsEarned,
    };
