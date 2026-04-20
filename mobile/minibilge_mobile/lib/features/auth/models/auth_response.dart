import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_dto.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @JsonKey(name: 'AccessToken') required String accessToken,
    @JsonKey(name: 'RefreshToken') required String refreshToken,
    @JsonKey(name: 'ExpiresAt') required DateTime expiresAt,
    @JsonKey(name: 'User') required UserDto user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
