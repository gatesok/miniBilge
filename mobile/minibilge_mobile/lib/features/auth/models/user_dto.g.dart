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
      'ParentProfile': instance.parentProfile,
    };
