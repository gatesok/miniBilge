// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChildProfileDto _$ChildProfileDtoFromJson(Map<String, dynamic> json) {
  return _ChildProfileDto.fromJson(json);
}

/// @nodoc
mixin _$ChildProfileDto {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'DateOfBirth')
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  @JsonKey(name: 'Age')
  int get age => throw _privateConstructorUsedError;
  @JsonKey(name: 'GradeLevel')
  String get gradeLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'EnglishLevel')
  String? get englishLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'AvatarImageUrl')
  String? get avatarImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalCoins')
  int get totalCoins => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalStars')
  int get totalStars => throw _privateConstructorUsedError; // 0 = Offline (cihaz TTS), 1 = Online (Google TTS)
  @JsonKey(name: 'PodcastListeningMode')
  int get podcastListeningMode => throw _privateConstructorUsedError;

  /// Serializes this ChildProfileDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChildProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChildProfileDtoCopyWith<ChildProfileDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildProfileDtoCopyWith<$Res> {
  factory $ChildProfileDtoCopyWith(
    ChildProfileDto value,
    $Res Function(ChildProfileDto) then,
  ) = _$ChildProfileDtoCopyWithImpl<$Res, ChildProfileDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'DateOfBirth') DateTime dateOfBirth,
    @JsonKey(name: 'Age') int age,
    @JsonKey(name: 'GradeLevel') String gradeLevel,
    @JsonKey(name: 'EnglishLevel') String? englishLevel,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'TotalCoins') int totalCoins,
    @JsonKey(name: 'TotalStars') int totalStars,
    @JsonKey(name: 'PodcastListeningMode') int podcastListeningMode,
  });
}

/// @nodoc
class _$ChildProfileDtoCopyWithImpl<$Res, $Val extends ChildProfileDto>
    implements $ChildProfileDtoCopyWith<$Res> {
  _$ChildProfileDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChildProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? dateOfBirth = null,
    Object? age = null,
    Object? gradeLevel = null,
    Object? englishLevel = freezed,
    Object? avatarImageUrl = freezed,
    Object? totalCoins = null,
    Object? totalStars = null,
    Object? podcastListeningMode = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            dateOfBirth: null == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            age: null == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                      as int,
            gradeLevel: null == gradeLevel
                ? _value.gradeLevel
                : gradeLevel // ignore: cast_nullable_to_non_nullable
                      as String,
            englishLevel: freezed == englishLevel
                ? _value.englishLevel
                : englishLevel // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarImageUrl: freezed == avatarImageUrl
                ? _value.avatarImageUrl
                : avatarImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalCoins: null == totalCoins
                ? _value.totalCoins
                : totalCoins // ignore: cast_nullable_to_non_nullable
                      as int,
            totalStars: null == totalStars
                ? _value.totalStars
                : totalStars // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$ChildProfileDtoImplCopyWith<$Res>
    implements $ChildProfileDtoCopyWith<$Res> {
  factory _$$ChildProfileDtoImplCopyWith(
    _$ChildProfileDtoImpl value,
    $Res Function(_$ChildProfileDtoImpl) then,
  ) = __$$ChildProfileDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'DateOfBirth') DateTime dateOfBirth,
    @JsonKey(name: 'Age') int age,
    @JsonKey(name: 'GradeLevel') String gradeLevel,
    @JsonKey(name: 'EnglishLevel') String? englishLevel,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'TotalCoins') int totalCoins,
    @JsonKey(name: 'TotalStars') int totalStars,
    @JsonKey(name: 'PodcastListeningMode') int podcastListeningMode,
  });
}

/// @nodoc
class __$$ChildProfileDtoImplCopyWithImpl<$Res>
    extends _$ChildProfileDtoCopyWithImpl<$Res, _$ChildProfileDtoImpl>
    implements _$$ChildProfileDtoImplCopyWith<$Res> {
  __$$ChildProfileDtoImplCopyWithImpl(
    _$ChildProfileDtoImpl _value,
    $Res Function(_$ChildProfileDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChildProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? dateOfBirth = null,
    Object? age = null,
    Object? gradeLevel = null,
    Object? englishLevel = freezed,
    Object? avatarImageUrl = freezed,
    Object? totalCoins = null,
    Object? totalStars = null,
    Object? podcastListeningMode = null,
  }) {
    return _then(
      _$ChildProfileDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        dateOfBirth: null == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        age: null == age
            ? _value.age
            : age // ignore: cast_nullable_to_non_nullable
                  as int,
        gradeLevel: null == gradeLevel
            ? _value.gradeLevel
            : gradeLevel // ignore: cast_nullable_to_non_nullable
                  as String,
        englishLevel: freezed == englishLevel
            ? _value.englishLevel
            : englishLevel // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarImageUrl: freezed == avatarImageUrl
            ? _value.avatarImageUrl
            : avatarImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalCoins: null == totalCoins
            ? _value.totalCoins
            : totalCoins // ignore: cast_nullable_to_non_nullable
                  as int,
        totalStars: null == totalStars
            ? _value.totalStars
            : totalStars // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$ChildProfileDtoImpl implements _ChildProfileDto {
  const _$ChildProfileDtoImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'Name') required this.name,
    @JsonKey(name: 'DateOfBirth') required this.dateOfBirth,
    @JsonKey(name: 'Age') required this.age,
    @JsonKey(name: 'GradeLevel') required this.gradeLevel,
    @JsonKey(name: 'EnglishLevel') this.englishLevel,
    @JsonKey(name: 'AvatarImageUrl') this.avatarImageUrl,
    @JsonKey(name: 'TotalCoins') this.totalCoins = 0,
    @JsonKey(name: 'TotalStars') this.totalStars = 0,
    @JsonKey(name: 'PodcastListeningMode') this.podcastListeningMode = 0,
  });

  factory _$ChildProfileDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChildProfileDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'Name')
  final String name;
  @override
  @JsonKey(name: 'DateOfBirth')
  final DateTime dateOfBirth;
  @override
  @JsonKey(name: 'Age')
  final int age;
  @override
  @JsonKey(name: 'GradeLevel')
  final String gradeLevel;
  @override
  @JsonKey(name: 'EnglishLevel')
  final String? englishLevel;
  @override
  @JsonKey(name: 'AvatarImageUrl')
  final String? avatarImageUrl;
  @override
  @JsonKey(name: 'TotalCoins')
  final int totalCoins;
  @override
  @JsonKey(name: 'TotalStars')
  final int totalStars;
  // 0 = Offline (cihaz TTS), 1 = Online (Google TTS)
  @override
  @JsonKey(name: 'PodcastListeningMode')
  final int podcastListeningMode;

  @override
  String toString() {
    return 'ChildProfileDto(id: $id, name: $name, dateOfBirth: $dateOfBirth, age: $age, gradeLevel: $gradeLevel, englishLevel: $englishLevel, avatarImageUrl: $avatarImageUrl, totalCoins: $totalCoins, totalStars: $totalStars, podcastListeningMode: $podcastListeningMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildProfileDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gradeLevel, gradeLevel) ||
                other.gradeLevel == gradeLevel) &&
            (identical(other.englishLevel, englishLevel) ||
                other.englishLevel == englishLevel) &&
            (identical(other.avatarImageUrl, avatarImageUrl) ||
                other.avatarImageUrl == avatarImageUrl) &&
            (identical(other.totalCoins, totalCoins) ||
                other.totalCoins == totalCoins) &&
            (identical(other.totalStars, totalStars) ||
                other.totalStars == totalStars) &&
            (identical(other.podcastListeningMode, podcastListeningMode) ||
                other.podcastListeningMode == podcastListeningMode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    dateOfBirth,
    age,
    gradeLevel,
    englishLevel,
    avatarImageUrl,
    totalCoins,
    totalStars,
    podcastListeningMode,
  );

  /// Create a copy of ChildProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildProfileDtoImplCopyWith<_$ChildProfileDtoImpl> get copyWith =>
      __$$ChildProfileDtoImplCopyWithImpl<_$ChildProfileDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChildProfileDtoImplToJson(this);
  }
}

abstract class _ChildProfileDto implements ChildProfileDto {
  const factory _ChildProfileDto({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'Name') required final String name,
    @JsonKey(name: 'DateOfBirth') required final DateTime dateOfBirth,
    @JsonKey(name: 'Age') required final int age,
    @JsonKey(name: 'GradeLevel') required final String gradeLevel,
    @JsonKey(name: 'EnglishLevel') final String? englishLevel,
    @JsonKey(name: 'AvatarImageUrl') final String? avatarImageUrl,
    @JsonKey(name: 'TotalCoins') final int totalCoins,
    @JsonKey(name: 'TotalStars') final int totalStars,
    @JsonKey(name: 'PodcastListeningMode') final int podcastListeningMode,
  }) = _$ChildProfileDtoImpl;

  factory _ChildProfileDto.fromJson(Map<String, dynamic> json) =
      _$ChildProfileDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'Name')
  String get name;
  @override
  @JsonKey(name: 'DateOfBirth')
  DateTime get dateOfBirth;
  @override
  @JsonKey(name: 'Age')
  int get age;
  @override
  @JsonKey(name: 'GradeLevel')
  String get gradeLevel;
  @override
  @JsonKey(name: 'EnglishLevel')
  String? get englishLevel;
  @override
  @JsonKey(name: 'AvatarImageUrl')
  String? get avatarImageUrl;
  @override
  @JsonKey(name: 'TotalCoins')
  int get totalCoins;
  @override
  @JsonKey(name: 'TotalStars')
  int get totalStars; // 0 = Offline (cihaz TTS), 1 = Online (Google TTS)
  @override
  @JsonKey(name: 'PodcastListeningMode')
  int get podcastListeningMode;

  /// Create a copy of ChildProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChildProfileDtoImplCopyWith<_$ChildProfileDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
