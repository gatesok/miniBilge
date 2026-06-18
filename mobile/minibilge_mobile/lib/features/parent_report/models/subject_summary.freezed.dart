// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subject_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubjectSummary _$SubjectSummaryFromJson(Map<String, dynamic> json) {
  return _SubjectSummary.fromJson(json);
}

/// @nodoc
mixin _$SubjectSummary {
  @JsonKey(name: 'SubjectName')
  String get subjectName => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalQuestions')
  int get totalQuestions => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectAnswers')
  int get correctAnswers => throw _privateConstructorUsedError;
  @JsonKey(name: 'WrongAnswers')
  int get wrongAnswers => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectAnswerRate')
  double get correctAnswerRate => throw _privateConstructorUsedError;

  /// Serializes this SubjectSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubjectSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubjectSummaryCopyWith<SubjectSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubjectSummaryCopyWith<$Res> {
  factory $SubjectSummaryCopyWith(
    SubjectSummary value,
    $Res Function(SubjectSummary) then,
  ) = _$SubjectSummaryCopyWithImpl<$Res, SubjectSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'SubjectName') String subjectName,
    @JsonKey(name: 'TotalQuestions') int totalQuestions,
    @JsonKey(name: 'CorrectAnswers') int correctAnswers,
    @JsonKey(name: 'WrongAnswers') int wrongAnswers,
    @JsonKey(name: 'CorrectAnswerRate') double correctAnswerRate,
  });
}

/// @nodoc
class _$SubjectSummaryCopyWithImpl<$Res, $Val extends SubjectSummary>
    implements $SubjectSummaryCopyWith<$Res> {
  _$SubjectSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubjectSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectName = null,
    Object? totalQuestions = null,
    Object? correctAnswers = null,
    Object? wrongAnswers = null,
    Object? correctAnswerRate = null,
  }) {
    return _then(
      _value.copyWith(
            subjectName: null == subjectName
                ? _value.subjectName
                : subjectName // ignore: cast_nullable_to_non_nullable
                      as String,
            totalQuestions: null == totalQuestions
                ? _value.totalQuestions
                : totalQuestions // ignore: cast_nullable_to_non_nullable
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubjectSummaryImplCopyWith<$Res>
    implements $SubjectSummaryCopyWith<$Res> {
  factory _$$SubjectSummaryImplCopyWith(
    _$SubjectSummaryImpl value,
    $Res Function(_$SubjectSummaryImpl) then,
  ) = __$$SubjectSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'SubjectName') String subjectName,
    @JsonKey(name: 'TotalQuestions') int totalQuestions,
    @JsonKey(name: 'CorrectAnswers') int correctAnswers,
    @JsonKey(name: 'WrongAnswers') int wrongAnswers,
    @JsonKey(name: 'CorrectAnswerRate') double correctAnswerRate,
  });
}

/// @nodoc
class __$$SubjectSummaryImplCopyWithImpl<$Res>
    extends _$SubjectSummaryCopyWithImpl<$Res, _$SubjectSummaryImpl>
    implements _$$SubjectSummaryImplCopyWith<$Res> {
  __$$SubjectSummaryImplCopyWithImpl(
    _$SubjectSummaryImpl _value,
    $Res Function(_$SubjectSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubjectSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectName = null,
    Object? totalQuestions = null,
    Object? correctAnswers = null,
    Object? wrongAnswers = null,
    Object? correctAnswerRate = null,
  }) {
    return _then(
      _$SubjectSummaryImpl(
        subjectName: null == subjectName
            ? _value.subjectName
            : subjectName // ignore: cast_nullable_to_non_nullable
                  as String,
        totalQuestions: null == totalQuestions
            ? _value.totalQuestions
            : totalQuestions // ignore: cast_nullable_to_non_nullable
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubjectSummaryImpl implements _SubjectSummary {
  const _$SubjectSummaryImpl({
    @JsonKey(name: 'SubjectName') required this.subjectName,
    @JsonKey(name: 'TotalQuestions') required this.totalQuestions,
    @JsonKey(name: 'CorrectAnswers') required this.correctAnswers,
    @JsonKey(name: 'WrongAnswers') required this.wrongAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required this.correctAnswerRate,
  });

  factory _$SubjectSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubjectSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'SubjectName')
  final String subjectName;
  @override
  @JsonKey(name: 'TotalQuestions')
  final int totalQuestions;
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
  String toString() {
    return 'SubjectSummary(subjectName: $subjectName, totalQuestions: $totalQuestions, correctAnswers: $correctAnswers, wrongAnswers: $wrongAnswers, correctAnswerRate: $correctAnswerRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubjectSummaryImpl &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.correctAnswers, correctAnswers) ||
                other.correctAnswers == correctAnswers) &&
            (identical(other.wrongAnswers, wrongAnswers) ||
                other.wrongAnswers == wrongAnswers) &&
            (identical(other.correctAnswerRate, correctAnswerRate) ||
                other.correctAnswerRate == correctAnswerRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    subjectName,
    totalQuestions,
    correctAnswers,
    wrongAnswers,
    correctAnswerRate,
  );

  /// Create a copy of SubjectSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubjectSummaryImplCopyWith<_$SubjectSummaryImpl> get copyWith =>
      __$$SubjectSummaryImplCopyWithImpl<_$SubjectSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubjectSummaryImplToJson(this);
  }
}

abstract class _SubjectSummary implements SubjectSummary {
  const factory _SubjectSummary({
    @JsonKey(name: 'SubjectName') required final String subjectName,
    @JsonKey(name: 'TotalQuestions') required final int totalQuestions,
    @JsonKey(name: 'CorrectAnswers') required final int correctAnswers,
    @JsonKey(name: 'WrongAnswers') required final int wrongAnswers,
    @JsonKey(name: 'CorrectAnswerRate') required final double correctAnswerRate,
  }) = _$SubjectSummaryImpl;

  factory _SubjectSummary.fromJson(Map<String, dynamic> json) =
      _$SubjectSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'SubjectName')
  String get subjectName;
  @override
  @JsonKey(name: 'TotalQuestions')
  int get totalQuestions;
  @override
  @JsonKey(name: 'CorrectAnswers')
  int get correctAnswers;
  @override
  @JsonKey(name: 'WrongAnswers')
  int get wrongAnswers;
  @override
  @JsonKey(name: 'CorrectAnswerRate')
  double get correctAnswerRate;

  /// Create a copy of SubjectSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubjectSummaryImplCopyWith<_$SubjectSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
