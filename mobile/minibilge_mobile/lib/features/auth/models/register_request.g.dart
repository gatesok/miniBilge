// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegisterRequestImpl _$$RegisterRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$RegisterRequestImpl(
      email: json['Email'] as String,
      password: json['Password'] as String,
      confirmPassword: json['ConfirmPassword'] as String,
      firstName: json['FirstName'] as String,
      lastName: json['LastName'] as String,
      phoneNumber: json['PhoneNumber'] as String?,
    );

Map<String, dynamic> _$$RegisterRequestImplToJson(
        _$RegisterRequestImpl instance) =>
    <String, dynamic>{
      'Email': instance.email,
      'Password': instance.password,
      'ConfirmPassword': instance.confirmPassword,
      'FirstName': instance.firstName,
      'LastName': instance.lastName,
      'PhoneNumber': instance.phoneNumber,
    };
