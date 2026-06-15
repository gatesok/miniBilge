// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LevelImpl _$$LevelImplFromJson(Map<String, dynamic> json) => _$LevelImpl(
  id: json['Id'] as String,
  topicId: json['TopicId'] as String,
  name: json['Name'] as String,
  description: json['Description'] as String?,
  difficulty: (json['Difficulty'] as num).toInt(),
  displayOrder: (json['DisplayOrder'] as num).toInt(),
  minCorrectToPass: (json['MinCorrectToPass'] as num).toInt(),
  isActive: json['IsActive'] as bool,
);

Map<String, dynamic> _$$LevelImplToJson(_$LevelImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'TopicId': instance.topicId,
      'Name': instance.name,
      'Description': instance.description,
      'Difficulty': instance.difficulty,
      'DisplayOrder': instance.displayOrder,
      'MinCorrectToPass': instance.minCorrectToPass,
      'IsActive': instance.isActive,
    };
