// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChildProfileDtoImpl _$$ChildProfileDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ChildProfileDtoImpl(
  id: json['Id'] as String,
  name: json['Name'] as String,
  dateOfBirth: DateTime.parse(json['DateOfBirth'] as String),
  age: (json['Age'] as num).toInt(),
  gradeLevel: json['GradeLevel'] as String,
  profileType: json['ProfileType'] as String? ?? 'Child',
  englishLevel: json['EnglishLevel'] as String?,
  avatarImageUrl: json['AvatarImageUrl'] as String?,
  photoUrl: json['PhotoUrl'] as String?,
  useAvatarAsProfile: json['UseAvatarAsProfile'] as bool? ?? false,
  totalCoins: (json['TotalCoins'] as num?)?.toInt() ?? 0,
  totalStars: (json['TotalStars'] as num?)?.toInt() ?? 0,
  podcastListeningMode: (json['PodcastListeningMode'] as num?)?.toInt() ?? 0,
  friendCode: json['FriendCode'] as String?,
  isTeacher: json['IsTeacher'] as bool? ?? false,
);

Map<String, dynamic> _$$ChildProfileDtoImplToJson(
  _$ChildProfileDtoImpl instance,
) => <String, dynamic>{
  'Id': instance.id,
  'Name': instance.name,
  'DateOfBirth': instance.dateOfBirth.toIso8601String(),
  'Age': instance.age,
  'GradeLevel': instance.gradeLevel,
  'ProfileType': instance.profileType,
  'EnglishLevel': instance.englishLevel,
  'AvatarImageUrl': instance.avatarImageUrl,
  'PhotoUrl': instance.photoUrl,
  'UseAvatarAsProfile': instance.useAvatarAsProfile,
  'TotalCoins': instance.totalCoins,
  'TotalStars': instance.totalStars,
  'PodcastListeningMode': instance.podcastListeningMode,
  'FriendCode': instance.friendCode,
  'IsTeacher': instance.isTeacher,
};
