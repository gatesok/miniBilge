// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tournament_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TournamentWeek _$TournamentWeekFromJson(Map<String, dynamic> json) {
  return _TournamentWeek.fromJson(json);
}

/// @nodoc
mixin _$TournamentWeek {
  @JsonKey(name: 'CategoryKey')
  String get categoryKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'CategoryLabel')
  String get categoryLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'CategoryEmoji')
  String get categoryEmoji => throw _privateConstructorUsedError;
  @JsonKey(name: 'WeekStart')
  String get weekStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'Entries')
  List<TournamentLeaderboardEntry> get entries =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'Me')
  TournamentLeaderboardEntry? get me => throw _privateConstructorUsedError;

  /// Serializes this TournamentWeek to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TournamentWeek
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TournamentWeekCopyWith<TournamentWeek> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TournamentWeekCopyWith<$Res> {
  factory $TournamentWeekCopyWith(
    TournamentWeek value,
    $Res Function(TournamentWeek) then,
  ) = _$TournamentWeekCopyWithImpl<$Res, TournamentWeek>;
  @useResult
  $Res call({
    @JsonKey(name: 'CategoryKey') String categoryKey,
    @JsonKey(name: 'CategoryLabel') String categoryLabel,
    @JsonKey(name: 'CategoryEmoji') String categoryEmoji,
    @JsonKey(name: 'WeekStart') String weekStart,
    @JsonKey(name: 'Entries') List<TournamentLeaderboardEntry> entries,
    @JsonKey(name: 'Me') TournamentLeaderboardEntry? me,
  });

  $TournamentLeaderboardEntryCopyWith<$Res>? get me;
}

/// @nodoc
class _$TournamentWeekCopyWithImpl<$Res, $Val extends TournamentWeek>
    implements $TournamentWeekCopyWith<$Res> {
  _$TournamentWeekCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TournamentWeek
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryKey = null,
    Object? categoryLabel = null,
    Object? categoryEmoji = null,
    Object? weekStart = null,
    Object? entries = null,
    Object? me = freezed,
  }) {
    return _then(
      _value.copyWith(
            categoryKey: null == categoryKey
                ? _value.categoryKey
                : categoryKey // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryLabel: null == categoryLabel
                ? _value.categoryLabel
                : categoryLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryEmoji: null == categoryEmoji
                ? _value.categoryEmoji
                : categoryEmoji // ignore: cast_nullable_to_non_nullable
                      as String,
            weekStart: null == weekStart
                ? _value.weekStart
                : weekStart // ignore: cast_nullable_to_non_nullable
                      as String,
            entries: null == entries
                ? _value.entries
                : entries // ignore: cast_nullable_to_non_nullable
                      as List<TournamentLeaderboardEntry>,
            me: freezed == me
                ? _value.me
                : me // ignore: cast_nullable_to_non_nullable
                      as TournamentLeaderboardEntry?,
          )
          as $Val,
    );
  }

  /// Create a copy of TournamentWeek
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TournamentLeaderboardEntryCopyWith<$Res>? get me {
    if (_value.me == null) {
      return null;
    }

    return $TournamentLeaderboardEntryCopyWith<$Res>(_value.me!, (value) {
      return _then(_value.copyWith(me: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TournamentWeekImplCopyWith<$Res>
    implements $TournamentWeekCopyWith<$Res> {
  factory _$$TournamentWeekImplCopyWith(
    _$TournamentWeekImpl value,
    $Res Function(_$TournamentWeekImpl) then,
  ) = __$$TournamentWeekImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'CategoryKey') String categoryKey,
    @JsonKey(name: 'CategoryLabel') String categoryLabel,
    @JsonKey(name: 'CategoryEmoji') String categoryEmoji,
    @JsonKey(name: 'WeekStart') String weekStart,
    @JsonKey(name: 'Entries') List<TournamentLeaderboardEntry> entries,
    @JsonKey(name: 'Me') TournamentLeaderboardEntry? me,
  });

  @override
  $TournamentLeaderboardEntryCopyWith<$Res>? get me;
}

/// @nodoc
class __$$TournamentWeekImplCopyWithImpl<$Res>
    extends _$TournamentWeekCopyWithImpl<$Res, _$TournamentWeekImpl>
    implements _$$TournamentWeekImplCopyWith<$Res> {
  __$$TournamentWeekImplCopyWithImpl(
    _$TournamentWeekImpl _value,
    $Res Function(_$TournamentWeekImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TournamentWeek
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryKey = null,
    Object? categoryLabel = null,
    Object? categoryEmoji = null,
    Object? weekStart = null,
    Object? entries = null,
    Object? me = freezed,
  }) {
    return _then(
      _$TournamentWeekImpl(
        categoryKey: null == categoryKey
            ? _value.categoryKey
            : categoryKey // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryLabel: null == categoryLabel
            ? _value.categoryLabel
            : categoryLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryEmoji: null == categoryEmoji
            ? _value.categoryEmoji
            : categoryEmoji // ignore: cast_nullable_to_non_nullable
                  as String,
        weekStart: null == weekStart
            ? _value.weekStart
            : weekStart // ignore: cast_nullable_to_non_nullable
                  as String,
        entries: null == entries
            ? _value._entries
            : entries // ignore: cast_nullable_to_non_nullable
                  as List<TournamentLeaderboardEntry>,
        me: freezed == me
            ? _value.me
            : me // ignore: cast_nullable_to_non_nullable
                  as TournamentLeaderboardEntry?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TournamentWeekImpl implements _TournamentWeek {
  const _$TournamentWeekImpl({
    @JsonKey(name: 'CategoryKey') required this.categoryKey,
    @JsonKey(name: 'CategoryLabel') required this.categoryLabel,
    @JsonKey(name: 'CategoryEmoji') required this.categoryEmoji,
    @JsonKey(name: 'WeekStart') required this.weekStart,
    @JsonKey(name: 'Entries')
    final List<TournamentLeaderboardEntry> entries =
        const <TournamentLeaderboardEntry>[],
    @JsonKey(name: 'Me') this.me,
  }) : _entries = entries;

  factory _$TournamentWeekImpl.fromJson(Map<String, dynamic> json) =>
      _$$TournamentWeekImplFromJson(json);

  @override
  @JsonKey(name: 'CategoryKey')
  final String categoryKey;
  @override
  @JsonKey(name: 'CategoryLabel')
  final String categoryLabel;
  @override
  @JsonKey(name: 'CategoryEmoji')
  final String categoryEmoji;
  @override
  @JsonKey(name: 'WeekStart')
  final String weekStart;
  final List<TournamentLeaderboardEntry> _entries;
  @override
  @JsonKey(name: 'Entries')
  List<TournamentLeaderboardEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  @JsonKey(name: 'Me')
  final TournamentLeaderboardEntry? me;

  @override
  String toString() {
    return 'TournamentWeek(categoryKey: $categoryKey, categoryLabel: $categoryLabel, categoryEmoji: $categoryEmoji, weekStart: $weekStart, entries: $entries, me: $me)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TournamentWeekImpl &&
            (identical(other.categoryKey, categoryKey) ||
                other.categoryKey == categoryKey) &&
            (identical(other.categoryLabel, categoryLabel) ||
                other.categoryLabel == categoryLabel) &&
            (identical(other.categoryEmoji, categoryEmoji) ||
                other.categoryEmoji == categoryEmoji) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.me, me) || other.me == me));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    categoryKey,
    categoryLabel,
    categoryEmoji,
    weekStart,
    const DeepCollectionEquality().hash(_entries),
    me,
  );

  /// Create a copy of TournamentWeek
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TournamentWeekImplCopyWith<_$TournamentWeekImpl> get copyWith =>
      __$$TournamentWeekImplCopyWithImpl<_$TournamentWeekImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TournamentWeekImplToJson(this);
  }
}

abstract class _TournamentWeek implements TournamentWeek {
  const factory _TournamentWeek({
    @JsonKey(name: 'CategoryKey') required final String categoryKey,
    @JsonKey(name: 'CategoryLabel') required final String categoryLabel,
    @JsonKey(name: 'CategoryEmoji') required final String categoryEmoji,
    @JsonKey(name: 'WeekStart') required final String weekStart,
    @JsonKey(name: 'Entries') final List<TournamentLeaderboardEntry> entries,
    @JsonKey(name: 'Me') final TournamentLeaderboardEntry? me,
  }) = _$TournamentWeekImpl;

  factory _TournamentWeek.fromJson(Map<String, dynamic> json) =
      _$TournamentWeekImpl.fromJson;

  @override
  @JsonKey(name: 'CategoryKey')
  String get categoryKey;
  @override
  @JsonKey(name: 'CategoryLabel')
  String get categoryLabel;
  @override
  @JsonKey(name: 'CategoryEmoji')
  String get categoryEmoji;
  @override
  @JsonKey(name: 'WeekStart')
  String get weekStart;
  @override
  @JsonKey(name: 'Entries')
  List<TournamentLeaderboardEntry> get entries;
  @override
  @JsonKey(name: 'Me')
  TournamentLeaderboardEntry? get me;

  /// Create a copy of TournamentWeek
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TournamentWeekImplCopyWith<_$TournamentWeekImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TournamentLeaderboardEntry _$TournamentLeaderboardEntryFromJson(
  Map<String, dynamic> json,
) {
  return _TournamentLeaderboardEntry.fromJson(json);
}

/// @nodoc
mixin _$TournamentLeaderboardEntry {
  @JsonKey(name: 'ChildProfileId')
  String get childProfileId => throw _privateConstructorUsedError;
  @JsonKey(name: 'ChildName')
  String get childName => throw _privateConstructorUsedError;
  @JsonKey(name: 'AvatarImageUrl')
  String? get avatarImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'Points')
  int get points => throw _privateConstructorUsedError;
  @JsonKey(name: 'Wins')
  int get wins => throw _privateConstructorUsedError;
  @JsonKey(name: 'GamesPlayed')
  int get gamesPlayed => throw _privateConstructorUsedError;
  @JsonKey(name: 'Rank')
  int get rank => throw _privateConstructorUsedError;

  /// Serializes this TournamentLeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TournamentLeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TournamentLeaderboardEntryCopyWith<TournamentLeaderboardEntry>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TournamentLeaderboardEntryCopyWith<$Res> {
  factory $TournamentLeaderboardEntryCopyWith(
    TournamentLeaderboardEntry value,
    $Res Function(TournamentLeaderboardEntry) then,
  ) =
      _$TournamentLeaderboardEntryCopyWithImpl<
        $Res,
        TournamentLeaderboardEntry
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'ChildProfileId') String childProfileId,
    @JsonKey(name: 'ChildName') String childName,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'Points') int points,
    @JsonKey(name: 'Wins') int wins,
    @JsonKey(name: 'GamesPlayed') int gamesPlayed,
    @JsonKey(name: 'Rank') int rank,
  });
}

/// @nodoc
class _$TournamentLeaderboardEntryCopyWithImpl<
  $Res,
  $Val extends TournamentLeaderboardEntry
>
    implements $TournamentLeaderboardEntryCopyWith<$Res> {
  _$TournamentLeaderboardEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TournamentLeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childProfileId = null,
    Object? childName = null,
    Object? avatarImageUrl = freezed,
    Object? points = null,
    Object? wins = null,
    Object? gamesPlayed = null,
    Object? rank = null,
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
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            wins: null == wins
                ? _value.wins
                : wins // ignore: cast_nullable_to_non_nullable
                      as int,
            gamesPlayed: null == gamesPlayed
                ? _value.gamesPlayed
                : gamesPlayed // ignore: cast_nullable_to_non_nullable
                      as int,
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TournamentLeaderboardEntryImplCopyWith<$Res>
    implements $TournamentLeaderboardEntryCopyWith<$Res> {
  factory _$$TournamentLeaderboardEntryImplCopyWith(
    _$TournamentLeaderboardEntryImpl value,
    $Res Function(_$TournamentLeaderboardEntryImpl) then,
  ) = __$$TournamentLeaderboardEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ChildProfileId') String childProfileId,
    @JsonKey(name: 'ChildName') String childName,
    @JsonKey(name: 'AvatarImageUrl') String? avatarImageUrl,
    @JsonKey(name: 'Points') int points,
    @JsonKey(name: 'Wins') int wins,
    @JsonKey(name: 'GamesPlayed') int gamesPlayed,
    @JsonKey(name: 'Rank') int rank,
  });
}

/// @nodoc
class __$$TournamentLeaderboardEntryImplCopyWithImpl<$Res>
    extends
        _$TournamentLeaderboardEntryCopyWithImpl<
          $Res,
          _$TournamentLeaderboardEntryImpl
        >
    implements _$$TournamentLeaderboardEntryImplCopyWith<$Res> {
  __$$TournamentLeaderboardEntryImplCopyWithImpl(
    _$TournamentLeaderboardEntryImpl _value,
    $Res Function(_$TournamentLeaderboardEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TournamentLeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childProfileId = null,
    Object? childName = null,
    Object? avatarImageUrl = freezed,
    Object? points = null,
    Object? wins = null,
    Object? gamesPlayed = null,
    Object? rank = null,
  }) {
    return _then(
      _$TournamentLeaderboardEntryImpl(
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
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        wins: null == wins
            ? _value.wins
            : wins // ignore: cast_nullable_to_non_nullable
                  as int,
        gamesPlayed: null == gamesPlayed
            ? _value.gamesPlayed
            : gamesPlayed // ignore: cast_nullable_to_non_nullable
                  as int,
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TournamentLeaderboardEntryImpl implements _TournamentLeaderboardEntry {
  const _$TournamentLeaderboardEntryImpl({
    @JsonKey(name: 'ChildProfileId') required this.childProfileId,
    @JsonKey(name: 'ChildName') required this.childName,
    @JsonKey(name: 'AvatarImageUrl') this.avatarImageUrl,
    @JsonKey(name: 'Points') required this.points,
    @JsonKey(name: 'Wins') required this.wins,
    @JsonKey(name: 'GamesPlayed') required this.gamesPlayed,
    @JsonKey(name: 'Rank') required this.rank,
  });

  factory _$TournamentLeaderboardEntryImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$TournamentLeaderboardEntryImplFromJson(json);

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
  @JsonKey(name: 'Points')
  final int points;
  @override
  @JsonKey(name: 'Wins')
  final int wins;
  @override
  @JsonKey(name: 'GamesPlayed')
  final int gamesPlayed;
  @override
  @JsonKey(name: 'Rank')
  final int rank;

  @override
  String toString() {
    return 'TournamentLeaderboardEntry(childProfileId: $childProfileId, childName: $childName, avatarImageUrl: $avatarImageUrl, points: $points, wins: $wins, gamesPlayed: $gamesPlayed, rank: $rank)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TournamentLeaderboardEntryImpl &&
            (identical(other.childProfileId, childProfileId) ||
                other.childProfileId == childProfileId) &&
            (identical(other.childName, childName) ||
                other.childName == childName) &&
            (identical(other.avatarImageUrl, avatarImageUrl) ||
                other.avatarImageUrl == avatarImageUrl) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.gamesPlayed, gamesPlayed) ||
                other.gamesPlayed == gamesPlayed) &&
            (identical(other.rank, rank) || other.rank == rank));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    childProfileId,
    childName,
    avatarImageUrl,
    points,
    wins,
    gamesPlayed,
    rank,
  );

  /// Create a copy of TournamentLeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TournamentLeaderboardEntryImplCopyWith<_$TournamentLeaderboardEntryImpl>
  get copyWith =>
      __$$TournamentLeaderboardEntryImplCopyWithImpl<
        _$TournamentLeaderboardEntryImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TournamentLeaderboardEntryImplToJson(this);
  }
}

abstract class _TournamentLeaderboardEntry
    implements TournamentLeaderboardEntry {
  const factory _TournamentLeaderboardEntry({
    @JsonKey(name: 'ChildProfileId') required final String childProfileId,
    @JsonKey(name: 'ChildName') required final String childName,
    @JsonKey(name: 'AvatarImageUrl') final String? avatarImageUrl,
    @JsonKey(name: 'Points') required final int points,
    @JsonKey(name: 'Wins') required final int wins,
    @JsonKey(name: 'GamesPlayed') required final int gamesPlayed,
    @JsonKey(name: 'Rank') required final int rank,
  }) = _$TournamentLeaderboardEntryImpl;

  factory _TournamentLeaderboardEntry.fromJson(Map<String, dynamic> json) =
      _$TournamentLeaderboardEntryImpl.fromJson;

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
  @JsonKey(name: 'Points')
  int get points;
  @override
  @JsonKey(name: 'Wins')
  int get wins;
  @override
  @JsonKey(name: 'GamesPlayed')
  int get gamesPlayed;
  @override
  @JsonKey(name: 'Rank')
  int get rank;

  /// Create a copy of TournamentLeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TournamentLeaderboardEntryImplCopyWith<_$TournamentLeaderboardEntryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TournamentCategory _$TournamentCategoryFromJson(Map<String, dynamic> json) {
  return _TournamentCategory.fromJson(json);
}

/// @nodoc
mixin _$TournamentCategory {
  @JsonKey(name: 'Key')
  String get key => throw _privateConstructorUsedError;
  @JsonKey(name: 'Label')
  String get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'Emoji')
  String get emoji => throw _privateConstructorUsedError;

  /// Serializes this TournamentCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TournamentCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TournamentCategoryCopyWith<TournamentCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TournamentCategoryCopyWith<$Res> {
  factory $TournamentCategoryCopyWith(
    TournamentCategory value,
    $Res Function(TournamentCategory) then,
  ) = _$TournamentCategoryCopyWithImpl<$Res, TournamentCategory>;
  @useResult
  $Res call({
    @JsonKey(name: 'Key') String key,
    @JsonKey(name: 'Label') String label,
    @JsonKey(name: 'Emoji') String emoji,
  });
}

/// @nodoc
class _$TournamentCategoryCopyWithImpl<$Res, $Val extends TournamentCategory>
    implements $TournamentCategoryCopyWith<$Res> {
  _$TournamentCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TournamentCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? key = null, Object? label = null, Object? emoji = null}) {
    return _then(
      _value.copyWith(
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TournamentCategoryImplCopyWith<$Res>
    implements $TournamentCategoryCopyWith<$Res> {
  factory _$$TournamentCategoryImplCopyWith(
    _$TournamentCategoryImpl value,
    $Res Function(_$TournamentCategoryImpl) then,
  ) = __$$TournamentCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Key') String key,
    @JsonKey(name: 'Label') String label,
    @JsonKey(name: 'Emoji') String emoji,
  });
}

/// @nodoc
class __$$TournamentCategoryImplCopyWithImpl<$Res>
    extends _$TournamentCategoryCopyWithImpl<$Res, _$TournamentCategoryImpl>
    implements _$$TournamentCategoryImplCopyWith<$Res> {
  __$$TournamentCategoryImplCopyWithImpl(
    _$TournamentCategoryImpl _value,
    $Res Function(_$TournamentCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TournamentCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? key = null, Object? label = null, Object? emoji = null}) {
    return _then(
      _$TournamentCategoryImpl(
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TournamentCategoryImpl implements _TournamentCategory {
  const _$TournamentCategoryImpl({
    @JsonKey(name: 'Key') required this.key,
    @JsonKey(name: 'Label') required this.label,
    @JsonKey(name: 'Emoji') required this.emoji,
  });

  factory _$TournamentCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TournamentCategoryImplFromJson(json);

  @override
  @JsonKey(name: 'Key')
  final String key;
  @override
  @JsonKey(name: 'Label')
  final String label;
  @override
  @JsonKey(name: 'Emoji')
  final String emoji;

  @override
  String toString() {
    return 'TournamentCategory(key: $key, label: $label, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TournamentCategoryImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, label, emoji);

  /// Create a copy of TournamentCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TournamentCategoryImplCopyWith<_$TournamentCategoryImpl> get copyWith =>
      __$$TournamentCategoryImplCopyWithImpl<_$TournamentCategoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TournamentCategoryImplToJson(this);
  }
}

abstract class _TournamentCategory implements TournamentCategory {
  const factory _TournamentCategory({
    @JsonKey(name: 'Key') required final String key,
    @JsonKey(name: 'Label') required final String label,
    @JsonKey(name: 'Emoji') required final String emoji,
  }) = _$TournamentCategoryImpl;

  factory _TournamentCategory.fromJson(Map<String, dynamic> json) =
      _$TournamentCategoryImpl.fromJson;

  @override
  @JsonKey(name: 'Key')
  String get key;
  @override
  @JsonKey(name: 'Label')
  String get label;
  @override
  @JsonKey(name: 'Emoji')
  String get emoji;

  /// Create a copy of TournamentCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TournamentCategoryImplCopyWith<_$TournamentCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
