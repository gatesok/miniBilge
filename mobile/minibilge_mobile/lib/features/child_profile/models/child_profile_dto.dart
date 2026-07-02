import 'package:freezed_annotation/freezed_annotation.dart';
import 'grade_level.dart';
import 'english_level.dart';

part 'child_profile_dto.freezed.dart';
part 'child_profile_dto.g.dart';

@freezed
class ChildProfileDto with _$ChildProfileDto {
  const factory ChildProfileDto({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'DateOfBirth') required DateTime dateOfBirth,
    @JsonKey(name: 'Age') required int age,
    @JsonKey(name: 'GradeLevel') required String gradeLevel,
    @JsonKey(name: 'EnglishLevel') String? englishLevel,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'TotalCoins') @Default(0) int totalCoins,
    @JsonKey(name: 'TotalStars') @Default(0) int totalStars,
    // 0 = Offline (cihaz TTS), 1 = Online (Google TTS)
    @JsonKey(name: 'PodcastListeningMode') @Default(0) int podcastListeningMode,
    @JsonKey(name: 'FriendCode') String? friendCode,
    @JsonKey(name: 'IsTeacher') @Default(false) bool isTeacher,
  }) = _ChildProfileDto;

  factory ChildProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ChildProfileDtoFromJson(json);
}

extension ChildProfileDtoX on ChildProfileDto {
  GradeLevel? get gradeLevelEnum => GradeLevel.fromString(gradeLevel);
  EnglishLevel? get englishLevelEnum => EnglishLevel.fromString(englishLevel);
}
