// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submit_answer_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubmitAnswerResponse _$SubmitAnswerResponseFromJson(Map<String, dynamic> json) {
  return _SubmitAnswerResponse.fromJson(json);
}

/// @nodoc
mixin _$SubmitAnswerResponse {
  @JsonKey(name: 'IsCorrect')
  bool get isCorrect => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectAnswer')
  String get correctAnswer => throw _privateConstructorUsedError;
  @JsonKey(name: 'Explanation')
  String? get explanation => throw _privateConstructorUsedError;

  /// Serializes this SubmitAnswerResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubmitAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmitAnswerResponseCopyWith<SubmitAnswerResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmitAnswerResponseCopyWith<$Res> {
  factory $SubmitAnswerResponseCopyWith(
    SubmitAnswerResponse value,
    $Res Function(SubmitAnswerResponse) then,
  ) = _$SubmitAnswerResponseCopyWithImpl<$Res, SubmitAnswerResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'IsCorrect') bool isCorrect,
    @JsonKey(name: 'CorrectAnswer') String correctAnswer,
    @JsonKey(name: 'Explanation') String? explanation,
  });
}

/// @nodoc
class _$SubmitAnswerResponseCopyWithImpl<
  $Res,
  $Val extends SubmitAnswerResponse
>
    implements $SubmitAnswerResponseCopyWith<$Res> {
  _$SubmitAnswerResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubmitAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCorrect = null,
    Object? correctAnswer = null,
    Object? explanation = freezed,
  }) {
    return _then(
      _value.copyWith(
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
            correctAnswer: null == correctAnswer
                ? _value.correctAnswer
                : correctAnswer // ignore: cast_nullable_to_non_nullable
                      as String,
            explanation: freezed == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubmitAnswerResponseImplCopyWith<$Res>
    implements $SubmitAnswerResponseCopyWith<$Res> {
  factory _$$SubmitAnswerResponseImplCopyWith(
    _$SubmitAnswerResponseImpl value,
    $Res Function(_$SubmitAnswerResponseImpl) then,
  ) = __$$SubmitAnswerResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'IsCorrect') bool isCorrect,
    @JsonKey(name: 'CorrectAnswer') String correctAnswer,
    @JsonKey(name: 'Explanation') String? explanation,
  });
}

/// @nodoc
class __$$SubmitAnswerResponseImplCopyWithImpl<$Res>
    extends _$SubmitAnswerResponseCopyWithImpl<$Res, _$SubmitAnswerResponseImpl>
    implements _$$SubmitAnswerResponseImplCopyWith<$Res> {
  __$$SubmitAnswerResponseImplCopyWithImpl(
    _$SubmitAnswerResponseImpl _value,
    $Res Function(_$SubmitAnswerResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubmitAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCorrect = null,
    Object? correctAnswer = null,
    Object? explanation = freezed,
  }) {
    return _then(
      _$SubmitAnswerResponseImpl(
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
        correctAnswer: null == correctAnswer
            ? _value.correctAnswer
            : correctAnswer // ignore: cast_nullable_to_non_nullable
                  as String,
        explanation: freezed == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmitAnswerResponseImpl implements _SubmitAnswerResponse {
  const _$SubmitAnswerResponseImpl({
    @JsonKey(name: 'IsCorrect') required this.isCorrect,
    @JsonKey(name: 'CorrectAnswer') required this.correctAnswer,
    @JsonKey(name: 'Explanation') this.explanation,
  });

  factory _$SubmitAnswerResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubmitAnswerResponseImplFromJson(json);

  @override
  @JsonKey(name: 'IsCorrect')
  final bool isCorrect;
  @override
  @JsonKey(name: 'CorrectAnswer')
  final String correctAnswer;
  @override
  @JsonKey(name: 'Explanation')
  final String? explanation;

  @override
  String toString() {
    return 'SubmitAnswerResponse(isCorrect: $isCorrect, correctAnswer: $correctAnswer, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitAnswerResponseImpl &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, isCorrect, correctAnswer, explanation);

  /// Create a copy of SubmitAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitAnswerResponseImplCopyWith<_$SubmitAnswerResponseImpl>
  get copyWith =>
      __$$SubmitAnswerResponseImplCopyWithImpl<_$SubmitAnswerResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmitAnswerResponseImplToJson(this);
  }
}

abstract class _SubmitAnswerResponse implements SubmitAnswerResponse {
  const factory _SubmitAnswerResponse({
    @JsonKey(name: 'IsCorrect') required final bool isCorrect,
    @JsonKey(name: 'CorrectAnswer') required final String correctAnswer,
    @JsonKey(name: 'Explanation') final String? explanation,
  }) = _$SubmitAnswerResponseImpl;

  factory _SubmitAnswerResponse.fromJson(Map<String, dynamic> json) =
      _$SubmitAnswerResponseImpl.fromJson;

  @override
  @JsonKey(name: 'IsCorrect')
  bool get isCorrect;
  @override
  @JsonKey(name: 'CorrectAnswer')
  String get correctAnswer;
  @override
  @JsonKey(name: 'Explanation')
  String? get explanation;

  /// Create a copy of SubmitAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmitAnswerResponseImplCopyWith<_$SubmitAnswerResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
