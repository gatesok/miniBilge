// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_child_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateChildProfileRequestImpl _$$CreateChildProfileRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateChildProfileRequestImpl(
      name: json['Name'] as String,
      dateOfBirth: DateTime.parse(json['DateOfBirth'] as String),
      gradeLevel: (json['GradeLevel'] as num).toInt(),
      avatarImageUrl: json['AvatarImageUrl'] as String?,
    );

Map<String, dynamic> _$$CreateChildProfileRequestImplToJson(
        _$CreateChildProfileRequestImpl instance) =>
    <String, dynamic>{
      'Name': instance.name,
      'DateOfBirth': instance.dateOfBirth.toIso8601String(),
      'GradeLevel': instance.gradeLevel,
      'AvatarImageUrl': instance.avatarImageUrl,
    };
