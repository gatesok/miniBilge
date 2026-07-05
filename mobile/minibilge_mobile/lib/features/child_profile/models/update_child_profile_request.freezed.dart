// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_child_profile_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UpdateChildProfileRequest _$UpdateChildProfileRequestFromJson(
  Map<String, dynamic> json,
) {
  return _UpdateChildProfileRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateChildProfileRequest {
  @JsonKey(name: 'Name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'DateOfBirth')
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  @JsonKey(name: 'GradeLevel')
  int get gradeLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'EnglishLevel')
  int? get englishLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'AvatarImageUrl')
  String? get avatarImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'PodcastListeningMode')
  int get podcastListeningMode => throw _privateConstructorUsedError;
  @JsonKey(name: 'UseAvatarAsProfile')
  bool? get useAvatarAsProfile => throw _privateConstructorUsedError;

  /// Serializes this UpdateChildProfileRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateChildProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateChildProfileRequestCopyWith<UpdateChildProfileRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateChildProfileRequestCopyWith<$Res> {
  factory $UpdateChildProfileRequestCopyWith(
    UpdateChildProfileRequest value,
    $Res Function(UpdateChildProfileRequest) then,
  ) = _$UpdateChildProfileRequestCopyWithImpl<$Res, UpdateChildProfileRequest>;
  @useResult
  $Res call({
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'DateOfBirth') DateTime dateOfBirth,
    @JsonKey(name: 'GradeLevel') int gradeLevel,
    @JsonKey(name: 'EnglishLevel') int? englishLevel,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'PodcastListeningMode') int podcastListeningMode,
    @JsonKey(name: 'UseAvatarAsProfile') bool? useAvatarAsProfile,
  });
}

/// @nodoc
class _$UpdateChildProfileRequestCopyWithImpl<
  $Res,
  $Val extends UpdateChildProfileRequest
>
    implements $UpdateChildProfileRequestCopyWith<$Res> {
  _$UpdateChildProfileRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateChildProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dateOfBirth = null,
    Object? gradeLevel = null,
    Object? englishLevel = freezed,
    Object? avatarImageUrl = freezed,
    Object? podcastListeningMode = null,
    Object? useAvatarAsProfile = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            dateOfBirth: null == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            gradeLevel: null == gradeLevel
                ? _value.gradeLevel
                : gradeLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            englishLevel: freezed == englishLevel
                ? _value.englishLevel
                : englishLevel // ignore: cast_nullable_to_non_nullable
                      as int?,
            avatarImageUrl: freezed == avatarImageUrl
                ? _value.avatarImageUrl
                : avatarImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            podcastListeningMode: null == podcastListeningMode
                ? _value.podcastListeningMode
                : podcastListeningMode // ignore: cast_nullable_to_non_nullable
                      as int,
            useAvatarAsProfile: freezed == useAvatarAsProfile
                ? _value.useAvatarAsProfile
                : useAvatarAsProfile // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateChildProfileRequestImplCopyWith<$Res>
    implements $UpdateChildProfileRequestCopyWith<$Res> {
  factory _$$UpdateChildProfileRequestImplCopyWith(
    _$UpdateChildProfileRequestImpl value,
    $Res Function(_$UpdateChildProfileRequestImpl) then,
  ) = __$$UpdateChildProfileRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'DateOfBirth') DateTime dateOfBirth,
    @JsonKey(name: 'GradeLevel') int gradeLevel,
    @JsonKey(name: 'EnglishLevel') int? englishLevel,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'PodcastListeningMode') int podcastListeningMode,
    @JsonKey(name: 'UseAvatarAsProfile') bool? useAvatarAsProfile,
  });
}

/// @nodoc
class __$$UpdateChildProfileRequestImplCopyWithImpl<$Res>
    extends
        _$UpdateChildProfileRequestCopyWithImpl<
          $Res,
          _$UpdateChildProfileRequestImpl
        >
    implements _$$UpdateChildProfileRequestImplCopyWith<$Res> {
  __$$UpdateChildProfileRequestImplCopyWithImpl(
    _$UpdateChildProfileRequestImpl _value,
    $Res Function(_$UpdateChildProfileRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateChildProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dateOfBirth = null,
    Object? gradeLevel = null,
    Object? englishLevel = freezed,
    Object? avatarImageUrl = freezed,
    Object? podcastListeningMode = null,
    Object? useAvatarAsProfile = freezed,
  }) {
    return _then(
      _$UpdateChildProfileRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        dateOfBirth: null == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        gradeLevel: null == gradeLevel
            ? _value.gradeLevel
            : gradeLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        englishLevel: freezed == englishLevel
            ? _value.englishLevel
            : englishLevel // ignore: cast_nullable_to_non_nullable
                  as int?,
        avatarImageUrl: freezed == avatarImageUrl
            ? _value.avatarImageUrl
            : avatarImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        podcastListeningMode: null == podcastListeningMode
            ? _value.podcastListeningMode
            : podcastListeningMode // ignore: cast_nullable_to_non_nullable
                  as int,
        useAvatarAsProfile: freezed == useAvatarAsProfile
            ? _value.useAvatarAsProfile
            : useAvatarAsProfile // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateChildProfileRequestImpl implements _UpdateChildProfileRequest {
  const _$UpdateChildProfileRequestImpl({
    @JsonKey(name: 'Name') required this.name,
    @JsonKey(name: 'DateOfBirth') required this.dateOfBirth,
    @JsonKey(name: 'GradeLevel') required this.gradeLevel,
    @JsonKey(name: 'EnglishLevel') this.englishLevel,
    @JsonKey(name: 'AvatarImageUrl') this.avatarImageUrl,
    @JsonKey(name: 'PodcastListeningMode') this.podcastListeningMode = 0,
    @JsonKey(name: 'UseAvatarAsProfile') this.useAvatarAsProfile,
  });

  factory _$UpdateChildProfileRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateChildProfileRequestImplFromJson(json);

  @override
  @JsonKey(name: 'Name')
  final String name;
  @override
  @JsonKey(name: 'DateOfBirth')
  final DateTime dateOfBirth;
  @override
  @JsonKey(name: 'GradeLevel')
  final int gradeLevel;
  @override
  @JsonKey(name: 'EnglishLevel')
  final int? englishLevel;
  @override
  @JsonKey(name: 'AvatarImageUrl')
  final String? avatarImageUrl;
  @override
  @JsonKey(name: 'PodcastListeningMode')
  final int podcastListeningMode;
  @override
  @JsonKey(name: 'UseAvatarAsProfile')
  final bool? useAvatarAsProfile;

  @override
  String toString() {
    return 'UpdateChildProfileRequest(name: $name, dateOfBirth: $dateOfBirth, gradeLevel: $gradeLevel, englishLevel: $englishLevel, avatarImageUrl: $avatarImageUrl, podcastListeningMode: $podcastListeningMode, useAvatarAsProfile: $useAvatarAsProfile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateChildProfileRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gradeLevel, gradeLevel) ||
                other.gradeLevel == gradeLevel) &&
            (identical(other.englishLevel, englishLevel) ||
                other.englishLevel == englishLevel) &&
            (identical(other.avatarImageUrl, avatarImageUrl) ||
                other.avatarImageUrl == avatarImageUrl) &&
            (identical(other.podcastListeningMode, podcastListeningMode) ||
                other.podcastListeningMode == podcastListeningMode) &&
            (identical(other.useAvatarAsProfile, useAvatarAsProfile) ||
                other.useAvatarAsProfile == useAvatarAsProfile));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    dateOfBirth,
    gradeLevel,
    englishLevel,
    avatarImageUrl,
    podcastListeningMode,
    useAvatarAsProfile,
  );

  /// Create a copy of UpdateChildProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateChildProfileRequestImplCopyWith<_$UpdateChildProfileRequestImpl>
  get copyWith =>
      __$$UpdateChildProfileRequestImplCopyWithImpl<
        _$UpdateChildProfileRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateChildProfileRequestImplToJson(this);
  }
}

abstract class _UpdateChildProfileRequest implements UpdateChildProfileRequest {
  const factory _UpdateChildProfileRequest({
    @JsonKey(name: 'Name') required final String name,
    @JsonKey(name: 'DateOfBirth') required final DateTime dateOfBirth,
    @JsonKey(name: 'GradeLevel') required final int gradeLevel,
    @JsonKey(name: 'EnglishLevel') final int? englishLevel,
    @JsonKey(name: 'AvatarImageUrl') final String? avatarImageUrl,
    @JsonKey(name: 'PodcastListeningMode') final int podcastListeningMode,
    @JsonKey(name: 'UseAvatarAsProfile') final bool? useAvatarAsProfile,
  }) = _$UpdateChildProfileRequestImpl;

  factory _UpdateChildProfileRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateChildProfileRequestImpl.fromJson;

  @override
  @JsonKey(name: 'Name')
  String get name;
  @override
  @JsonKey(name: 'DateOfBirth')
  DateTime get dateOfBirth;
  @override
  @JsonKey(name: 'GradeLevel')
  int get gradeLevel;
  @override
  @JsonKey(name: 'EnglishLevel')
  int? get englishLevel;
  @override
  @JsonKey(name: 'AvatarImageUrl')
  String? get avatarImageUrl;
  @override
  @JsonKey(name: 'PodcastListeningMode')
  int get podcastListeningMode;
  @override
  @JsonKey(name: 'UseAvatarAsProfile')
  bool? get useAvatarAsProfile;

  /// Create a copy of UpdateChildProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateChildProfileRequestImplCopyWith<_$UpdateChildProfileRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
