// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDtoImpl _$$UserDtoImplFromJson(Map<String, dynamic> json) =>
    _$UserDtoImpl(
      id: json['Id'] as String,
      email: json['Email'] as String,
      role: json['Role'] as String,
      canUseOnlineSpeech: json['CanUseOnlineSpeech'] as bool? ?? false,
      experienceMode: json['ExperienceMode'] as String? ?? 'Family',
      hasSelectedExperienceMode:
          json['HasSelectedExperienceMode'] as bool? ?? true,
      parentProfile: json['ParentProfile'] == null
          ? null
          : ParentProfileDto.fromJson(
              json['ParentProfile'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$UserDtoImplToJson(_$UserDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Email': instance.email,
      'Role': instance.role,
      'CanUseOnlineSpeech': instance.canUseOnlineSpeech,
      'ExperienceMode': instance.experienceMode,
      'HasSelectedExperienceMode': instance.hasSelectedExperienceMode,
      'ParentProfile': instance.parentProfile,
    };
