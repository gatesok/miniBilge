import 'package:freezed_annotation/freezed_annotation.dart';
import 'parent_profile_dto.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'Email') required String email,
    @JsonKey(name: 'Role') required String role,
    @JsonKey(name: 'CanUseOnlineSpeech') @Default(false) bool canUseOnlineSpeech,
    @JsonKey(name: 'IsTeacher') @Default(false) bool isTeacher,
    @JsonKey(name: 'ParentProfile') ParentProfileDto? parentProfile,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}
