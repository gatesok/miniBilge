// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic_performance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TopicPerformance _$TopicPerformanceFromJson(Map<String, dynamic> json) {
  return _TopicPerformance.fromJson(json);
}

/// @nodoc
mixin _$TopicPerformance {
  @JsonKey(name: 'TopicId')
  String get topicId => throw _privateConstructorUsedError;
  @JsonKey(name: 'TopicName')
  String get topicName => throw _privateConstructorUsedError;
  @JsonKey(name: 'SubjectName')
  String get subjectName => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalAttempts')
  int get totalAttempts => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectAttempts')
  int get correctAttempts => throw _privateConstructorUsedError;
  @JsonKey(name: 'SuccessRate')
  double get successRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'AverageTimeSeconds')
  double? get averageTimeSeconds => throw _privateConstructorUsedError;
  @JsonKey(name: 'DistinctDaysPracticed')
  int get distinctDaysPracticed => throw _privateConstructorUsedError;
  @JsonKey(name: 'LastPracticedAt')
  DateTime get lastPracticedAt => throw _privateConstructorUsedError;

  /// Serializes this TopicPerformance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TopicPerformance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopicPerformanceCopyWith<TopicPerformance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopicPerformanceCopyWith<$Res> {
  factory $TopicPerformanceCopyWith(
    TopicPerformance value,
    $Res Function(TopicPerformance) then,
  ) = _$TopicPerformanceCopyWithImpl<$Res, TopicPerformance>;
  @useResult
  $Res call({
    @JsonKey(name: 'TopicId') String topicId,
    @JsonKey(name: 'TopicName') String topicName,
    @JsonKey(name: 'SubjectName') String subjectName,
    @JsonKey(name: 'TotalAttempts') int totalAttempts,
    @JsonKey(name: 'CorrectAttempts') int correctAttempts,
    @JsonKey(name: 'SuccessRate') double successRate,
    @JsonKey(name: 'AverageTimeSeconds') double? averageTimeSeconds,
    @JsonKey(name: 'DistinctDaysPracticed') int distinctDaysPracticed,
    @JsonKey(name: 'LastPracticedAt') DateTime lastPracticedAt,
  });
}

/// @nodoc
class _$TopicPerformanceCopyWithImpl<$Res, $Val extends TopicPerformance>
    implements $TopicPerformanceCopyWith<$Res> {
  _$TopicPerformanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopicPerformance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicId = null,
    Object? topicName = null,
    Object? subjectName = null,
    Object? totalAttempts = null,
    Object? correctAttempts = null,
    Object? successRate = null,
    Object? averageTimeSeconds = freezed,
    Object? distinctDaysPracticed = null,
    Object? lastPracticedAt = null,
  }) {
    return _then(
      _value.copyWith(
            topicId: null == topicId
                ? _value.topicId
                : topicId // ignore: cast_nullable_to_non_nullable
                      as String,
            topicName: null == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String,
            subjectName: null == subjectName
                ? _value.subjectName
                : subjectName // ignore: cast_nullable_to_non_nullable
                      as String,
            totalAttempts: null == totalAttempts
                ? _value.totalAttempts
                : totalAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            correctAttempts: null == correctAttempts
                ? _value.correctAttempts
                : correctAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            successRate: null == successRate
                ? _value.successRate
                : successRate // ignore: cast_nullable_to_non_nullable
                      as double,
            averageTimeSeconds: freezed == averageTimeSeconds
                ? _value.averageTimeSeconds
                : averageTimeSeconds // ignore: cast_nullable_to_non_nullable
                      as double?,
            distinctDaysPracticed: null == distinctDaysPracticed
                ? _value.distinctDaysPracticed
                : distinctDaysPracticed // ignore: cast_nullable_to_non_nullable
                      as int,
            lastPracticedAt: null == lastPracticedAt
                ? _value.lastPracticedAt
                : lastPracticedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TopicPerformanceImplCopyWith<$Res>
    implements $TopicPerformanceCopyWith<$Res> {
  factory _$$TopicPerformanceImplCopyWith(
    _$TopicPerformanceImpl value,
    $Res Function(_$TopicPerformanceImpl) then,
  ) = __$$TopicPerformanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'TopicId') String topicId,
    @JsonKey(name: 'TopicName') String topicName,
    @JsonKey(name: 'SubjectName') String subjectName,
    @JsonKey(name: 'TotalAttempts') int totalAttempts,
    @JsonKey(name: 'CorrectAttempts') int correctAttempts,
    @JsonKey(name: 'SuccessRate') double successRate,
    @JsonKey(name: 'AverageTimeSeconds') double? averageTimeSeconds,
    @JsonKey(name: 'DistinctDaysPracticed') int distinctDaysPracticed,
    @JsonKey(name: 'LastPracticedAt') DateTime lastPracticedAt,
  });
}

/// @nodoc
class __$$TopicPerformanceImplCopyWithImpl<$Res>
    extends _$TopicPerformanceCopyWithImpl<$Res, _$TopicPerformanceImpl>
    implements _$$TopicPerformanceImplCopyWith<$Res> {
  __$$TopicPerformanceImplCopyWithImpl(
    _$TopicPerformanceImpl _value,
    $Res Function(_$TopicPerformanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TopicPerformance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicId = null,
    Object? topicName = null,
    Object? subjectName = null,
    Object? totalAttempts = null,
    Object? correctAttempts = null,
    Object? successRate = null,
    Object? averageTimeSeconds = freezed,
    Object? distinctDaysPracticed = null,
    Object? lastPracticedAt = null,
  }) {
    return _then(
      _$TopicPerformanceImpl(
        topicId: null == topicId
            ? _value.topicId
            : topicId // ignore: cast_nullable_to_non_nullable
                  as String,
        topicName: null == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String,
        subjectName: null == subjectName
            ? _value.subjectName
            : subjectName // ignore: cast_nullable_to_non_nullable
                  as String,
        totalAttempts: null == totalAttempts
            ? _value.totalAttempts
            : totalAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        correctAttempts: null == correctAttempts
            ? _value.correctAttempts
            : correctAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        successRate: null == successRate
            ? _value.successRate
            : successRate // ignore: cast_nullable_to_non_nullable
                  as double,
        averageTimeSeconds: freezed == averageTimeSeconds
            ? _value.averageTimeSeconds
            : averageTimeSeconds // ignore: cast_nullable_to_non_nullable
                  as double?,
        distinctDaysPracticed: null == distinctDaysPracticed
            ? _value.distinctDaysPracticed
            : distinctDaysPracticed // ignore: cast_nullable_to_non_nullable
                  as int,
        lastPracticedAt: null == lastPracticedAt
            ? _value.lastPracticedAt
            : lastPracticedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TopicPerformanceImpl implements _TopicPerformance {
  const _$TopicPerformanceImpl({
    @JsonKey(name: 'TopicId') required this.topicId,
    @JsonKey(name: 'TopicName') required this.topicName,
    @JsonKey(name: 'SubjectName') required this.subjectName,
    @JsonKey(name: 'TotalAttempts') required this.totalAttempts,
    @JsonKey(name: 'CorrectAttempts') required this.correctAttempts,
    @JsonKey(name: 'SuccessRate') required this.successRate,
    @JsonKey(name: 'AverageTimeSeconds') this.averageTimeSeconds,
    @JsonKey(name: 'DistinctDaysPracticed') required this.distinctDaysPracticed,
    @JsonKey(name: 'LastPracticedAt') required this.lastPracticedAt,
  });

  factory _$TopicPerformanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopicPerformanceImplFromJson(json);

  @override
  @JsonKey(name: 'TopicId')
  final String topicId;
  @override
  @JsonKey(name: 'TopicName')
  final String topicName;
  @override
  @JsonKey(name: 'SubjectName')
  final String subjectName;
  @override
  @JsonKey(name: 'TotalAttempts')
  final int totalAttempts;
  @override
  @JsonKey(name: 'CorrectAttempts')
  final int correctAttempts;
  @override
  @JsonKey(name: 'SuccessRate')
  final double successRate;
  @override
  @JsonKey(name: 'AverageTimeSeconds')
  final double? averageTimeSeconds;
  @override
  @JsonKey(name: 'DistinctDaysPracticed')
  final int distinctDaysPracticed;
  @override
  @JsonKey(name: 'LastPracticedAt')
  final DateTime lastPracticedAt;

  @override
  String toString() {
    return 'TopicPerformance(topicId: $topicId, topicName: $topicName, subjectName: $subjectName, totalAttempts: $totalAttempts, correctAttempts: $correctAttempts, successRate: $successRate, averageTimeSeconds: $averageTimeSeconds, distinctDaysPracticed: $distinctDaysPracticed, lastPracticedAt: $lastPracticedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopicPerformanceImpl &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.totalAttempts, totalAttempts) ||
                other.totalAttempts == totalAttempts) &&
            (identical(other.correctAttempts, correctAttempts) ||
                other.correctAttempts == correctAttempts) &&
            (identical(other.successRate, successRate) ||
                other.successRate == successRate) &&
            (identical(other.averageTimeSeconds, averageTimeSeconds) ||
                other.averageTimeSeconds == averageTimeSeconds) &&
            (identical(other.distinctDaysPracticed, distinctDaysPracticed) ||
                other.distinctDaysPracticed == distinctDaysPracticed) &&
            (identical(other.lastPracticedAt, lastPracticedAt) ||
                other.lastPracticedAt == lastPracticedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    topicId,
    topicName,
    subjectName,
    totalAttempts,
    correctAttempts,
    successRate,
    averageTimeSeconds,
    distinctDaysPracticed,
    lastPracticedAt,
  );

  /// Create a copy of TopicPerformance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopicPerformanceImplCopyWith<_$TopicPerformanceImpl> get copyWith =>
      __$$TopicPerformanceImplCopyWithImpl<_$TopicPerformanceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TopicPerformanceImplToJson(this);
  }
}

abstract class _TopicPerformance implements TopicPerformance {
  const factory _TopicPerformance({
    @JsonKey(name: 'TopicId') required final String topicId,
    @JsonKey(name: 'TopicName') required final String topicName,
    @JsonKey(name: 'SubjectName') required final String subjectName,
    @JsonKey(name: 'TotalAttempts') required final int totalAttempts,
    @JsonKey(name: 'CorrectAttempts') required final int correctAttempts,
    @JsonKey(name: 'SuccessRate') required final double successRate,
    @JsonKey(name: 'AverageTimeSeconds') final double? averageTimeSeconds,
    @JsonKey(name: 'DistinctDaysPracticed')
    required final int distinctDaysPracticed,
    @JsonKey(name: 'LastPracticedAt') required final DateTime lastPracticedAt,
  }) = _$TopicPerformanceImpl;

  factory _TopicPerformance.fromJson(Map<String, dynamic> json) =
      _$TopicPerformanceImpl.fromJson;

  @override
  @JsonKey(name: 'TopicId')
  String get topicId;
  @override
  @JsonKey(name: 'TopicName')
  String get topicName;
  @override
  @JsonKey(name: 'SubjectName')
  String get subjectName;
  @override
  @JsonKey(name: 'TotalAttempts')
  int get totalAttempts;
  @override
  @JsonKey(name: 'CorrectAttempts')
  int get correctAttempts;
  @override
  @JsonKey(name: 'SuccessRate')
  double get successRate;
  @override
  @JsonKey(name: 'AverageTimeSeconds')
  double? get averageTimeSeconds;
  @override
  @JsonKey(name: 'DistinctDaysPracticed')
  int get distinctDaysPracticed;
  @override
  @JsonKey(name: 'LastPracticedAt')
  DateTime get lastPracticedAt;

  /// Create a copy of TopicPerformance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopicPerformanceImplCopyWith<_$TopicPerformanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
