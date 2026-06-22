// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserDto _$UserDtoFromJson(Map<String, dynamic> json) {
  return _UserDto.fromJson(json);
}

/// @nodoc
mixin _$UserDto {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Email')
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'Role')
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'CanUseOnlineSpeech')
  bool get canUseOnlineSpeech => throw _privateConstructorUsedError;
  @JsonKey(name: 'ParentProfile')
  ParentProfileDto? get parentProfile => throw _privateConstructorUsedError;

  /// Serializes this UserDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDtoCopyWith<UserDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDtoCopyWith<$Res> {
  factory $UserDtoCopyWith(UserDto value, $Res Function(UserDto) then) =
      _$UserDtoCopyWithImpl<$Res, UserDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Email') String email,
    @JsonKey(name: 'Role') String role,
    @JsonKey(name: 'CanUseOnlineSpeech') bool canUseOnlineSpeech,
    @JsonKey(name: 'ParentProfile') ParentProfileDto? parentProfile,
  });

  $ParentProfileDtoCopyWith<$Res>? get parentProfile;
}

/// @nodoc
class _$UserDtoCopyWithImpl<$Res, $Val extends UserDto>
    implements $UserDtoCopyWith<$Res> {
  _$UserDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? role = null,
    Object? canUseOnlineSpeech = null,
    Object? parentProfile = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            canUseOnlineSpeech: null == canUseOnlineSpeech
                ? _value.canUseOnlineSpeech
                : canUseOnlineSpeech // ignore: cast_nullable_to_non_nullable
                      as bool,
            parentProfile: freezed == parentProfile
                ? _value.parentProfile
                : parentProfile // ignore: cast_nullable_to_non_nullable
                      as ParentProfileDto?,
          )
          as $Val,
    );
  }

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParentProfileDtoCopyWith<$Res>? get parentProfile {
    if (_value.parentProfile == null) {
      return null;
    }

    return $ParentProfileDtoCopyWith<$Res>(_value.parentProfile!, (value) {
      return _then(_value.copyWith(parentProfile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserDtoImplCopyWith<$Res> implements $UserDtoCopyWith<$Res> {
  factory _$$UserDtoImplCopyWith(
    _$UserDtoImpl value,
    $Res Function(_$UserDtoImpl) then,
  ) = __$$UserDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Email') String email,
    @JsonKey(name: 'Role') String role,
    @JsonKey(name: 'CanUseOnlineSpeech') bool canUseOnlineSpeech,
    @JsonKey(name: 'ParentProfile') ParentProfileDto? parentProfile,
  });

  @override
  $ParentProfileDtoCopyWith<$Res>? get parentProfile;
}

/// @nodoc
class __$$UserDtoImplCopyWithImpl<$Res>
    extends _$UserDtoCopyWithImpl<$Res, _$UserDtoImpl>
    implements _$$UserDtoImplCopyWith<$Res> {
  __$$UserDtoImplCopyWithImpl(
    _$UserDtoImpl _value,
    $Res Function(_$UserDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? role = null,
    Object? canUseOnlineSpeech = null,
    Object? parentProfile = freezed,
  }) {
    return _then(
      _$UserDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        canUseOnlineSpeech: null == canUseOnlineSpeech
            ? _value.canUseOnlineSpeech
            : canUseOnlineSpeech // ignore: cast_nullable_to_non_nullable
                  as bool,
        parentProfile: freezed == parentProfile
            ? _value.parentProfile
            : parentProfile // ignore: cast_nullable_to_non_nullable
                  as ParentProfileDto?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDtoImpl implements _UserDto {
  const _$UserDtoImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'Email') required this.email,
    @JsonKey(name: 'Role') required this.role,
    @JsonKey(name: 'CanUseOnlineSpeech') this.canUseOnlineSpeech = false,
    @JsonKey(name: 'ParentProfile') this.parentProfile,
  });

  factory _$UserDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'Email')
  final String email;
  @override
  @JsonKey(name: 'Role')
  final String role;
  @override
  @JsonKey(name: 'CanUseOnlineSpeech')
  final bool canUseOnlineSpeech;
  @override
  @JsonKey(name: 'ParentProfile')
  final ParentProfileDto? parentProfile;

  @override
  String toString() {
    return 'UserDto(id: $id, email: $email, role: $role, canUseOnlineSpeech: $canUseOnlineSpeech, parentProfile: $parentProfile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.canUseOnlineSpeech, canUseOnlineSpeech) ||
                other.canUseOnlineSpeech == canUseOnlineSpeech) &&
            (identical(other.parentProfile, parentProfile) ||
                other.parentProfile == parentProfile));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    role,
    canUseOnlineSpeech,
    parentProfile,
  );

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDtoImplCopyWith<_$UserDtoImpl> get copyWith =>
      __$$UserDtoImplCopyWithImpl<_$UserDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDtoImplToJson(this);
  }
}

abstract class _UserDto implements UserDto {
  const factory _UserDto({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'Email') required final String email,
    @JsonKey(name: 'Role') required final String role,
    @JsonKey(name: 'CanUseOnlineSpeech') final bool canUseOnlineSpeech,
    @JsonKey(name: 'ParentProfile') final ParentProfileDto? parentProfile,
  }) = _$UserDtoImpl;

  factory _UserDto.fromJson(Map<String, dynamic> json) = _$UserDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'Email')
  String get email;
  @override
  @JsonKey(name: 'Role')
  String get role;
  @override
  @JsonKey(name: 'CanUseOnlineSpeech')
  bool get canUseOnlineSpeech;
  @override
  @JsonKey(name: 'ParentProfile')
  ParentProfileDto? get parentProfile;

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDtoImplCopyWith<_$UserDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
