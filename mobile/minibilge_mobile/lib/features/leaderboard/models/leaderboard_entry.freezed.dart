// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) {
  return _LeaderboardEntry.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardEntry {
  @JsonKey(name: 'ChildProfileId')
  String get childProfileId => throw _privateConstructorUsedError;
  @JsonKey(name: 'ChildName')
  String get childName => throw _privateConstructorUsedError;
  @JsonKey(name: 'AvatarImageUrl')
  String? get avatarImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalCoins')
  int get totalCoins => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalScore')
  int get totalScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalStars')
  int get totalStars => throw _privateConstructorUsedError;
  @JsonKey(name: 'Rank')
  int get rank => throw _privateConstructorUsedError;
  @JsonKey(name: 'GradeLevel')
  String? get gradeLevel => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardEntryCopyWith<$Res> {
  factory $LeaderboardEntryCopyWith(
    LeaderboardEntry value,
    $Res Function(LeaderboardEntry) then,
  ) = _$LeaderboardEntryCopyWithImpl<$Res, LeaderboardEntry>;
  @useResult
  $Res call({
    @JsonKey(name: 'ChildProfileId') String childProfileId,
    @JsonKey(name: 'ChildName') String childName,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'TotalCoins') int totalCoins,
    @JsonKey(name: 'TotalScore') int totalScore,
    @JsonKey(name: 'TotalStars') int totalStars,
    @JsonKey(name: 'Rank') int rank,
    @JsonKey(name: 'GradeLevel') String? gradeLevel,
  });
}

/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res, $Val extends LeaderboardEntry>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childProfileId = null,
    Object? childName = null,
    Object? avatarImageUrl = freezed,
    Object? totalCoins = null,
    Object? totalScore = null,
    Object? totalStars = null,
    Object? rank = null,
    Object? gradeLevel = freezed,
  }) {
    return _then(
      _value.copyWith(
            childProfileId: null == childProfileId
                ? _value.childProfileId
                : childProfileId // ignore: cast_nullable_to_non_nullable
                      as String,
            childName: null == childName
                ? _value.childName
                : childName // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarImageUrl: freezed == avatarImageUrl
                ? _value.avatarImageUrl
                : avatarImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalCoins: null == totalCoins
                ? _value.totalCoins
                : totalCoins // ignore: cast_nullable_to_non_nullable
                      as int,
            totalScore: null == totalScore
                ? _value.totalScore
                : totalScore // ignore: cast_nullable_to_non_nullable
                      as int,
            totalStars: null == totalStars
                ? _value.totalStars
                : totalStars // ignore: cast_nullable_to_non_nullable
                      as int,
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            gradeLevel: freezed == gradeLevel
                ? _value.gradeLevel
                : gradeLevel // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaderboardEntryImplCopyWith<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  factory _$$LeaderboardEntryImplCopyWith(
    _$LeaderboardEntryImpl value,
    $Res Function(_$LeaderboardEntryImpl) then,
  ) = __$$LeaderboardEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ChildProfileId') String childProfileId,
    @JsonKey(name: 'ChildName') String childName,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'TotalCoins') int totalCoins,
    @JsonKey(name: 'TotalScore') int totalScore,
    @JsonKey(name: 'TotalStars') int totalStars,
    @JsonKey(name: 'Rank') int rank,
    @JsonKey(name: 'GradeLevel') String? gradeLevel,
  });
}

/// @nodoc
class __$$LeaderboardEntryImplCopyWithImpl<$Res>
    extends _$LeaderboardEntryCopyWithImpl<$Res, _$LeaderboardEntryImpl>
    implements _$$LeaderboardEntryImplCopyWith<$Res> {
  __$$LeaderboardEntryImplCopyWithImpl(
    _$LeaderboardEntryImpl _value,
    $Res Function(_$LeaderboardEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childProfileId = null,
    Object? childName = null,
    Object? avatarImageUrl = freezed,
    Object? totalCoins = null,
    Object? totalScore = null,
    Object? totalStars = null,
    Object? rank = null,
    Object? gradeLevel = freezed,
  }) {
    return _then(
      _$LeaderboardEntryImpl(
        childProfileId: null == childProfileId
            ? _value.childProfileId
            : childProfileId // ignore: cast_nullable_to_non_nullable
                  as String,
        childName: null == childName
            ? _value.childName
            : childName // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarImageUrl: freezed == avatarImageUrl
            ? _value.avatarImageUrl
            : avatarImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalCoins: null == totalCoins
            ? _value.totalCoins
            : totalCoins // ignore: cast_nullable_to_non_nullable
                  as int,
        totalScore: null == totalScore
            ? _value.totalScore
            : totalScore // ignore: cast_nullable_to_non_nullable
                  as int,
        totalStars: null == totalStars
            ? _value.totalStars
            : totalStars // ignore: cast_nullable_to_non_nullable
                  as int,
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        gradeLevel: freezed == gradeLevel
            ? _value.gradeLevel
            : gradeLevel // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardEntryImpl implements _LeaderboardEntry {
  const _$LeaderboardEntryImpl({
    @JsonKey(name: 'ChildProfileId') required this.childProfileId,
    @JsonKey(name: 'ChildName') required this.childName,
    @JsonKey(name: 'AvatarImageUrl') this.avatarImageUrl,
    @JsonKey(name: 'TotalCoins') this.totalCoins = 0,
    @JsonKey(name: 'TotalScore') this.totalScore = 0,
    @JsonKey(name: 'TotalStars') this.totalStars = 0,
    @JsonKey(name: 'Rank') this.rank = 0,
    @JsonKey(name: 'GradeLevel') this.gradeLevel,
  });

  factory _$LeaderboardEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardEntryImplFromJson(json);

  @override
  @JsonKey(name: 'ChildProfileId')
  final String childProfileId;
  @override
  @JsonKey(name: 'ChildName')
  final String childName;
  @override
  @JsonKey(name: 'AvatarImageUrl')
  final String? avatarImageUrl;
  @override
  @JsonKey(name: 'TotalCoins')
  final int totalCoins;
  @override
  @JsonKey(name: 'TotalScore')
  final int totalScore;
  @override
  @JsonKey(name: 'TotalStars')
  final int totalStars;
  @override
  @JsonKey(name: 'Rank')
  final int rank;
  @override
  @JsonKey(name: 'GradeLevel')
  final String? gradeLevel;

  @override
  String toString() {
    return 'LeaderboardEntry(childProfileId: $childProfileId, childName: $childName, avatarImageUrl: $avatarImageUrl, totalCoins: $totalCoins, totalScore: $totalScore, totalStars: $totalStars, rank: $rank, gradeLevel: $gradeLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardEntryImpl &&
            (identical(other.childProfileId, childProfileId) ||
                other.childProfileId == childProfileId) &&
            (identical(other.childName, childName) ||
                other.childName == childName) &&
            (identical(other.avatarImageUrl, avatarImageUrl) ||
                other.avatarImageUrl == avatarImageUrl) &&
            (identical(other.totalCoins, totalCoins) ||
                other.totalCoins == totalCoins) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.totalStars, totalStars) ||
                other.totalStars == totalStars) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.gradeLevel, gradeLevel) ||
                other.gradeLevel == gradeLevel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    childProfileId,
    childName,
    avatarImageUrl,
    totalCoins,
    totalScore,
    totalStars,
    rank,
    gradeLevel,
  );

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      __$$LeaderboardEntryImplCopyWithImpl<_$LeaderboardEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardEntryImplToJson(this);
  }
}

abstract class _LeaderboardEntry implements LeaderboardEntry {
  const factory _LeaderboardEntry({
    @JsonKey(name: 'ChildProfileId') required final String childProfileId,
    @JsonKey(name: 'ChildName') required final String childName,
    @JsonKey(name: 'AvatarImageUrl') final String? avatarImageUrl,
    @JsonKey(name: 'TotalCoins') final int totalCoins,
    @JsonKey(name: 'TotalScore') final int totalScore,
    @JsonKey(name: 'TotalStars') final int totalStars,
    @JsonKey(name: 'Rank') final int rank,
    @JsonKey(name: 'GradeLevel') final String? gradeLevel,
  }) = _$LeaderboardEntryImpl;

  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) =
      _$LeaderboardEntryImpl.fromJson;

  @override
  @JsonKey(name: 'ChildProfileId')
  String get childProfileId;
  @override
  @JsonKey(name: 'ChildName')
  String get childName;
  @override
  @JsonKey(name: 'AvatarImageUrl')
  String? get avatarImageUrl;
  @override
  @JsonKey(name: 'TotalCoins')
  int get totalCoins;
  @override
  @JsonKey(name: 'TotalScore')
  int get totalScore;
  @override
  @JsonKey(name: 'TotalStars')
  int get totalStars;
  @override
  @JsonKey(name: 'Rank')
  int get rank;
  @override
  @JsonKey(name: 'GradeLevel')
  String? get gradeLevel;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
