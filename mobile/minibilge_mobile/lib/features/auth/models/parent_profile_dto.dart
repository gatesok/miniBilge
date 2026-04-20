import 'package:freezed_annotation/freezed_annotation.dart';

part 'parent_profile_dto.freezed.dart';
part 'parent_profile_dto.g.dart';

@freezed
class ParentProfileDto with _$ParentProfileDto {
  const factory ParentProfileDto({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'FirstName') required String firstName,
    @JsonKey(name: 'LastName') required String lastName,
    @JsonKey(name: 'PhoneNumber') String? phoneNumber,
    @JsonKey(name: 'ChildrenCount') required int childrenCount,
  }) = _ParentProfileDto;

  factory ParentProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ParentProfileDtoFromJson(json);
}
