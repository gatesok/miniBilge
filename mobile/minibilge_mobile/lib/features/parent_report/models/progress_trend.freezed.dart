// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_trend.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProgressTrend _$ProgressTrendFromJson(Map<String, dynamic> json) {
  return _ProgressTrend.fromJson(json);
}

/// @nodoc
mixin _$ProgressTrend {
  @JsonKey(name: 'ChildId')
  String get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'Days')
  int get days => throw _privateConstructorUsedError;
  @JsonKey(name: 'PeriodStart')
  DateTime get periodStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'PeriodEnd')
  DateTime get periodEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalQuestionsAnswered')
  int get totalQuestionsAnswered => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectAnswers')
  int get correctAnswers => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectAnswerRate')
  double get correctAnswerRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'ActiveDays')
  int get activeDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'LevelsCompleted')
  int get levelsCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalPointsEarned')
  int get totalPointsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalStarsEarned')
  int get totalStarsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'WeeklyTrend')
  List<TrendPoint> get weeklyTrend => throw _privateConstructorUsedError;

  /// Serializes this ProgressTrend to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressTrendCopyWith<ProgressTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressTrendCopyWith<$Res> {
  factory $ProgressTrendCopyWith(
    ProgressTrend value,
    $Res Function(ProgressTrend) then,
  ) = _$ProgressTrendCopyWithImpl<$Res, ProgressTrend>;
  @useResult
  $Res call({
    @JsonKey(name: 'ChildId') String childId,
    @JsonKey(name: 'Days') int days,
    @JsonKey(name: 'PeriodStart') DateTime periodStart,
    @JsonKey(name: 'PeriodEnd') DateTime periodEnd,
    @JsonKey(name: 'TotalQuestionsAnswered') int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') int correctAnswers,
    @JsonKey(name: 'CorrectAnswerRate') double correctAnswerRate,
    @JsonKey(name: 'ActiveDays') int activeDays,
    @JsonKey(name: 'LevelsCompleted') int levelsCompleted,
    @JsonKey(name: 'TotalPointsEarned') int totalPointsEarned,
    @JsonKey(name: 'TotalStarsEarned') int totalStarsEarned,
    @JsonKey(name: 'WeeklyTrend') List<TrendPoint> weeklyTrend,
  });
}

/// @nodoc
class _$ProgressTrendCopyWithImpl<$Res, $Val extends ProgressTrend>
    implements $ProgressTrendCopyWith<$Res> {
  _$ProgressTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? days = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? totalQuestionsAnswered = null,
    Object? correctAnswers = null,
    Object? correctAnswerRate = null,
    Object? activeDays = null,
    Object? levelsCompleted = null,
    Object? totalPointsEarned = null,
    Object? totalStarsEarned = null,
    Object? weeklyTrend = null,
  }) {
    return _then(
      _value.copyWith(
            childId: null == childId
                ? _value.childId
                : childId // ignore: cast_nullable_to_non_nullable
                      as String,
            days: null == days
                ? _value.days
                : days // ignore: cast_nullable_to_non_nullable
                      as int,
            periodStart: null == periodStart
                ? _value.periodStart
                : periodStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            periodEnd: null == periodEnd
                ? _value.periodEnd
                : periodEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            totalQuestionsAnswered: null == totalQuestionsAnswered
                ? _value.totalQuestionsAnswered
                : totalQuestionsAnswered // ignore: cast_nullable_to_non_nullable
                      as int,
            correctAnswers: null == correctAnswers
                ? _value.correctAnswers
                : correctAnswers // ignore: cast_nullable_to_non_nullable
                      as int,
            correctAnswerRate: null == correctAnswerRate
                ? _value.correctAnswerRate
                : correctAnswerRate // ignore: cast_nullable_to_non_nullable
                      as double,
            activeDays: null == activeDays
                ? _value.activeDays
                : activeDays // ignore: cast_nullable_to_non_nullable
                      as int,
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
            weeklyTrend: null == weeklyTrend
                ? _value.weeklyTrend
                : weeklyTrend // ignore: cast_nullable_to_non_nullable
                      as List<TrendPoint>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProgressTrendImplCopyWith<$Res>
    implements $ProgressTrendCopyWith<$Res> {
  factory _$$ProgressTrendImplCopyWith(
    _$ProgressTrendImpl value,
    $Res Function(_$ProgressTrendImpl) then,
  ) = __$$ProgressTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ChildId') String childId,
    @JsonKey(name: 'Days') int days,
    @JsonKey(name: 'PeriodStart') DateTime periodStart,
    @JsonKey(name: 'PeriodEnd') DateTime periodEnd,
    @JsonKey(name: 'TotalQuestionsAnswered') int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') int correctAnswers,
    @JsonKey(name: 'CorrectAnswerRate') double correctAnswerRate,
    @JsonKey(name: 'ActiveDays') int activeDays,
    @JsonKey(name: 'LevelsCompleted') int levelsCompleted,
    @JsonKey(name: 'TotalPointsEarned') int totalPointsEarned,
    @JsonKey(name: 'TotalStarsEarned') int totalStarsEarned,
    @JsonKey(name: 'WeeklyTrend') List<TrendPoint> weeklyTrend,
  });
}

/// @nodoc
class __$$ProgressTrendImplCopyWithImpl<$Res>
    extends _$ProgressTrendCopyWithImpl<$Res, _$ProgressTrendImpl>
    implements _$$ProgressTrendImplCopyWith<$Res> {
  __$$ProgressTrendImplCopyWithImpl(
    _$ProgressTrendImpl _value,
    $Res Function(_$ProgressTrendImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgressTrend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? days = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? totalQuestionsAnswered = null,
    Object? correctAnswers = null,
    Object? correctAnswerRate = null,
    Object? activeDays = null,
    Object? levelsCompleted = null,
    Object? totalPointsEarned = null,
    Object? totalStarsEarned = null,
    Object? weeklyTrend = null,
  }) {
    return _then(
      _$ProgressTrendImpl(
        childId: null == childId
            ? _value.childId
            : childId // ignore: cast_nullable_to_non_nullable
                  as String,
        days: null == days
            ? _value.days
            : days // ignore: cast_nullable_to_non_nullable
                  as int,
        periodStart: null == periodStart
            ? _value.periodStart
            : periodStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        periodEnd: null == periodEnd
            ? _value.periodEnd
            : periodEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        totalQuestionsAnswered: null == totalQuestionsAnswered
            ? _value.totalQuestionsAnswered
            : totalQuestionsAnswered // ignore: cast_nullable_to_non_nullable
                  as int,
        correctAnswers: null == correctAnswers
            ? _value.correctAnswers
            : correctAnswers // ignore: cast_nullable_to_non_nullable
                  as int,
        correctAnswerRate: null == correctAnswerRate
            ? _value.correctAnswerRate
            : correctAnswerRate // ignore: cast_nullable_to_non_nullable
                  as double,
        activeDays: null == activeDays
            ? _value.activeDays
            : activeDays // ignore: cast_nullable_to_non_nullable
                  as int,
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
        weeklyTrend: null == weeklyTrend
            ? _value._weeklyTrend
            : weeklyTrend // ignore: cast_nullable_to_non_nullable
                  as List<TrendPoint>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressTrendImpl implements _ProgressTrend {
  const _$ProgressTrendImpl({
    @JsonKey(name: 'ChildId') required this.childId,
    @JsonKey(name: 'Days') required this.days,
    @JsonKey(name: 'PeriodStart') required this.periodStart,
    @JsonKey(name: 'PeriodEnd') required this.periodEnd,
    @JsonKey(name: 'TotalQuestionsAnswered')
    required this.totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') required this.correctAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required this.correctAnswerRate,
    @JsonKey(name: 'ActiveDays') required this.activeDays,
    @JsonKey(name: 'LevelsCompleted') required this.levelsCompleted,
    @JsonKey(name: 'TotalPointsEarned') required this.totalPointsEarned,
    @JsonKey(name: 'TotalStarsEarned') required this.totalStarsEarned,
    @JsonKey(name: 'WeeklyTrend') final List<TrendPoint> weeklyTrend = const [],
  }) : _weeklyTrend = weeklyTrend;

  factory _$ProgressTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressTrendImplFromJson(json);

  @override
  @JsonKey(name: 'ChildId')
  final String childId;
  @override
  @JsonKey(name: 'Days')
  final int days;
  @override
  @JsonKey(name: 'PeriodStart')
  final DateTime periodStart;
  @override
  @JsonKey(name: 'PeriodEnd')
  final DateTime periodEnd;
  @override
  @JsonKey(name: 'TotalQuestionsAnswered')
  final int totalQuestionsAnswered;
  @override
  @JsonKey(name: 'CorrectAnswers')
  final int correctAnswers;
  @override
  @JsonKey(name: 'CorrectAnswerRate')
  final double correctAnswerRate;
  @override
  @JsonKey(name: 'ActiveDays')
  final int activeDays;
  @override
  @JsonKey(name: 'LevelsCompleted')
  final int levelsCompleted;
  @override
  @JsonKey(name: 'TotalPointsEarned')
  final int totalPointsEarned;
  @override
  @JsonKey(name: 'TotalStarsEarned')
  final int totalStarsEarned;
  final List<TrendPoint> _weeklyTrend;
  @override
  @JsonKey(name: 'WeeklyTrend')
  List<TrendPoint> get weeklyTrend {
    if (_weeklyTrend is EqualUnmodifiableListView) return _weeklyTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weeklyTrend);
  }

  @override
  String toString() {
    return 'ProgressTrend(childId: $childId, days: $days, periodStart: $periodStart, periodEnd: $periodEnd, totalQuestionsAnswered: $totalQuestionsAnswered, correctAnswers: $correctAnswers, correctAnswerRate: $correctAnswerRate, activeDays: $activeDays, levelsCompleted: $levelsCompleted, totalPointsEarned: $totalPointsEarned, totalStarsEarned: $totalStarsEarned, weeklyTrend: $weeklyTrend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressTrendImpl &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.days, days) || other.days == days) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.totalQuestionsAnswered, totalQuestionsAnswered) ||
                other.totalQuestionsAnswered == totalQuestionsAnswered) &&
            (identical(other.correctAnswers, correctAnswers) ||
                other.correctAnswers == correctAnswers) &&
            (identical(other.correctAnswerRate, correctAnswerRate) ||
                other.correctAnswerRate == correctAnswerRate) &&
            (identical(other.activeDays, activeDays) ||
                other.activeDays == activeDays) &&
            (identical(other.levelsCompleted, levelsCompleted) ||
                other.levelsCompleted == levelsCompleted) &&
            (identical(other.totalPointsEarned, totalPointsEarned) ||
                other.totalPointsEarned == totalPointsEarned) &&
            (identical(other.totalStarsEarned, totalStarsEarned) ||
                other.totalStarsEarned == totalStarsEarned) &&
            const DeepCollectionEquality().equals(
              other._weeklyTrend,
              _weeklyTrend,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    childId,
    days,
    periodStart,
    periodEnd,
    totalQuestionsAnswered,
    correctAnswers,
    correctAnswerRate,
    activeDays,
    levelsCompleted,
    totalPointsEarned,
    totalStarsEarned,
    const DeepCollectionEquality().hash(_weeklyTrend),
  );

  /// Create a copy of ProgressTrend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressTrendImplCopyWith<_$ProgressTrendImpl> get copyWith =>
      __$$ProgressTrendImplCopyWithImpl<_$ProgressTrendImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressTrendImplToJson(this);
  }
}

abstract class _ProgressTrend implements ProgressTrend {
  const factory _ProgressTrend({
    @JsonKey(name: 'ChildId') required final String childId,
    @JsonKey(name: 'Days') required final int days,
    @JsonKey(name: 'PeriodStart') required final DateTime periodStart,
    @JsonKey(name: 'PeriodEnd') required final DateTime periodEnd,
    @JsonKey(name: 'TotalQuestionsAnswered')
    required final int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') required final int correctAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required final double correctAnswerRate,
    @JsonKey(name: 'ActiveDays') required final int activeDays,
    @JsonKey(name: 'LevelsCompleted') required final int levelsCompleted,
    @JsonKey(name: 'TotalPointsEarned') required final int totalPointsEarned,
    @JsonKey(name: 'TotalStarsEarned') required final int totalStarsEarned,
    @JsonKey(name: 'WeeklyTrend') final List<TrendPoint> weeklyTrend,
  }) = _$ProgressTrendImpl;

  factory _ProgressTrend.fromJson(Map<String, dynamic> json) =
      _$ProgressTrendImpl.fromJson;

  @override
  @JsonKey(name: 'ChildId')
  String get childId;
  @override
  @JsonKey(name: 'Days')
  int get days;
  @override
  @JsonKey(name: 'PeriodStart')
  DateTime get periodStart;
  @override
  @JsonKey(name: 'PeriodEnd')
  DateTime get periodEnd;
  @override
  @JsonKey(name: 'TotalQuestionsAnswered')
  int get totalQuestionsAnswered;
  @override
  @JsonKey(name: 'CorrectAnswers')
  int get correctAnswers;
  @override
  @JsonKey(name: 'CorrectAnswerRate')
  double get correctAnswerRate;
  @override
  @JsonKey(name: 'ActiveDays')
  int get activeDays;
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
  @JsonKey(name: 'WeeklyTrend')
  List<TrendPoint> get weeklyTrend;

  /// Create a copy of ProgressTrend
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressTrendImplCopyWith<_$ProgressTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrendPoint _$TrendPointFromJson(Map<String, dynamic> json) {
  return _TrendPoint.fromJson(json);
}

/// @nodoc
mixin _$TrendPoint {
  @JsonKey(name: 'WeekStart')
  DateTime get weekStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'WeekEnd')
  DateTime get weekEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalQuestionsAnswered')
  int get totalQuestionsAnswered => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectAnswers')
  int get correctAnswers => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectAnswerRate')
  double get correctAnswerRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'ActiveDays')
  int get activeDays => throw _privateConstructorUsedError;

  /// Serializes this TrendPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrendPointCopyWith<TrendPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrendPointCopyWith<$Res> {
  factory $TrendPointCopyWith(
    TrendPoint value,
    $Res Function(TrendPoint) then,
  ) = _$TrendPointCopyWithImpl<$Res, TrendPoint>;
  @useResult
  $Res call({
    @JsonKey(name: 'WeekStart') DateTime weekStart,
    @JsonKey(name: 'WeekEnd') DateTime weekEnd,
    @JsonKey(name: 'TotalQuestionsAnswered') int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') int correctAnswers,
    @JsonKey(name: 'CorrectAnswerRate') double correctAnswerRate,
    @JsonKey(name: 'ActiveDays') int activeDays,
  });
}

/// @nodoc
class _$TrendPointCopyWithImpl<$Res, $Val extends TrendPoint>
    implements $TrendPointCopyWith<$Res> {
  _$TrendPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? totalQuestionsAnswered = null,
    Object? correctAnswers = null,
    Object? correctAnswerRate = null,
    Object? activeDays = null,
  }) {
    return _then(
      _value.copyWith(
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
            correctAnswerRate: null == correctAnswerRate
                ? _value.correctAnswerRate
                : correctAnswerRate // ignore: cast_nullable_to_non_nullable
                      as double,
            activeDays: null == activeDays
                ? _value.activeDays
                : activeDays // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrendPointImplCopyWith<$Res>
    implements $TrendPointCopyWith<$Res> {
  factory _$$TrendPointImplCopyWith(
    _$TrendPointImpl value,
    $Res Function(_$TrendPointImpl) then,
  ) = __$$TrendPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'WeekStart') DateTime weekStart,
    @JsonKey(name: 'WeekEnd') DateTime weekEnd,
    @JsonKey(name: 'TotalQuestionsAnswered') int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') int correctAnswers,
    @JsonKey(name: 'CorrectAnswerRate') double correctAnswerRate,
    @JsonKey(name: 'ActiveDays') int activeDays,
  });
}

/// @nodoc
class __$$TrendPointImplCopyWithImpl<$Res>
    extends _$TrendPointCopyWithImpl<$Res, _$TrendPointImpl>
    implements _$$TrendPointImplCopyWith<$Res> {
  __$$TrendPointImplCopyWithImpl(
    _$TrendPointImpl _value,
    $Res Function(_$TrendPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? totalQuestionsAnswered = null,
    Object? correctAnswers = null,
    Object? correctAnswerRate = null,
    Object? activeDays = null,
  }) {
    return _then(
      _$TrendPointImpl(
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
        correctAnswerRate: null == correctAnswerRate
            ? _value.correctAnswerRate
            : correctAnswerRate // ignore: cast_nullable_to_non_nullable
                  as double,
        activeDays: null == activeDays
            ? _value.activeDays
            : activeDays // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrendPointImpl implements _TrendPoint {
  const _$TrendPointImpl({
    @JsonKey(name: 'WeekStart') required this.weekStart,
    @JsonKey(name: 'WeekEnd') required this.weekEnd,
    @JsonKey(name: 'TotalQuestionsAnswered')
    required this.totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') required this.correctAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required this.correctAnswerRate,
    @JsonKey(name: 'ActiveDays') required this.activeDays,
  });

  factory _$TrendPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrendPointImplFromJson(json);

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
  @JsonKey(name: 'CorrectAnswerRate')
  final double correctAnswerRate;
  @override
  @JsonKey(name: 'ActiveDays')
  final int activeDays;

  @override
  String toString() {
    return 'TrendPoint(weekStart: $weekStart, weekEnd: $weekEnd, totalQuestionsAnswered: $totalQuestionsAnswered, correctAnswers: $correctAnswers, correctAnswerRate: $correctAnswerRate, activeDays: $activeDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrendPointImpl &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.weekEnd, weekEnd) || other.weekEnd == weekEnd) &&
            (identical(other.totalQuestionsAnswered, totalQuestionsAnswered) ||
                other.totalQuestionsAnswered == totalQuestionsAnswered) &&
            (identical(other.correctAnswers, correctAnswers) ||
                other.correctAnswers == correctAnswers) &&
            (identical(other.correctAnswerRate, correctAnswerRate) ||
                other.correctAnswerRate == correctAnswerRate) &&
            (identical(other.activeDays, activeDays) ||
                other.activeDays == activeDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    weekStart,
    weekEnd,
    totalQuestionsAnswered,
    correctAnswers,
    correctAnswerRate,
    activeDays,
  );

  /// Create a copy of TrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrendPointImplCopyWith<_$TrendPointImpl> get copyWith =>
      __$$TrendPointImplCopyWithImpl<_$TrendPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrendPointImplToJson(this);
  }
}

abstract class _TrendPoint implements TrendPoint {
  const factory _TrendPoint({
    @JsonKey(name: 'WeekStart') required final DateTime weekStart,
    @JsonKey(name: 'WeekEnd') required final DateTime weekEnd,
    @JsonKey(name: 'TotalQuestionsAnswered')
    required final int totalQuestionsAnswered,
    @JsonKey(name: 'CorrectAnswers') required final int correctAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required final double correctAnswerRate,
    @JsonKey(name: 'ActiveDays') required final int activeDays,
  }) = _$TrendPointImpl;

  factory _TrendPoint.fromJson(Map<String, dynamic> json) =
      _$TrendPointImpl.fromJson;

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
  @JsonKey(name: 'CorrectAnswerRate')
  double get correctAnswerRate;
  @override
  @JsonKey(name: 'ActiveDays')
  int get activeDays;

  /// Create a copy of TrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrendPointImplCopyWith<_$TrendPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
