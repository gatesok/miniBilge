// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubjectImpl _$$SubjectImplFromJson(Map<String, dynamic> json) =>
    _$SubjectImpl(
      id: json['Id'] as String,
      name: json['Name'] as String,
      displayOrder: (json['DisplayOrder'] as num).toInt(),
      isActive: json['IsActive'] as bool,
    );

Map<String, dynamic> _$$SubjectImplToJson(_$SubjectImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'DisplayOrder': instance.displayOrder,
      'IsActive': instance.isActive,
    };
