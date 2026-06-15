// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParentProfileDtoImpl _$$ParentProfileDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ParentProfileDtoImpl(
  id: json['Id'] as String,
  firstName: json['FirstName'] as String,
  lastName: json['LastName'] as String,
  phoneNumber: json['PhoneNumber'] as String?,
  childrenCount: (json['ChildrenCount'] as num).toInt(),
);

Map<String, dynamic> _$$ParentProfileDtoImplToJson(
  _$ParentProfileDtoImpl instance,
) => <String, dynamic>{
  'Id': instance.id,
  'FirstName': instance.firstName,
  'LastName': instance.lastName,
  'PhoneNumber': instance.phoneNumber,
  'ChildrenCount': instance.childrenCount,
};
