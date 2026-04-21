// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LevelResultImpl _$$LevelResultImplFromJson(Map<String, dynamic> json) =>
    _$LevelResultImpl(
      id: json['Id'] as String,
      childId: json['ChildId'] as String,
      levelId: json['LevelId'] as String,
      score: (json['Score'] as num).toInt(),
      stars: (json['Stars'] as num).toInt(),
      correctCount: (json['CorrectCount'] as num).toInt(),
      totalQuestions: (json['TotalQuestions'] as num).toInt(),
      successPercentage: (json['SuccessPercentage'] as num).toDouble(),
      isUnlocked: json['IsUnlocked'] as bool,
      completedAt: json['CompletedAt'] as String?,
    );

Map<String, dynamic> _$$LevelResultImplToJson(_$LevelResultImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'ChildId': instance.childId,
      'LevelId': instance.levelId,
      'Score': instance.score,
      'Stars': instance.stars,
      'CorrectCount': instance.correctCount,
      'TotalQuestions': instance.totalQuestions,
      'SuccessPercentage': instance.successPercentage,
      'IsUnlocked': instance.isUnlocked,
      'CompletedAt': instance.completedAt,
    };
