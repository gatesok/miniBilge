// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'save_answer_attempt_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SaveAnswerAttemptRequest _$SaveAnswerAttemptRequestFromJson(
    Map<String, dynamic> json) {
  return _SaveAnswerAttemptRequest.fromJson(json);
}

/// @nodoc
mixin _$SaveAnswerAttemptRequest {
  @JsonKey(name: 'ChildId')
  String get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'QuestionId')
  String get questionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'SubmittedAnswer')
  String get submittedAnswer => throw _privateConstructorUsedError;
  @JsonKey(name: 'IsCorrect')
  bool get isCorrect => throw _privateConstructorUsedError;
  @JsonKey(name: 'TimeTakenSeconds')
  int? get timeTakenSeconds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SaveAnswerAttemptRequestCopyWith<SaveAnswerAttemptRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaveAnswerAttemptRequestCopyWith<$Res> {
  factory $SaveAnswerAttemptRequestCopyWith(SaveAnswerAttemptRequest value,
          $Res Function(SaveAnswerAttemptRequest) then) =
      _$SaveAnswerAttemptRequestCopyWithImpl<$Res, SaveAnswerAttemptRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'ChildId') String childId,
      @JsonKey(name: 'QuestionId') String questionId,
      @JsonKey(name: 'SubmittedAnswer') String submittedAnswer,
      @JsonKey(name: 'IsCorrect') bool isCorrect,
      @JsonKey(name: 'TimeTakenSeconds') int? timeTakenSeconds});
}

/// @nodoc
class _$SaveAnswerAttemptRequestCopyWithImpl<$Res,
        $Val extends SaveAnswerAttemptRequest>
    implements $SaveAnswerAttemptRequestCopyWith<$Res> {
  _$SaveAnswerAttemptRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? questionId = null,
    Object? submittedAnswer = null,
    Object? isCorrect = null,
    Object? timeTakenSeconds = freezed,
  }) {
    return _then(_value.copyWith(
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      submittedAnswer: null == submittedAnswer
          ? _value.submittedAnswer
          : submittedAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      timeTakenSeconds: freezed == timeTakenSeconds
          ? _value.timeTakenSeconds
          : timeTakenSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SaveAnswerAttemptRequestImplCopyWith<$Res>
    implements $SaveAnswerAttemptRequestCopyWith<$Res> {
  factory _$$SaveAnswerAttemptRequestImplCopyWith(
          _$SaveAnswerAttemptRequestImpl value,
          $Res Function(_$SaveAnswerAttemptRequestImpl) then) =
      __$$SaveAnswerAttemptRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'ChildId') String childId,
      @JsonKey(name: 'QuestionId') String questionId,
      @JsonKey(name: 'SubmittedAnswer') String submittedAnswer,
      @JsonKey(name: 'IsCorrect') bool isCorrect,
      @JsonKey(name: 'TimeTakenSeconds') int? timeTakenSeconds});
}

/// @nodoc
class __$$SaveAnswerAttemptRequestImplCopyWithImpl<$Res>
    extends _$SaveAnswerAttemptRequestCopyWithImpl<$Res,
        _$SaveAnswerAttemptRequestImpl>
    implements _$$SaveAnswerAttemptRequestImplCopyWith<$Res> {
  __$$SaveAnswerAttemptRequestImplCopyWithImpl(
      _$SaveAnswerAttemptRequestImpl _value,
      $Res Function(_$SaveAnswerAttemptRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? questionId = null,
    Object? submittedAnswer = null,
    Object? isCorrect = null,
    Object? timeTakenSeconds = freezed,
  }) {
    return _then(_$SaveAnswerAttemptRequestImpl(
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      submittedAnswer: null == submittedAnswer
          ? _value.submittedAnswer
          : submittedAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      timeTakenSeconds: freezed == timeTakenSeconds
          ? _value.timeTakenSeconds
          : timeTakenSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SaveAnswerAttemptRequestImpl implements _SaveAnswerAttemptRequest {
  const _$SaveAnswerAttemptRequestImpl(
      {@JsonKey(name: 'ChildId') required this.childId,
      @JsonKey(name: 'QuestionId') required this.questionId,
      @JsonKey(name: 'SubmittedAnswer') required this.submittedAnswer,
      @JsonKey(name: 'IsCorrect') required this.isCorrect,
      @JsonKey(name: 'TimeTakenSeconds') this.timeTakenSeconds});

  factory _$SaveAnswerAttemptRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaveAnswerAttemptRequestImplFromJson(json);

  @override
  @JsonKey(name: 'ChildId')
  final String childId;
  @override
  @JsonKey(name: 'QuestionId')
  final String questionId;
  @override
  @JsonKey(name: 'SubmittedAnswer')
  final String submittedAnswer;
  @override
  @JsonKey(name: 'IsCorrect')
  final bool isCorrect;
  @override
  @JsonKey(name: 'TimeTakenSeconds')
  final int? timeTakenSeconds;

  @override
  String toString() {
    return 'SaveAnswerAttemptRequest(childId: $childId, questionId: $questionId, submittedAnswer: $submittedAnswer, isCorrect: $isCorrect, timeTakenSeconds: $timeTakenSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaveAnswerAttemptRequestImpl &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.submittedAnswer, submittedAnswer) ||
                other.submittedAnswer == submittedAnswer) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.timeTakenSeconds, timeTakenSeconds) ||
                other.timeTakenSeconds == timeTakenSeconds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, childId, questionId,
      submittedAnswer, isCorrect, timeTakenSeconds);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SaveAnswerAttemptRequestImplCopyWith<_$SaveAnswerAttemptRequestImpl>
      get copyWith => __$$SaveAnswerAttemptRequestImplCopyWithImpl<
          _$SaveAnswerAttemptRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaveAnswerAttemptRequestImplToJson(
      this,
    );
  }
}

abstract class _SaveAnswerAttemptRequest implements SaveAnswerAttemptRequest {
  const factory _SaveAnswerAttemptRequest(
      {@JsonKey(name: 'ChildId') required final String childId,
      @JsonKey(name: 'QuestionId') required final String questionId,
      @JsonKey(name: 'SubmittedAnswer') required final String submittedAnswer,
      @JsonKey(name: 'IsCorrect') required final bool isCorrect,
      @JsonKey(name: 'TimeTakenSeconds')
      final int? timeTakenSeconds}) = _$SaveAnswerAttemptRequestImpl;

  factory _SaveAnswerAttemptRequest.fromJson(Map<String, dynamic> json) =
      _$SaveAnswerAttemptRequestImpl.fromJson;

  @override
  @JsonKey(name: 'ChildId')
  String get childId;
  @override
  @JsonKey(name: 'QuestionId')
  String get questionId;
  @override
  @JsonKey(name: 'SubmittedAnswer')
  String get submittedAnswer;
  @override
  @JsonKey(name: 'IsCorrect')
  bool get isCorrect;
  @override
  @JsonKey(name: 'TimeTakenSeconds')
  int? get timeTakenSeconds;
  @override
  @JsonKey(ignore: true)
  _$$SaveAnswerAttemptRequestImplCopyWith<_$SaveAnswerAttemptRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
