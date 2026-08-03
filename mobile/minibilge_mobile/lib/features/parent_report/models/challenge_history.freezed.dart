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
  @JsonKey(name: 'Items')
  List<ChallengeHistoryItem> get items => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'Items') List<ChallengeHistoryItem> items,
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
    Object? items = null,
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
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ChallengeHistoryItem>,
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
    @JsonKey(name: 'Items') List<ChallengeHistoryItem> items,
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
    Object? items = null,
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
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ChallengeHistoryItem>,
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
    @JsonKey(name: 'Items')
    final List<ChallengeHistoryItem> items = const <ChallengeHistoryItem>[],
  }) : _items = items;

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
  final List<ChallengeHistoryItem> _items;
  @override
  @JsonKey(name: 'Items')
  List<ChallengeHistoryItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'ChallengeHistory(childId: $childId, totalCompleted: $totalCompleted, won: $won, lost: $lost, tie: $tie, items: $items)';
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
            const DeepCollectionEquality().equals(other._items, _items));
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
    const DeepCollectionEquality().hash(_items),
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
    @JsonKey(name: 'Items') final List<ChallengeHistoryItem> items,
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
  @JsonKey(name: 'Items')
  List<ChallengeHistoryItem> get items;

  /// Create a copy of ChallengeHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeHistoryImplCopyWith<_$ChallengeHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChallengeHistoryItem _$ChallengeHistoryItemFromJson(Map<String, dynamic> json) {
  return _ChallengeHistoryItem.fromJson(json);
}

/// @nodoc
mixin _$ChallengeHistoryItem {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'OpponentName')
  String get opponentName => throw _privateConstructorUsedError;
  @JsonKey(name: 'Category')
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'Result')
  String get result => throw _privateConstructorUsedError;
  @JsonKey(name: 'MyScore')
  int get myScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'OpponentScore')
  int get opponentScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalQuestions')
  int get totalQuestions => throw _privateConstructorUsedError;
  @JsonKey(name: 'PlayedAt')
  DateTime get playedAt => throw _privateConstructorUsedError;

  /// Serializes this ChallengeHistoryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeHistoryItemCopyWith<ChallengeHistoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeHistoryItemCopyWith<$Res> {
  factory $ChallengeHistoryItemCopyWith(
    ChallengeHistoryItem value,
    $Res Function(ChallengeHistoryItem) then,
  ) = _$ChallengeHistoryItemCopyWithImpl<$Res, ChallengeHistoryItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'OpponentName') String opponentName,
    @JsonKey(name: 'Category') String category,
    @JsonKey(name: 'Result') String result,
    @JsonKey(name: 'MyScore') int myScore,
    @JsonKey(name: 'OpponentScore') int opponentScore,
    @JsonKey(name: 'TotalQuestions') int totalQuestions,
    @JsonKey(name: 'PlayedAt') DateTime playedAt,
  });
}

/// @nodoc
class _$ChallengeHistoryItemCopyWithImpl<
  $Res,
  $Val extends ChallengeHistoryItem
>
    implements $ChallengeHistoryItemCopyWith<$Res> {
  _$ChallengeHistoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? opponentName = null,
    Object? category = null,
    Object? result = null,
    Object? myScore = null,
    Object? opponentScore = null,
    Object? totalQuestions = null,
    Object? playedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            opponentName: null == opponentName
                ? _value.opponentName
                : opponentName // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            result: null == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as String,
            myScore: null == myScore
                ? _value.myScore
                : myScore // ignore: cast_nullable_to_non_nullable
                      as int,
            opponentScore: null == opponentScore
                ? _value.opponentScore
                : opponentScore // ignore: cast_nullable_to_non_nullable
                      as int,
            totalQuestions: null == totalQuestions
                ? _value.totalQuestions
                : totalQuestions // ignore: cast_nullable_to_non_nullable
                      as int,
            playedAt: null == playedAt
                ? _value.playedAt
                : playedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChallengeHistoryItemImplCopyWith<$Res>
    implements $ChallengeHistoryItemCopyWith<$Res> {
  factory _$$ChallengeHistoryItemImplCopyWith(
    _$ChallengeHistoryItemImpl value,
    $Res Function(_$ChallengeHistoryItemImpl) then,
  ) = __$$ChallengeHistoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'OpponentName') String opponentName,
    @JsonKey(name: 'Category') String category,
    @JsonKey(name: 'Result') String result,
    @JsonKey(name: 'MyScore') int myScore,
    @JsonKey(name: 'OpponentScore') int opponentScore,
    @JsonKey(name: 'TotalQuestions') int totalQuestions,
    @JsonKey(name: 'PlayedAt') DateTime playedAt,
  });
}

/// @nodoc
class __$$ChallengeHistoryItemImplCopyWithImpl<$Res>
    extends _$ChallengeHistoryItemCopyWithImpl<$Res, _$ChallengeHistoryItemImpl>
    implements _$$ChallengeHistoryItemImplCopyWith<$Res> {
  __$$ChallengeHistoryItemImplCopyWithImpl(
    _$ChallengeHistoryItemImpl _value,
    $Res Function(_$ChallengeHistoryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChallengeHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? opponentName = null,
    Object? category = null,
    Object? result = null,
    Object? myScore = null,
    Object? opponentScore = null,
    Object? totalQuestions = null,
    Object? playedAt = null,
  }) {
    return _then(
      _$ChallengeHistoryItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        opponentName: null == opponentName
            ? _value.opponentName
            : opponentName // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        result: null == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as String,
        myScore: null == myScore
            ? _value.myScore
            : myScore // ignore: cast_nullable_to_non_nullable
                  as int,
        opponentScore: null == opponentScore
            ? _value.opponentScore
            : opponentScore // ignore: cast_nullable_to_non_nullable
                  as int,
        totalQuestions: null == totalQuestions
            ? _value.totalQuestions
            : totalQuestions // ignore: cast_nullable_to_non_nullable
                  as int,
        playedAt: null == playedAt
            ? _value.playedAt
            : playedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeHistoryItemImpl implements _ChallengeHistoryItem {
  const _$ChallengeHistoryItemImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'OpponentName') required this.opponentName,
    @JsonKey(name: 'Category') required this.category,
    @JsonKey(name: 'Result') required this.result,
    @JsonKey(name: 'MyScore') required this.myScore,
    @JsonKey(name: 'OpponentScore') required this.opponentScore,
    @JsonKey(name: 'TotalQuestions') required this.totalQuestions,
    @JsonKey(name: 'PlayedAt') required this.playedAt,
  });

  factory _$ChallengeHistoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeHistoryItemImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'OpponentName')
  final String opponentName;
  @override
  @JsonKey(name: 'Category')
  final String category;
  @override
  @JsonKey(name: 'Result')
  final String result;
  @override
  @JsonKey(name: 'MyScore')
  final int myScore;
  @override
  @JsonKey(name: 'OpponentScore')
  final int opponentScore;
  @override
  @JsonKey(name: 'TotalQuestions')
  final int totalQuestions;
  @override
  @JsonKey(name: 'PlayedAt')
  final DateTime playedAt;

  @override
  String toString() {
    return 'ChallengeHistoryItem(id: $id, opponentName: $opponentName, category: $category, result: $result, myScore: $myScore, opponentScore: $opponentScore, totalQuestions: $totalQuestions, playedAt: $playedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeHistoryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.opponentName, opponentName) ||
                other.opponentName == opponentName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.myScore, myScore) || other.myScore == myScore) &&
            (identical(other.opponentScore, opponentScore) ||
                other.opponentScore == opponentScore) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.playedAt, playedAt) ||
                other.playedAt == playedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    opponentName,
    category,
    result,
    myScore,
    opponentScore,
    totalQuestions,
    playedAt,
  );

  /// Create a copy of ChallengeHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeHistoryItemImplCopyWith<_$ChallengeHistoryItemImpl>
  get copyWith =>
      __$$ChallengeHistoryItemImplCopyWithImpl<_$ChallengeHistoryItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeHistoryItemImplToJson(this);
  }
}

abstract class _ChallengeHistoryItem implements ChallengeHistoryItem {
  const factory _ChallengeHistoryItem({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'OpponentName') required final String opponentName,
    @JsonKey(name: 'Category') required final String category,
    @JsonKey(name: 'Result') required final String result,
    @JsonKey(name: 'MyScore') required final int myScore,
    @JsonKey(name: 'OpponentScore') required final int opponentScore,
    @JsonKey(name: 'TotalQuestions') required final int totalQuestions,
    @JsonKey(name: 'PlayedAt') required final DateTime playedAt,
  }) = _$ChallengeHistoryItemImpl;

  factory _ChallengeHistoryItem.fromJson(Map<String, dynamic> json) =
      _$ChallengeHistoryItemImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'OpponentName')
  String get opponentName;
  @override
  @JsonKey(name: 'Category')
  String get category;
  @override
  @JsonKey(name: 'Result')
  String get result;
  @override
  @JsonKey(name: 'MyScore')
  int get myScore;
  @override
  @JsonKey(name: 'OpponentScore')
  int get opponentScore;
  @override
  @JsonKey(name: 'TotalQuestions')
  int get totalQuestions;
  @override
  @JsonKey(name: 'PlayedAt')
  DateTime get playedAt;

  /// Create a copy of ChallengeHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeHistoryItemImplCopyWith<_$ChallengeHistoryItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}
