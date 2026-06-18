import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_child_profile_request.freezed.dart';
part 'update_child_profile_request.g.dart';

@freezed
class UpdateChildProfileRequest with _$UpdateChildProfileRequest {
  const factory UpdateChildProfileRequest({
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'DateOfBirth') required DateTime dateOfBirth,
    @JsonKey(name: 'GradeLevel') required int gradeLevel,
    @JsonKey(name: 'EnglishLevel') int? englishLevel,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
  }) = _UpdateChildProfileRequest;

  factory UpdateChildProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateChildProfileRequestFromJson(json);
}
