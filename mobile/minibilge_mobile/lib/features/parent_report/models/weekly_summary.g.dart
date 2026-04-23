// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeeklySummaryImpl _$$WeeklySummaryImplFromJson(Map<String, dynamic> json) =>
    _$WeeklySummaryImpl(
      childId: json['ChildId'] as String,
      weekStart: DateTime.parse(json['WeekStart'] as String),
      weekEnd: DateTime.parse(json['WeekEnd'] as String),
      totalQuestionsAnswered: (json['TotalQuestionsAnswered'] as num).toInt(),
      correctAnswers: (json['CorrectAnswers'] as num).toInt(),
      wrongAnswers: (json['WrongAnswers'] as num).toInt(),
      correctAnswerRate: (json['CorrectAnswerRate'] as num).toDouble(),
      levelsCompleted: (json['LevelsCompleted'] as num).toInt(),
      totalPointsEarned: (json['TotalPointsEarned'] as num).toInt(),
      totalStarsEarned: (json['TotalStarsEarned'] as num).toInt(),
      activeDays: (json['ActiveDays'] as num).toInt(),
      dailyBreakdown: (json['DailyBreakdown'] as List<dynamic>)
          .map((e) => DailySummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$WeeklySummaryImplToJson(_$WeeklySummaryImpl instance) =>
    <String, dynamic>{
      'ChildId': instance.childId,
      'WeekStart': instance.weekStart.toIso8601String(),
      'WeekEnd': instance.weekEnd.toIso8601String(),
      'TotalQuestionsAnswered': instance.totalQuestionsAnswered,
      'CorrectAnswers': instance.correctAnswers,
      'WrongAnswers': instance.wrongAnswers,
      'CorrectAnswerRate': instance.correctAnswerRate,
      'LevelsCompleted': instance.levelsCompleted,
      'TotalPointsEarned': instance.totalPointsEarned,
      'TotalStarsEarned': instance.totalStarsEarned,
      'ActiveDays': instance.activeDays,
      'DailyBreakdown': instance.dailyBreakdown,
    };
