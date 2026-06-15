// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WeeklySummary _$WeeklySummaryFromJson(Map<String, dynamic> json) {
  return _WeeklySummary.fromJson(json);
}

/// @nodoc
mixin _$WeeklySummary {
  @JsonKey(name: 'ChildId')
  String get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'WeekStart')
  DateTime get weekStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'WeekEnd')
  DateTime get weekEnd => throw _privateConstructorUsedError;
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
  @JsonKey(name: 'TotalPointsEarned')
  int get totalPointsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalStarsEarned')
  int get totalStarsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'ActiveDays')
  int get activeDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'DailyBreakdown')
  List<DailySummary> get dailyBreakdown => throw _privateConstructorUsedError;

  /// Serializes this WeeklySummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklySummaryCopyWith<WeeklySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklySummaryCopyWith<$Res> {
  factory $WeeklySummaryCopyWith(
    WeeklySummary value,
    $Res Function(WeeklySummary) then,
  ) = _$WeeklySummaryCopyWithImpl<$Res, WeeklySummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'ChildId') String childId,
    @JsonKey(name: 'WeekStart') DateTime weekStart,
    @JsonKey(name: 'WeekEnd') DateTime weekEnd,
    @JsonKey(name: 'TotalQuestionsAnswered') int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') int correctAnswers,
    @JsonKey(name: 'WrongAnswers') int wrongAnswers,
    @JsonKey(name: 'CorrectAnswerRate') double correctAnswerRate,
    @JsonKey(name: 'LevelsCompleted') int levelsCompleted,
    @JsonKey(name: 'TotalPointsEarned') int totalPointsEarned,
    @JsonKey(name: 'TotalStarsEarned') int totalStarsEarned,
    @JsonKey(name: 'ActiveDays') int activeDays,
    @JsonKey(name: 'DailyBreakdown') List<DailySummary> dailyBreakdown,
  });
}

/// @nodoc
class _$WeeklySummaryCopyWithImpl<$Res, $Val extends WeeklySummary>
    implements $WeeklySummaryCopyWith<$Res> {
  _$WeeklySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? totalQuestionsAnswered = null,
    Object? correctAnswers = null,
    Object? wrongAnswers = null,
    Object? correctAnswerRate = null,
    Object? levelsCompleted = null,
    Object? totalPointsEarned = null,
    Object? totalStarsEarned = null,
    Object? activeDays = null,
    Object? dailyBreakdown = null,
  }) {
    return _then(
      _value.copyWith(
            childId: null == childId
                ? _value.childId
                : childId // ignore: cast_nullable_to_non_nullable
                      as String,
            weekStart: null == weekStart
                ? _value.weekStart
                : weekStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            weekEnd: null == weekEnd
                ? _value.weekEnd
                : weekEnd // ignore: cast_nullable_to_non_nullable
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
            totalPointsEarned: null == totalPointsEarned
                ? _value.totalPointsEarned
                : totalPointsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
            totalStarsEarned: null == totalStarsEarned
                ? _value.totalStarsEarned
                : totalStarsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
            activeDays: null == activeDays
                ? _value.activeDays
                : activeDays // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyBreakdown: null == dailyBreakdown
                ? _value.dailyBreakdown
                : dailyBreakdown // ignore: cast_nullable_to_non_nullable
                      as List<DailySummary>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeeklySummaryImplCopyWith<$Res>
    implements $WeeklySummaryCopyWith<$Res> {
  factory _$$WeeklySummaryImplCopyWith(
    _$WeeklySummaryImpl value,
    $Res Function(_$WeeklySummaryImpl) then,
  ) = __$$WeeklySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ChildId') String childId,
    @JsonKey(name: 'WeekStart') DateTime weekStart,
    @JsonKey(name: 'WeekEnd') DateTime weekEnd,
    @JsonKey(name: 'TotalQuestionsAnswered') int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') int correctAnswers,
    @JsonKey(name: 'WrongAnswers') int wrongAnswers,
    @JsonKey(name: 'CorrectAnswerRate') double correctAnswerRate,
    @JsonKey(name: 'LevelsCompleted') int levelsCompleted,
    @JsonKey(name: 'TotalPointsEarned') int totalPointsEarned,
    @JsonKey(name: 'TotalStarsEarned') int totalStarsEarned,
    @JsonKey(name: 'ActiveDays') int activeDays,
    @JsonKey(name: 'DailyBreakdown') List<DailySummary> dailyBreakdown,
  });
}

/// @nodoc
class __$$WeeklySummaryImplCopyWithImpl<$Res>
    extends _$WeeklySummaryCopyWithImpl<$Res, _$WeeklySummaryImpl>
    implements _$$WeeklySummaryImplCopyWith<$Res> {
  __$$WeeklySummaryImplCopyWithImpl(
    _$WeeklySummaryImpl _value,
    $Res Function(_$WeeklySummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeeklySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? totalQuestionsAnswered = null,
    Object? correctAnswers = null,
    Object? wrongAnswers = null,
    Object? correctAnswerRate = null,
    Object? levelsCompleted = null,
    Object? totalPointsEarned = null,
    Object? totalStarsEarned = null,
    Object? activeDays = null,
    Object? dailyBreakdown = null,
  }) {
    return _then(
      _$WeeklySummaryImpl(
        childId: null == childId
            ? _value.childId
            : childId // ignore: cast_nullable_to_non_nullable
                  as String,
        weekStart: null == weekStart
            ? _value.weekStart
            : weekStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        weekEnd: null == weekEnd
            ? _value.weekEnd
            : weekEnd // ignore: cast_nullable_to_non_nullable
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
        totalPointsEarned: null == totalPointsEarned
            ? _value.totalPointsEarned
            : totalPointsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
        totalStarsEarned: null == totalStarsEarned
            ? _value.totalStarsEarned
            : totalStarsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
        activeDays: null == activeDays
            ? _value.activeDays
            : activeDays // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyBreakdown: null == dailyBreakdown
            ? _value._dailyBreakdown
            : dailyBreakdown // ignore: cast_nullable_to_non_nullable
                  as List<DailySummary>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklySummaryImpl implements _WeeklySummary {
  const _$WeeklySummaryImpl({
    @JsonKey(name: 'ChildId') required this.childId,
    @JsonKey(name: 'WeekStart') required this.weekStart,
    @JsonKey(name: 'WeekEnd') required this.weekEnd,
    @JsonKey(name: 'TotalQuestionsAnswered')
    required this.totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') required this.correctAnswers,
    @JsonKey(name: 'WrongAnswers') required this.wrongAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required this.correctAnswerRate,
    @JsonKey(name: 'LevelsCompleted') required this.levelsCompleted,
    @JsonKey(name: 'TotalPointsEarned') required this.totalPointsEarned,
    @JsonKey(name: 'TotalStarsEarned') required this.totalStarsEarned,
    @JsonKey(name: 'ActiveDays') required this.activeDays,
    @JsonKey(name: 'DailyBreakdown')
    required final List<DailySummary> dailyBreakdown,
  }) : _dailyBreakdown = dailyBreakdown;

  factory _$WeeklySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklySummaryImplFromJson(json);

  @override
  @JsonKey(name: 'ChildId')
  final String childId;
  @override
  @JsonKey(name: 'WeekStart')
  final DateTime weekStart;
  @override
  @JsonKey(name: 'WeekEnd')
  final DateTime weekEnd;
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
  @JsonKey(name: 'TotalPointsEarned')
  final int totalPointsEarned;
  @override
  @JsonKey(name: 'TotalStarsEarned')
  final int totalStarsEarned;
  @override
  @JsonKey(name: 'ActiveDays')
  final int activeDays;
  final List<DailySummary> _dailyBreakdown;
  @override
  @JsonKey(name: 'DailyBreakdown')
  List<DailySummary> get dailyBreakdown {
    if (_dailyBreakdown is EqualUnmodifiableListView) return _dailyBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyBreakdown);
  }

  @override
  String toString() {
    return 'WeeklySummary(childId: $childId, weekStart: $weekStart, weekEnd: $weekEnd, totalQuestionsAnswered: $totalQuestionsAnswered, correctAnswers: $correctAnswers, wrongAnswers: $wrongAnswers, correctAnswerRate: $correctAnswerRate, levelsCompleted: $levelsCompleted, totalPointsEarned: $totalPointsEarned, totalStarsEarned: $totalStarsEarned, activeDays: $activeDays, dailyBreakdown: $dailyBreakdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklySummaryImpl &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.weekEnd, weekEnd) || other.weekEnd == weekEnd) &&
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
            (identical(other.totalPointsEarned, totalPointsEarned) ||
                other.totalPointsEarned == totalPointsEarned) &&
            (identical(other.totalStarsEarned, totalStarsEarned) ||
                other.totalStarsEarned == totalStarsEarned) &&
            (identical(other.activeDays, activeDays) ||
                other.activeDays == activeDays) &&
            const DeepCollectionEquality().equals(
              other._dailyBreakdown,
              _dailyBreakdown,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    childId,
    weekStart,
    weekEnd,
    totalQuestionsAnswered,
    correctAnswers,
    wrongAnswers,
    correctAnswerRate,
    levelsCompleted,
    totalPointsEarned,
    totalStarsEarned,
    activeDays,
    const DeepCollectionEquality().hash(_dailyBreakdown),
  );

  /// Create a copy of WeeklySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklySummaryImplCopyWith<_$WeeklySummaryImpl> get copyWith =>
      __$$WeeklySummaryImplCopyWithImpl<_$WeeklySummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklySummaryImplToJson(this);
  }
}

abstract class _WeeklySummary implements WeeklySummary {
  const factory _WeeklySummary({
    @JsonKey(name: 'ChildId') required final String childId,
    @JsonKey(name: 'WeekStart') required final DateTime weekStart,
    @JsonKey(name: 'WeekEnd') required final DateTime weekEnd,
    @JsonKey(name: 'TotalQuestionsAnswered')
    required final int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') required final int correctAnswers,
    @JsonKey(name: 'WrongAnswers') required final int wrongAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required final double correctAnswerRate,
    @JsonKey(name: 'LevelsCompleted') required final int levelsCompleted,
    @JsonKey(name: 'TotalPointsEarned') required final int totalPointsEarned,
    @JsonKey(name: 'TotalStarsEarned') required final int totalStarsEarned,
    @JsonKey(name: 'ActiveDays') required final int activeDays,
    @JsonKey(name: 'DailyBreakdown')
    required final List<DailySummary> dailyBreakdown,
  }) = _$WeeklySummaryImpl;

  factory _WeeklySummary.fromJson(Map<String, dynamic> json) =
      _$WeeklySummaryImpl.fromJson;

  @override
  @JsonKey(name: 'ChildId')
  String get childId;
  @override
  @JsonKey(name: 'WeekStart')
  DateTime get weekStart;
  @override
  @JsonKey(name: 'WeekEnd')
  DateTime get weekEnd;
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
  @JsonKey(name: 'TotalPointsEarned')
  int get totalPointsEarned;
  @override
  @JsonKey(name: 'TotalStarsEarned')
  int get totalStarsEarned;
  @override
  @JsonKey(name: 'ActiveDays')
  int get activeDays;
  @override
  @JsonKey(name: 'DailyBreakdown')
  List<DailySummary> get dailyBreakdown;

  /// Create a copy of WeeklySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklySummaryImplCopyWith<_$WeeklySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
