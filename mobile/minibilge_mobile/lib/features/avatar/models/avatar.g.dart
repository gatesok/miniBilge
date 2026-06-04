// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AvatarImpl _$$AvatarImplFromJson(Map<String, dynamic> json) => _$AvatarImpl(
  id: json['Id'] as String,
  name: json['Name'] as String,
  imageUrl: json['ImageUrl'] as String,
  isDefault: json['IsDefault'] as bool,
);

Map<String, dynamic> _$$AvatarImplToJson(_$AvatarImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'ImageUrl': instance.imageUrl,
      'IsDefault': instance.isDefault,
    };
