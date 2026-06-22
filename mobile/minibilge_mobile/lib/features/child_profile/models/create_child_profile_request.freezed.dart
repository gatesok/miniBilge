// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_child_profile_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateChildProfileRequest _$CreateChildProfileRequestFromJson(
  Map<String, dynamic> json,
) {
  return _CreateChildProfileRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateChildProfileRequest {
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

  /// Serializes this CreateChildProfileRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateChildProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateChildProfileRequestCopyWith<CreateChildProfileRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateChildProfileRequestCopyWith<$Res> {
  factory $CreateChildProfileRequestCopyWith(
    CreateChildProfileRequest value,
    $Res Function(CreateChildProfileRequest) then,
  ) = _$CreateChildProfileRequestCopyWithImpl<$Res, CreateChildProfileRequest>;
  @useResult
  $Res call({
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'DateOfBirth') DateTime dateOfBirth,
    @JsonKey(name: 'GradeLevel') int gradeLevel,
    @JsonKey(name: 'EnglishLevel') int? englishLevel,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'PodcastListeningMode') int podcastListeningMode,
  });
}

/// @nodoc
class _$CreateChildProfileRequestCopyWithImpl<
  $Res,
  $Val extends CreateChildProfileRequest
>
    implements $CreateChildProfileRequestCopyWith<$Res> {
  _$CreateChildProfileRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateChildProfileRequest
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateChildProfileRequestImplCopyWith<$Res>
    implements $CreateChildProfileRequestCopyWith<$Res> {
  factory _$$CreateChildProfileRequestImplCopyWith(
    _$CreateChildProfileRequestImpl value,
    $Res Function(_$CreateChildProfileRequestImpl) then,
  ) = __$$CreateChildProfileRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'DateOfBirth') DateTime dateOfBirth,
    @JsonKey(name: 'GradeLevel') int gradeLevel,
    @JsonKey(name: 'EnglishLevel') int? englishLevel,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'PodcastListeningMode') int podcastListeningMode,
  });
}

/// @nodoc
class __$$CreateChildProfileRequestImplCopyWithImpl<$Res>
    extends
        _$CreateChildProfileRequestCopyWithImpl<
          $Res,
          _$CreateChildProfileRequestImpl
        >
    implements _$$CreateChildProfileRequestImplCopyWith<$Res> {
  __$$CreateChildProfileRequestImplCopyWithImpl(
    _$CreateChildProfileRequestImpl _value,
    $Res Function(_$CreateChildProfileRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateChildProfileRequest
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
  }) {
    return _then(
      _$CreateChildProfileRequestImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateChildProfileRequestImpl implements _CreateChildProfileRequest {
  const _$CreateChildProfileRequestImpl({
    @JsonKey(name: 'Name') required this.name,
    @JsonKey(name: 'DateOfBirth') required this.dateOfBirth,
    @JsonKey(name: 'GradeLevel') required this.gradeLevel,
    @JsonKey(name: 'EnglishLevel') this.englishLevel,
    @JsonKey(name: 'AvatarImageUrl') this.avatarImageUrl,
    @JsonKey(name: 'PodcastListeningMode') this.podcastListeningMode = 0,
  });

  factory _$CreateChildProfileRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateChildProfileRequestImplFromJson(json);

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
  String toString() {
    return 'CreateChildProfileRequest(name: $name, dateOfBirth: $dateOfBirth, gradeLevel: $gradeLevel, englishLevel: $englishLevel, avatarImageUrl: $avatarImageUrl, podcastListeningMode: $podcastListeningMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateChildProfileRequestImpl &&
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
                other.podcastListeningMode == podcastListeningMode));
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
  );

  /// Create a copy of CreateChildProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateChildProfileRequestImplCopyWith<_$CreateChildProfileRequestImpl>
  get copyWith =>
      __$$CreateChildProfileRequestImplCopyWithImpl<
        _$CreateChildProfileRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateChildProfileRequestImplToJson(this);
  }
}

abstract class _CreateChildProfileRequest implements CreateChildProfileRequest {
  const factory _CreateChildProfileRequest({
    @JsonKey(name: 'Name') required final String name,
    @JsonKey(name: 'DateOfBirth') required final DateTime dateOfBirth,
    @JsonKey(name: 'GradeLevel') required final int gradeLevel,
    @JsonKey(name: 'EnglishLevel') final int? englishLevel,
    @JsonKey(name: 'AvatarImageUrl') final String? avatarImageUrl,
    @JsonKey(name: 'PodcastListeningMode') final int podcastListeningMode,
  }) = _$CreateChildProfileRequestImpl;

  factory _CreateChildProfileRequest.fromJson(Map<String, dynamic> json) =
      _$CreateChildProfileRequestImpl.fromJson;

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

  /// Create a copy of CreateChildProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateChildProfileRequestImplCopyWith<_$CreateChildProfileRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
