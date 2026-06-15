// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) {
  return _RegisterRequest.fromJson(json);
}

/// @nodoc
mixin _$RegisterRequest {
  @JsonKey(name: 'Email')
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'Password')
  String get password => throw _privateConstructorUsedError;
  @JsonKey(name: 'ConfirmPassword')
  String get confirmPassword => throw _privateConstructorUsedError;
  @JsonKey(name: 'FirstName')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'LastName')
  String get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'PhoneNumber')
  String? get phoneNumber => throw _privateConstructorUsedError;

  /// Serializes this RegisterRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterRequestCopyWith<RegisterRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterRequestCopyWith<$Res> {
  factory $RegisterRequestCopyWith(
    RegisterRequest value,
    $Res Function(RegisterRequest) then,
  ) = _$RegisterRequestCopyWithImpl<$Res, RegisterRequest>;
  @useResult
  $Res call({
    @JsonKey(name: 'Email') String email,
    @JsonKey(name: 'Password') String password,
    @JsonKey(name: 'ConfirmPassword') String confirmPassword,
    @JsonKey(name: 'FirstName') String firstName,
    @JsonKey(name: 'LastName') String lastName,
    @JsonKey(name: 'PhoneNumber') String? phoneNumber,
  });
}

/// @nodoc
class _$RegisterRequestCopyWithImpl<$Res, $Val extends RegisterRequest>
    implements $RegisterRequestCopyWith<$Res> {
  _$RegisterRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? confirmPassword = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? phoneNumber = freezed,
  }) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            confirmPassword: null == confirmPassword
                ? _value.confirmPassword
                : confirmPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RegisterRequestImplCopyWith<$Res>
    implements $RegisterRequestCopyWith<$Res> {
  factory _$$RegisterRequestImplCopyWith(
    _$RegisterRequestImpl value,
    $Res Function(_$RegisterRequestImpl) then,
  ) = __$$RegisterRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Email') String email,
    @JsonKey(name: 'Password') String password,
    @JsonKey(name: 'ConfirmPassword') String confirmPassword,
    @JsonKey(name: 'FirstName') String firstName,
    @JsonKey(name: 'LastName') String lastName,
    @JsonKey(name: 'PhoneNumber') String? phoneNumber,
  });
}

/// @nodoc
class __$$RegisterRequestImplCopyWithImpl<$Res>
    extends _$RegisterRequestCopyWithImpl<$Res, _$RegisterRequestImpl>
    implements _$$RegisterRequestImplCopyWith<$Res> {
  __$$RegisterRequestImplCopyWithImpl(
    _$RegisterRequestImpl _value,
    $Res Function(_$RegisterRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? confirmPassword = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? phoneNumber = freezed,
  }) {
    return _then(
      _$RegisterRequestImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        confirmPassword: null == confirmPassword
            ? _value.confirmPassword
            : confirmPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterRequestImpl implements _RegisterRequest {
  const _$RegisterRequestImpl({
    @JsonKey(name: 'Email') required this.email,
    @JsonKey(name: 'Password') required this.password,
    @JsonKey(name: 'ConfirmPassword') required this.confirmPassword,
    @JsonKey(name: 'FirstName') required this.firstName,
    @JsonKey(name: 'LastName') required this.lastName,
    @JsonKey(name: 'PhoneNumber') this.phoneNumber,
  });

  factory _$RegisterRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterRequestImplFromJson(json);

  @override
  @JsonKey(name: 'Email')
  final String email;
  @override
  @JsonKey(name: 'Password')
  final String password;
  @override
  @JsonKey(name: 'ConfirmPassword')
  final String confirmPassword;
  @override
  @JsonKey(name: 'FirstName')
  final String firstName;
  @override
  @JsonKey(name: 'LastName')
  final String lastName;
  @override
  @JsonKey(name: 'PhoneNumber')
  final String? phoneNumber;

  @override
  String toString() {
    return 'RegisterRequest(email: $email, password: $password, confirmPassword: $confirmPassword, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.confirmPassword, confirmPassword) ||
                other.confirmPassword == confirmPassword) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    email,
    password,
    confirmPassword,
    firstName,
    lastName,
    phoneNumber,
  );

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterRequestImplCopyWith<_$RegisterRequestImpl> get copyWith =>
      __$$RegisterRequestImplCopyWithImpl<_$RegisterRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterRequestImplToJson(this);
  }
}

abstract class _RegisterRequest implements RegisterRequest {
  const factory _RegisterRequest({
    @JsonKey(name: 'Email') required final String email,
    @JsonKey(name: 'Password') required final String password,
    @JsonKey(name: 'ConfirmPassword') required final String confirmPassword,
    @JsonKey(name: 'FirstName') required final String firstName,
    @JsonKey(name: 'LastName') required final String lastName,
    @JsonKey(name: 'PhoneNumber') final String? phoneNumber,
  }) = _$RegisterRequestImpl;

  factory _RegisterRequest.fromJson(Map<String, dynamic> json) =
      _$RegisterRequestImpl.fromJson;

  @override
  @JsonKey(name: 'Email')
  String get email;
  @override
  @JsonKey(name: 'Password')
  String get password;
  @override
  @JsonKey(name: 'ConfirmPassword')
  String get confirmPassword;
  @override
  @JsonKey(name: 'FirstName')
  String get firstName;
  @override
  @JsonKey(name: 'LastName')
  String get lastName;
  @override
  @JsonKey(name: 'PhoneNumber')
  String? get phoneNumber;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterRequestImplCopyWith<_$RegisterRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
