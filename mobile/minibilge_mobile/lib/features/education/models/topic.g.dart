// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopicImpl _$$TopicImplFromJson(Map<String, dynamic> json) => _$TopicImpl(
      id: json['Id'] as String,
      subjectId: json['SubjectId'] as String,
      name: json['Name'] as String,
      description: json['Description'] as String,
      displayOrder: (json['DisplayOrder'] as num).toInt(),
      isActive: json['IsActive'] as bool,
    );

Map<String, dynamic> _$$TopicImplToJson(_$TopicImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'SubjectId': instance.subjectId,
      'Name': instance.name,
      'Description': instance.description,
      'DisplayOrder': instance.displayOrder,
      'IsActive': instance.isActive,
    };
