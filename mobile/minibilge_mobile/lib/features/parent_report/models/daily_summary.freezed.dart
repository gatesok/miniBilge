// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailySummary _$DailySummaryFromJson(Map<String, dynamic> json) {
  return _DailySummary.fromJson(json);
}

/// @nodoc
mixin _$DailySummary {
  @JsonKey(name: 'ChildId')
  String get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'Date')
  DateTime get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalQuestionsAnswered')
  int get totalQuestionsAnswered => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectAnswers')
  int get correctAnswers => throw _privateConstructorUsedError;
  @JsonKey(name: 'WrongAnswers')
  int get wrongAnswers => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectAnswerRate')
  double get correctAnswerRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'LevelsCompleted')
  int get levelsCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'PointsEarned')
  int get pointsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'StarsEarned')
  int get starsEarned => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DailySummaryCopyWith<DailySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailySummaryCopyWith<$Res> {
  factory $DailySummaryCopyWith(
          DailySummary value, $Res Function(DailySummary) then) =
      _$DailySummaryCopyWithImpl<$Res, DailySummary>;
  @useResult
  $Res call(
      {@JsonKey(name: 'ChildId') String childId,
      @JsonKey(name: 'Date') DateTime date,
      @JsonKey(name: 'TotalQuestionsAnswered') int totalQuestionsAnswered,
      @JsonKey(name: 'CorrectAnswers') int correctAnswers,
      @JsonKey(name: 'WrongAnswers') int wrongAnswers,
      @JsonKey(name: 'CorrectAnswerRate') double correctAnswerRate,
      @JsonKey(name: 'LevelsCompleted') int levelsCompleted,
      @JsonKey(name: 'PointsEarned') int pointsEarned,
      @JsonKey(name: 'StarsEarned') int starsEarned});
}

/// @nodoc
class _$DailySummaryCopyWithImpl<$Res, $Val extends DailySummary>
    implements $DailySummaryCopyWith<$Res> {
  _$DailySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? date = null,
    Object? totalQuestionsAnswered = null,
    Object? correctAnswers = null,
    Object? wrongAnswers = null,
    Object? correctAnswerRate = null,
    Object? levelsCompleted = null,
    Object? pointsEarned = null,
    Object? starsEarned = null,
  }) {
    return _then(_value.copyWith(
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalQuestionsAnswered: null == totalQuestionsAnswered
          ? _value.totalQuestionsAnswered
          : totalQuestionsAnswered // ignore: cast_nullable_to_non_nullable
              as int,
      correctAnswers: null == correctAnswers
          ? _value.correctAnswers
          : correctAnswers // ignore: cast_nullable_to_non_nullable
              as int,
      wrongAnswers: null == wrongAnswers
          ? _value.wrongAnswers
          : wrongAnswers // ignore: cast_nullable_to_non_nullable
              as int,
      correctAnswerRate: null == correctAnswerRate
          ? _value.correctAnswerRate
          : correctAnswerRate // ignore: cast_nullable_to_non_nullable
              as double,
      levelsCompleted: null == levelsCompleted
          ? _value.levelsCompleted
          : levelsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      pointsEarned: null == pointsEarned
          ? _value.pointsEarned
          : pointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      starsEarned: null == starsEarned
          ? _value.starsEarned
          : starsEarned // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailySummaryImplCopyWith<$Res>
    implements $DailySummaryCopyWith<$Res> {
  factory _$$DailySummaryImplCopyWith(
          _$DailySummaryImpl value, $Res Function(_$DailySummaryImpl) then) =
      __$$DailySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'ChildId') String childId,
      @JsonKey(name: 'Date') DateTime date,
      @JsonKey(name: 'TotalQuestionsAnswered') int totalQuestionsAnswered,
      @JsonKey(name: 'CorrectAnswers') int correctAnswers,
      @JsonKey(name: 'WrongAnswers') int wrongAnswers,
      @JsonKey(name: 'CorrectAnswerRate') double correctAnswerRate,
      @JsonKey(name: 'LevelsCompleted') int levelsCompleted,
      @JsonKey(name: 'PointsEarned') int pointsEarned,
      @JsonKey(name: 'StarsEarned') int starsEarned});
}

/// @nodoc
class __$$DailySummaryImplCopyWithImpl<$Res>
    extends _$DailySummaryCopyWithImpl<$Res, _$DailySummaryImpl>
    implements _$$DailySummaryImplCopyWith<$Res> {
  __$$DailySummaryImplCopyWithImpl(
      _$DailySummaryImpl _value, $Res Function(_$DailySummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? date = null,
    Object? totalQuestionsAnswered = null,
    Object? correctAnswers = null,
    Object? wrongAnswers = null,
    Object? correctAnswerRate = null,
    Object? levelsCompleted = null,
    Object? pointsEarned = null,
    Object? starsEarned = null,
  }) {
    return _then(_$DailySummaryImpl(
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalQuestionsAnswered: null == totalQuestionsAnswered
          ? _value.totalQuestionsAnswered
          : totalQuestionsAnswered // ignore: cast_nullable_to_non_nullable
              as int,
      correctAnswers: null == correctAnswers
          ? _value.correctAnswers
          : correctAnswers // ignore: cast_nullable_to_non_nullable
              as int,
      wrongAnswers: null == wrongAnswers
          ? _value.wrongAnswers
          : wrongAnswers // ignore: cast_nullable_to_non_nullable
              as int,
      correctAnswerRate: null == correctAnswerRate
          ? _value.correctAnswerRate
          : correctAnswerRate // ignore: cast_nullable_to_non_nullable
              as double,
      levelsCompleted: null == levelsCompleted
          ? _value.levelsCompleted
          : levelsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      pointsEarned: null == pointsEarned
          ? _value.pointsEarned
          : pointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      starsEarned: null == starsEarned
          ? _value.starsEarned
          : starsEarned // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailySummaryImpl implements _DailySummary {
  const _$DailySummaryImpl(
      {@JsonKey(name: 'ChildId') required this.childId,
      @JsonKey(name: 'Date') required this.date,
      @JsonKey(name: 'TotalQuestionsAnswered')
      required this.totalQuestionsAnswered,
      @JsonKey(name: 'CorrectAnswers') required this.correctAnswers,
      @JsonKey(name: 'WrongAnswers') required this.wrongAnswers,
      @JsonKey(name: 'CorrectAnswerRate') required this.correctAnswerRate,
      @JsonKey(name: 'LevelsCompleted') required this.levelsCompleted,
      @JsonKey(name: 'PointsEarned') required this.pointsEarned,
      @JsonKey(name: 'StarsEarned') required this.starsEarned});

  factory _$DailySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailySummaryImplFromJson(json);

  @override
  @JsonKey(name: 'ChildId')
  final String childId;
  @override
  @JsonKey(name: 'Date')
  final DateTime date;
  @override
  @JsonKey(name: 'TotalQuestionsAnswered')
  final int totalQuestionsAnswered;
  @override
  @JsonKey(name: 'CorrectAnswers')
  final int correctAnswers;
  @override
  @JsonKey(name: 'WrongAnswers')
  final int wrongAnswers;
  @override
  @JsonKey(name: 'CorrectAnswerRate')
  final double correctAnswerRate;
  @override
  @JsonKey(name: 'LevelsCompleted')
  final int levelsCompleted;
  @override
  @JsonKey(name: 'PointsEarned')
  final int pointsEarned;
  @override
  @JsonKey(name: 'StarsEarned')
  final int starsEarned;

  @override
  String toString() {
    return 'DailySummary(childId: $childId, date: $date, totalQuestionsAnswered: $totalQuestionsAnswered, correctAnswers: $correctAnswers, wrongAnswers: $wrongAnswers, correctAnswerRate: $correctAnswerRate, levelsCompleted: $levelsCompleted, pointsEarned: $pointsEarned, starsEarned: $starsEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailySummaryImpl &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalQuestionsAnswered, totalQuestionsAnswered) ||
                other.totalQuestionsAnswered == totalQuestionsAnswered) &&
            (identical(other.correctAnswers, correctAnswers) ||
                other.correctAnswers == correctAnswers) &&
            (identical(other.wrongAnswers, wrongAnswers) ||
                other.wrongAnswers == wrongAnswers) &&
            (identical(other.correctAnswerRate, correctAnswerRate) ||
                other.correctAnswerRate == correctAnswerRate) &&
            (identical(other.levelsCompleted, levelsCompleted) ||
                other.levelsCompleted == levelsCompleted) &&
            (identical(other.pointsEarned, pointsEarned) ||
                other.pointsEarned == pointsEarned) &&
            (identical(other.starsEarned, starsEarned) ||
                other.starsEarned == starsEarned));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      childId,
      date,
      totalQuestionsAnswered,
      correctAnswers,
      wrongAnswers,
      correctAnswerRate,
      levelsCompleted,
      pointsEarned,
      starsEarned);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DailySummaryImplCopyWith<_$DailySummaryImpl> get copyWith =>
      __$$DailySummaryImplCopyWithImpl<_$DailySummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailySummaryImplToJson(
      this,
    );
  }
}

abstract class _DailySummary implements DailySummary {
  const factory _DailySummary(
          {@JsonKey(name: 'ChildId') required final String childId,
          @JsonKey(name: 'Date') required final DateTime date,
          @JsonKey(name: 'TotalQuestionsAnswered')
          required final int totalQuestionsAnswered,
          @JsonKey(name: 'CorrectAnswers') required final int correctAnswers,
          @JsonKey(name: 'WrongAnswers') required final int wrongAnswers,
          @JsonKey(name: 'CorrectAnswerRate')
          required final double correctAnswerRate,
          @JsonKey(name: 'LevelsCompleted') required final int levelsCompleted,
          @JsonKey(name: 'PointsEarned') required final int pointsEarned,
          @JsonKey(name: 'StarsEarned') required final int starsEarned}) =
      _$DailySummaryImpl;

  factory _DailySummary.fromJson(Map<String, dynamic> json) =
      _$DailySummaryImpl.fromJson;

  @override
  @JsonKey(name: 'ChildId')
  String get childId;
  @override
  @JsonKey(name: 'Date')
  DateTime get date;
  @override
  @JsonKey(name: 'TotalQuestionsAnswered')
  int get totalQuestionsAnswered;
  @override
  @JsonKey(name: 'CorrectAnswers')
  int get correctAnswers;
  @override
  @JsonKey(name: 'WrongAnswers')
  int get wrongAnswers;
  @override
  @JsonKey(name: 'CorrectAnswerRate')
  double get correctAnswerRate;
  @override
  @JsonKey(name: 'LevelsCompleted')
  int get levelsCompleted;
  @override
  @JsonKey(name: 'PointsEarned')
  int get pointsEarned;
  @override
  @JsonKey(name: 'StarsEarned')
  int get starsEarned;
  @override
  @JsonKey(ignore: true)
  _$$DailySummaryImplCopyWith<_$DailySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
