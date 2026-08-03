// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChallengeHistory _$ChallengeHistoryFromJson(Map<String, dynamic> json) {
  return _ChallengeHistory.fromJson(json);
}

/// @nodoc
mixin _$ChallengeHistory {
  @JsonKey(name: 'ChildId')
  String get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalCompleted')
  int get totalCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'Won')
  int get won => throw _privateConstructorUsedError;
  @JsonKey(name: 'Lost')
  int get lost => throw _privateConstructorUsedError;
  @JsonKey(name: 'Tie')
  int get tie => throw _privateConstructorUsedError;
  @JsonKey(name: 'Categories')
  List<ChallengeCategoryStat> get categories =>
      throw _privateConstructorUsedError;

  /// Serializes this ChallengeHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeHistoryCopyWith<ChallengeHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeHistoryCopyWith<$Res> {
  factory $ChallengeHistoryCopyWith(
    ChallengeHistory value,
    $Res Function(ChallengeHistory) then,
  ) = _$ChallengeHistoryCopyWithImpl<$Res, ChallengeHistory>;
  @useResult
  $Res call({
    @JsonKey(name: 'ChildId') String childId,
    @JsonKey(name: 'TotalCompleted') int totalCompleted,
    @JsonKey(name: 'Won') int won,
    @JsonKey(name: 'Lost') int lost,
    @JsonKey(name: 'Tie') int tie,
    @JsonKey(name: 'Categories') List<ChallengeCategoryStat> categories,
  });
}

/// @nodoc
class _$ChallengeHistoryCopyWithImpl<$Res, $Val extends ChallengeHistory>
    implements $ChallengeHistoryCopyWith<$Res> {
  _$ChallengeHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? totalCompleted = null,
    Object? won = null,
    Object? lost = null,
    Object? tie = null,
    Object? categories = null,
  }) {
    return _then(
      _value.copyWith(
            childId: null == childId
                ? _value.childId
                : childId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalCompleted: null == totalCompleted
                ? _value.totalCompleted
                : totalCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            won: null == won
                ? _value.won
                : won // ignore: cast_nullable_to_non_nullable
                      as int,
            lost: null == lost
                ? _value.lost
                : lost // ignore: cast_nullable_to_non_nullable
                      as int,
            tie: null == tie
                ? _value.tie
                : tie // ignore: cast_nullable_to_non_nullable
                      as int,
            categories: null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                      as List<ChallengeCategoryStat>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChallengeHistoryImplCopyWith<$Res>
    implements $ChallengeHistoryCopyWith<$Res> {
  factory _$$ChallengeHistoryImplCopyWith(
    _$ChallengeHistoryImpl value,
    $Res Function(_$ChallengeHistoryImpl) then,
  ) = __$$ChallengeHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ChildId') String childId,
    @JsonKey(name: 'TotalCompleted') int totalCompleted,
    @JsonKey(name: 'Won') int won,
    @JsonKey(name: 'Lost') int lost,
    @JsonKey(name: 'Tie') int tie,
    @JsonKey(name: 'Categories') List<ChallengeCategoryStat> categories,
  });
}

/// @nodoc
class __$$ChallengeHistoryImplCopyWithImpl<$Res>
    extends _$ChallengeHistoryCopyWithImpl<$Res, _$ChallengeHistoryImpl>
    implements _$$ChallengeHistoryImplCopyWith<$Res> {
  __$$ChallengeHistoryImplCopyWithImpl(
    _$ChallengeHistoryImpl _value,
    $Res Function(_$ChallengeHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChallengeHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? totalCompleted = null,
    Object? won = null,
    Object? lost = null,
    Object? tie = null,
    Object? categories = null,
  }) {
    return _then(
      _$ChallengeHistoryImpl(
        childId: null == childId
            ? _value.childId
            : childId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalCompleted: null == totalCompleted
            ? _value.totalCompleted
            : totalCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        won: null == won
            ? _value.won
            : won // ignore: cast_nullable_to_non_nullable
                  as int,
        lost: null == lost
            ? _value.lost
            : lost // ignore: cast_nullable_to_non_nullable
                  as int,
        tie: null == tie
            ? _value.tie
            : tie // ignore: cast_nullable_to_non_nullable
                  as int,
        categories: null == categories
            ? _value._categories
            : categories // ignore: cast_nullable_to_non_nullable
                  as List<ChallengeCategoryStat>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeHistoryImpl implements _ChallengeHistory {
  const _$ChallengeHistoryImpl({
    @JsonKey(name: 'ChildId') required this.childId,
    @JsonKey(name: 'TotalCompleted') required this.totalCompleted,
    @JsonKey(name: 'Won') required this.won,
    @JsonKey(name: 'Lost') required this.lost,
    @JsonKey(name: 'Tie') required this.tie,
    @JsonKey(name: 'Categories')
    final List<ChallengeCategoryStat> categories =
        const <ChallengeCategoryStat>[],
  }) : _categories = categories;

  factory _$ChallengeHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeHistoryImplFromJson(json);

  @override
  @JsonKey(name: 'ChildId')
  final String childId;
  @override
  @JsonKey(name: 'TotalCompleted')
  final int totalCompleted;
  @override
  @JsonKey(name: 'Won')
  final int won;
  @override
  @JsonKey(name: 'Lost')
  final int lost;
  @override
  @JsonKey(name: 'Tie')
  final int tie;
  final List<ChallengeCategoryStat> _categories;
  @override
  @JsonKey(name: 'Categories')
  List<ChallengeCategoryStat> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  String toString() {
    return 'ChallengeHistory(childId: $childId, totalCompleted: $totalCompleted, won: $won, lost: $lost, tie: $tie, categories: $categories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeHistoryImpl &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.totalCompleted, totalCompleted) ||
                other.totalCompleted == totalCompleted) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.lost, lost) || other.lost == lost) &&
            (identical(other.tie, tie) || other.tie == tie) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    childId,
    totalCompleted,
    won,
    lost,
    tie,
    const DeepCollectionEquality().hash(_categories),
  );

  /// Create a copy of ChallengeHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeHistoryImplCopyWith<_$ChallengeHistoryImpl> get copyWith =>
      __$$ChallengeHistoryImplCopyWithImpl<_$ChallengeHistoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeHistoryImplToJson(this);
  }
}

abstract class _ChallengeHistory implements ChallengeHistory {
  const factory _ChallengeHistory({
    @JsonKey(name: 'ChildId') required final String childId,
    @JsonKey(name: 'TotalCompleted') required final int totalCompleted,
    @JsonKey(name: 'Won') required final int won,
    @JsonKey(name: 'Lost') required final int lost,
    @JsonKey(name: 'Tie') required final int tie,
    @JsonKey(name: 'Categories') final List<ChallengeCategoryStat> categories,
  }) = _$ChallengeHistoryImpl;

  factory _ChallengeHistory.fromJson(Map<String, dynamic> json) =
      _$ChallengeHistoryImpl.fromJson;

  @override
  @JsonKey(name: 'ChildId')
  String get childId;
  @override
  @JsonKey(name: 'TotalCompleted')
  int get totalCompleted;
  @override
  @JsonKey(name: 'Won')
  int get won;
  @override
  @JsonKey(name: 'Lost')
  int get lost;
  @override
  @JsonKey(name: 'Tie')
  int get tie;
  @override
  @JsonKey(name: 'Categories')
  List<ChallengeCategoryStat> get categories;

  /// Create a copy of ChallengeHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeHistoryImplCopyWith<_$ChallengeHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChallengeCategoryStat _$ChallengeCategoryStatFromJson(
  Map<String, dynamic> json,
) {
  return _ChallengeCategoryStat.fromJson(json);
}

/// @nodoc
mixin _$ChallengeCategoryStat {
  @JsonKey(name: 'Category')
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'Played')
  int get played => throw _privateConstructorUsedError;
  @JsonKey(name: 'Won')
  int get won => throw _privateConstructorUsedError;
  @JsonKey(name: 'Lost')
  int get lost => throw _privateConstructorUsedError;
  @JsonKey(name: 'Tie')
  int get tie => throw _privateConstructorUsedError;
  @JsonKey(name: 'WinRate')
  double get winRate => throw _privateConstructorUsedError;

  /// Serializes this ChallengeCategoryStat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeCategoryStat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeCategoryStatCopyWith<ChallengeCategoryStat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeCategoryStatCopyWith<$Res> {
  factory $ChallengeCategoryStatCopyWith(
    ChallengeCategoryStat value,
    $Res Function(ChallengeCategoryStat) then,
  ) = _$ChallengeCategoryStatCopyWithImpl<$Res, ChallengeCategoryStat>;
  @useResult
  $Res call({
    @JsonKey(name: 'Category') String category,
    @JsonKey(name: 'Played') int played,
    @JsonKey(name: 'Won') int won,
    @JsonKey(name: 'Lost') int lost,
    @JsonKey(name: 'Tie') int tie,
    @JsonKey(name: 'WinRate') double winRate,
  });
}

/// @nodoc
class _$ChallengeCategoryStatCopyWithImpl<
  $Res,
  $Val extends ChallengeCategoryStat
>
    implements $ChallengeCategoryStatCopyWith<$Res> {
  _$ChallengeCategoryStatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeCategoryStat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? played = null,
    Object? won = null,
    Object? lost = null,
    Object? tie = null,
    Object? winRate = null,
  }) {
    return _then(
      _value.copyWith(
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            played: null == played
                ? _value.played
                : played // ignore: cast_nullable_to_non_nullable
                      as int,
            won: null == won
                ? _value.won
                : won // ignore: cast_nullable_to_non_nullable
                      as int,
            lost: null == lost
                ? _value.lost
                : lost // ignore: cast_nullable_to_non_nullable
                      as int,
            tie: null == tie
                ? _value.tie
                : tie // ignore: cast_nullable_to_non_nullable
                      as int,
            winRate: null == winRate
                ? _value.winRate
                : winRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChallengeCategoryStatImplCopyWith<$Res>
    implements $ChallengeCategoryStatCopyWith<$Res> {
  factory _$$ChallengeCategoryStatImplCopyWith(
    _$ChallengeCategoryStatImpl value,
    $Res Function(_$ChallengeCategoryStatImpl) then,
  ) = __$$ChallengeCategoryStatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Category') String category,
    @JsonKey(name: 'Played') int played,
    @JsonKey(name: 'Won') int won,
    @JsonKey(name: 'Lost') int lost,
    @JsonKey(name: 'Tie') int tie,
    @JsonKey(name: 'WinRate') double winRate,
  });
}

/// @nodoc
class __$$ChallengeCategoryStatImplCopyWithImpl<$Res>
    extends
        _$ChallengeCategoryStatCopyWithImpl<$Res, _$ChallengeCategoryStatImpl>
    implements _$$ChallengeCategoryStatImplCopyWith<$Res> {
  __$$ChallengeCategoryStatImplCopyWithImpl(
    _$ChallengeCategoryStatImpl _value,
    $Res Function(_$ChallengeCategoryStatImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChallengeCategoryStat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? played = null,
    Object? won = null,
    Object? lost = null,
    Object? tie = null,
    Object? winRate = null,
  }) {
    return _then(
      _$ChallengeCategoryStatImpl(
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        played: null == played
            ? _value.played
            : played // ignore: cast_nullable_to_non_nullable
                  as int,
        won: null == won
            ? _value.won
            : won // ignore: cast_nullable_to_non_nullable
                  as int,
        lost: null == lost
            ? _value.lost
            : lost // ignore: cast_nullable_to_non_nullable
                  as int,
        tie: null == tie
            ? _value.tie
            : tie // ignore: cast_nullable_to_non_nullable
                  as int,
        winRate: null == winRate
            ? _value.winRate
            : winRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeCategoryStatImpl implements _ChallengeCategoryStat {
  const _$ChallengeCategoryStatImpl({
    @JsonKey(name: 'Category') required this.category,
    @JsonKey(name: 'Played') required this.played,
    @JsonKey(name: 'Won') required this.won,
    @JsonKey(name: 'Lost') required this.lost,
    @JsonKey(name: 'Tie') required this.tie,
    @JsonKey(name: 'WinRate') required this.winRate,
  });

  factory _$ChallengeCategoryStatImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeCategoryStatImplFromJson(json);

  @override
  @JsonKey(name: 'Category')
  final String category;
  @override
  @JsonKey(name: 'Played')
  final int played;
  @override
  @JsonKey(name: 'Won')
  final int won;
  @override
  @JsonKey(name: 'Lost')
  final int lost;
  @override
  @JsonKey(name: 'Tie')
  final int tie;
  @override
  @JsonKey(name: 'WinRate')
  final double winRate;

  @override
  String toString() {
    return 'ChallengeCategoryStat(category: $category, played: $played, won: $won, lost: $lost, tie: $tie, winRate: $winRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeCategoryStatImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.played, played) || other.played == played) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.lost, lost) || other.lost == lost) &&
            (identical(other.tie, tie) || other.tie == tie) &&
            (identical(other.winRate, winRate) || other.winRate == winRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, category, played, won, lost, tie, winRate);

  /// Create a copy of ChallengeCategoryStat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeCategoryStatImplCopyWith<_$ChallengeCategoryStatImpl>
  get copyWith =>
      __$$ChallengeCategoryStatImplCopyWithImpl<_$ChallengeCategoryStatImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeCategoryStatImplToJson(this);
  }
}

abstract class _ChallengeCategoryStat implements ChallengeCategoryStat {
  const factory _ChallengeCategoryStat({
    @JsonKey(name: 'Category') required final String category,
    @JsonKey(name: 'Played') required final int played,
    @JsonKey(name: 'Won') required final int won,
    @JsonKey(name: 'Lost') required final int lost,
    @JsonKey(name: 'Tie') required final int tie,
    @JsonKey(name: 'WinRate') required final double winRate,
  }) = _$ChallengeCategoryStatImpl;

  factory _ChallengeCategoryStat.fromJson(Map<String, dynamic> json) =
      _$ChallengeCategoryStatImpl.fromJson;

  @override
  @JsonKey(name: 'Category')
  String get category;
  @override
  @JsonKey(name: 'Played')
  int get played;
  @override
  @JsonKey(name: 'Won')
  int get won;
  @override
  @JsonKey(name: 'Lost')
  int get lost;
  @override
  @JsonKey(name: 'Tie')
  int get tie;
  @override
  @JsonKey(name: 'WinRate')
  double get winRate;

  /// Create a copy of ChallengeCategoryStat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeCategoryStatImplCopyWith<_$ChallengeCategoryStatImpl>
  get copyWith => throw _privateConstructorUsedError;
}
