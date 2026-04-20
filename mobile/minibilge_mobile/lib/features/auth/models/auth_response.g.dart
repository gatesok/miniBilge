// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      accessToken: json['AccessToken'] as String,
      refreshToken: json['RefreshToken'] as String,
      expiresAt: DateTime.parse(json['ExpiresAt'] as String),
      user: UserDto.fromJson(json['User'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'AccessToken': instance.accessToken,
      'RefreshToken': instance.refreshToken,
      'ExpiresAt': instance.expiresAt.toIso8601String(),
      'User': instance.user,
    };
