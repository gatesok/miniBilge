// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'level_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LevelResult _$LevelResultFromJson(Map<String, dynamic> json) {
  return _LevelResult.fromJson(json);
}

/// @nodoc
mixin _$LevelResult {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'ChildId')
  String get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'LevelId')
  String get levelId => throw _privateConstructorUsedError;
  @JsonKey(name: 'Score')
  int get score => throw _privateConstructorUsedError;
  @JsonKey(name: 'Stars')
  int get stars => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectCount')
  int get correctCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalQuestions')
  int get totalQuestions => throw _privateConstructorUsedError;
  @JsonKey(name: 'SuccessPercentage')
  double get successPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'IsUnlocked')
  bool get isUnlocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'CompletedAt')
  String? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this LevelResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LevelResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LevelResultCopyWith<LevelResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelResultCopyWith<$Res> {
  factory $LevelResultCopyWith(
    LevelResult value,
    $Res Function(LevelResult) then,
  ) = _$LevelResultCopyWithImpl<$Res, LevelResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'ChildId') String childId,
    @JsonKey(name: 'LevelId') String levelId,
    @JsonKey(name: 'Score') int score,
    @JsonKey(name: 'Stars') int stars,
    @JsonKey(name: 'CorrectCount') int correctCount,
    @JsonKey(name: 'TotalQuestions') int totalQuestions,
    @JsonKey(name: 'SuccessPercentage') double successPercentage,
    @JsonKey(name: 'IsUnlocked') bool isUnlocked,
    @JsonKey(name: 'CompletedAt') String? completedAt,
  });
}

/// @nodoc
class _$LevelResultCopyWithImpl<$Res, $Val extends LevelResult>
    implements $LevelResultCopyWith<$Res> {
  _$LevelResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LevelResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? levelId = null,
    Object? score = null,
    Object? stars = null,
    Object? correctCount = null,
    Object? totalQuestions = null,
    Object? successPercentage = null,
    Object? isUnlocked = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            childId: null == childId
                ? _value.childId
                : childId // ignore: cast_nullable_to_non_nullable
                      as String,
            levelId: null == levelId
                ? _value.levelId
                : levelId // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            stars: null == stars
                ? _value.stars
                : stars // ignore: cast_nullable_to_non_nullable
                      as int,
            correctCount: null == correctCount
                ? _value.correctCount
                : correctCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalQuestions: null == totalQuestions
                ? _value.totalQuestions
                : totalQuestions // ignore: cast_nullable_to_non_nullable
                      as int,
            successPercentage: null == successPercentage
                ? _value.successPercentage
                : successPercentage // ignore: cast_nullable_to_non_nullable
                      as double,
            isUnlocked: null == isUnlocked
                ? _value.isUnlocked
                : isUnlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LevelResultImplCopyWith<$Res>
    implements $LevelResultCopyWith<$Res> {
  factory _$$LevelResultImplCopyWith(
    _$LevelResultImpl value,
    $Res Function(_$LevelResultImpl) then,
  ) = __$$LevelResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'ChildId') String childId,
    @JsonKey(name: 'LevelId') String levelId,
    @JsonKey(name: 'Score') int score,
    @JsonKey(name: 'Stars') int stars,
    @JsonKey(name: 'CorrectCount') int correctCount,
    @JsonKey(name: 'TotalQuestions') int totalQuestions,
    @JsonKey(name: 'SuccessPercentage') double successPercentage,
    @JsonKey(name: 'IsUnlocked') bool isUnlocked,
    @JsonKey(name: 'CompletedAt') String? completedAt,
  });
}

/// @nodoc
class __$$LevelResultImplCopyWithImpl<$Res>
    extends _$LevelResultCopyWithImpl<$Res, _$LevelResultImpl>
    implements _$$LevelResultImplCopyWith<$Res> {
  __$$LevelResultImplCopyWithImpl(
    _$LevelResultImpl _value,
    $Res Function(_$LevelResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LevelResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? levelId = null,
    Object? score = null,
    Object? stars = null,
    Object? correctCount = null,
    Object? totalQuestions = null,
    Object? successPercentage = null,
    Object? isUnlocked = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$LevelResultImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        childId: null == childId
            ? _value.childId
            : childId // ignore: cast_nullable_to_non_nullable
                  as String,
        levelId: null == levelId
            ? _value.levelId
            : levelId // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        stars: null == stars
            ? _value.stars
            : stars // ignore: cast_nullable_to_non_nullable
                  as int,
        correctCount: null == correctCount
            ? _value.correctCount
            : correctCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalQuestions: null == totalQuestions
            ? _value.totalQuestions
            : totalQuestions // ignore: cast_nullable_to_non_nullable
                  as int,
        successPercentage: null == successPercentage
            ? _value.successPercentage
            : successPercentage // ignore: cast_nullable_to_non_nullable
                  as double,
        isUnlocked: null == isUnlocked
            ? _value.isUnlocked
            : isUnlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LevelResultImpl implements _LevelResult {
  const _$LevelResultImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'ChildId') required this.childId,
    @JsonKey(name: 'LevelId') required this.levelId,
    @JsonKey(name: 'Score') required this.score,
    @JsonKey(name: 'Stars') required this.stars,
    @JsonKey(name: 'CorrectCount') required this.correctCount,
    @JsonKey(name: 'TotalQuestions') required this.totalQuestions,
    @JsonKey(name: 'SuccessPercentage') required this.successPercentage,
    @JsonKey(name: 'IsUnlocked') required this.isUnlocked,
    @JsonKey(name: 'CompletedAt') this.completedAt,
  });

  factory _$LevelResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$LevelResultImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'ChildId')
  final String childId;
  @override
  @JsonKey(name: 'LevelId')
  final String levelId;
  @override
  @JsonKey(name: 'Score')
  final int score;
  @override
  @JsonKey(name: 'Stars')
  final int stars;
  @override
  @JsonKey(name: 'CorrectCount')
  final int correctCount;
  @override
  @JsonKey(name: 'TotalQuestions')
  final int totalQuestions;
  @override
  @JsonKey(name: 'SuccessPercentage')
  final double successPercentage;
  @override
  @JsonKey(name: 'IsUnlocked')
  final bool isUnlocked;
  @override
  @JsonKey(name: 'CompletedAt')
  final String? completedAt;

  @override
  String toString() {
    return 'LevelResult(id: $id, childId: $childId, levelId: $levelId, score: $score, stars: $stars, correctCount: $correctCount, totalQuestions: $totalQuestions, successPercentage: $successPercentage, isUnlocked: $isUnlocked, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.levelId, levelId) || other.levelId == levelId) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.stars, stars) || other.stars == stars) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.successPercentage, successPercentage) ||
                other.successPercentage == successPercentage) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    childId,
    levelId,
    score,
    stars,
    correctCount,
    totalQuestions,
    successPercentage,
    isUnlocked,
    completedAt,
  );

  /// Create a copy of LevelResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelResultImplCopyWith<_$LevelResultImpl> get copyWith =>
      __$$LevelResultImplCopyWithImpl<_$LevelResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LevelResultImplToJson(this);
  }
}

abstract class _LevelResult implements LevelResult {
  const factory _LevelResult({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'ChildId') required final String childId,
    @JsonKey(name: 'LevelId') required final String levelId,
    @JsonKey(name: 'Score') required final int score,
    @JsonKey(name: 'Stars') required final int stars,
    @JsonKey(name: 'CorrectCount') required final int correctCount,
    @JsonKey(name: 'TotalQuestions') required final int totalQuestions,
    @JsonKey(name: 'SuccessPercentage') required final double successPercentage,
    @JsonKey(name: 'IsUnlocked') required final bool isUnlocked,
    @JsonKey(name: 'CompletedAt') final String? completedAt,
  }) = _$LevelResultImpl;

  factory _LevelResult.fromJson(Map<String, dynamic> json) =
      _$LevelResultImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'ChildId')
  String get childId;
  @override
  @JsonKey(name: 'LevelId')
  String get levelId;
  @override
  @JsonKey(name: 'Score')
  int get score;
  @override
  @JsonKey(name: 'Stars')
  int get stars;
  @override
  @JsonKey(name: 'CorrectCount')
  int get correctCount;
  @override
  @JsonKey(name: 'TotalQuestions')
  int get totalQuestions;
  @override
  @JsonKey(name: 'SuccessPercentage')
  double get successPercentage;
  @override
  @JsonKey(name: 'IsUnlocked')
  bool get isUnlocked;
  @override
  @JsonKey(name: 'CompletedAt')
  String? get completedAt;

  /// Create a copy of LevelResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LevelResultImplCopyWith<_$LevelResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
