import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_child_profile_request.freezed.dart';
part 'create_child_profile_request.g.dart';

@freezed
class CreateChildProfileRequest with _$CreateChildProfileRequest {
  const factory CreateChildProfileRequest({
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'DateOfBirth') required DateTime dateOfBirth,
    @JsonKey(name: 'GradeLevel') required int gradeLevel,
    @JsonKey(name: 'EnglishLevel') int? englishLevel,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'PodcastListeningMode') @Default(0) int podcastListeningMode,
  }) = _CreateChildProfileRequest;

  factory CreateChildProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateChildProfileRequestFromJson(json);
}
