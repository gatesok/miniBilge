// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChildProgressImpl _$$ChildProgressImplFromJson(Map<String, dynamic> json) =>
    _$ChildProgressImpl(
      id: json['Id'] as String,
      childId: json['ChildId'] as String,
      totalScore: (json['TotalScore'] as num).toInt(),
      totalStars: (json['TotalStars'] as num).toInt(),
      completedLevelsCount: (json['CompletedLevelsCount'] as num).toInt(),
    );

Map<String, dynamic> _$$ChildProgressImplToJson(_$ChildProgressImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'ChildId': instance.childId,
      'TotalScore': instance.totalScore,
      'TotalStars': instance.totalStars,
      'CompletedLevelsCount': instance.completedLevelsCount,
    };
