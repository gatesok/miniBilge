// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_child_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdateChildProfileRequestImpl _$$UpdateChildProfileRequestImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateChildProfileRequestImpl(
  name: json['Name'] as String,
  dateOfBirth: DateTime.parse(json['DateOfBirth'] as String),
  gradeLevel: (json['GradeLevel'] as num).toInt(),
  englishLevel: (json['EnglishLevel'] as num?)?.toInt(),
  avatarImageUrl: json['AvatarImageUrl'] as String?,
  podcastListeningMode: (json['PodcastListeningMode'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$UpdateChildProfileRequestImplToJson(
  _$UpdateChildProfileRequestImpl instance,
) => <String, dynamic>{
  'Name': instance.name,
  'DateOfBirth': instance.dateOfBirth.toIso8601String(),
  'GradeLevel': instance.gradeLevel,
  'EnglishLevel': instance.englishLevel,
  'AvatarImageUrl': instance.avatarImageUrl,
  'PodcastListeningMode': instance.podcastListeningMode,
};
