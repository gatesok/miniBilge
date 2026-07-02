import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request.freezed.dart';
part 'register_request.g.dart';

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    @JsonKey(name: 'Email') required String email,
    @JsonKey(name: 'Password') required String password,
    @JsonKey(name: 'ConfirmPassword') required String confirmPassword,
    @JsonKey(name: 'FirstName') required String firstName,
    @JsonKey(name: 'LastName') required String lastName,
    @JsonKey(name: 'PhoneNumber') String? phoneNumber,
    @JsonKey(name: 'IsTeacher') @Default(false) bool isTeacher,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}
