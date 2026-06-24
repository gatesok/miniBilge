// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'writing_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WritingPrompt _$WritingPromptFromJson(Map<String, dynamic> json) {
  return _WritingPrompt.fromJson(json);
}

/// @nodoc
mixin _$WritingPrompt {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'PromptText')
  String get promptText => throw _privateConstructorUsedError;
  @JsonKey(name: 'Context')
  String? get context => throw _privateConstructorUsedError;

  /// Serializes this WritingPrompt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WritingPrompt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WritingPromptCopyWith<WritingPrompt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WritingPromptCopyWith<$Res> {
  factory $WritingPromptCopyWith(
    WritingPrompt value,
    $Res Function(WritingPrompt) then,
  ) = _$WritingPromptCopyWithImpl<$Res, WritingPrompt>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'PromptText') String promptText,
    @JsonKey(name: 'Context') String? context,
  });
}

/// @nodoc
class _$WritingPromptCopyWithImpl<$Res, $Val extends WritingPrompt>
    implements $WritingPromptCopyWith<$Res> {
  _$WritingPromptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WritingPrompt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? promptText = null,
    Object? context = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            promptText: null == promptText
                ? _value.promptText
                : promptText // ignore: cast_nullable_to_non_nullable
                      as String,
            context: freezed == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WritingPromptImplCopyWith<$Res>
    implements $WritingPromptCopyWith<$Res> {
  factory _$$WritingPromptImplCopyWith(
    _$WritingPromptImpl value,
    $Res Function(_$WritingPromptImpl) then,
  ) = __$$WritingPromptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'PromptText') String promptText,
    @JsonKey(name: 'Context') String? context,
  });
}

/// @nodoc
class __$$WritingPromptImplCopyWithImpl<$Res>
    extends _$WritingPromptCopyWithImpl<$Res, _$WritingPromptImpl>
    implements _$$WritingPromptImplCopyWith<$Res> {
  __$$WritingPromptImplCopyWithImpl(
    _$WritingPromptImpl _value,
    $Res Function(_$WritingPromptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WritingPrompt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? promptText = null,
    Object? context = freezed,
  }) {
    return _then(
      _$WritingPromptImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        promptText: null == promptText
            ? _value.promptText
            : promptText // ignore: cast_nullable_to_non_nullable
                  as String,
        context: freezed == context
            ? _value.context
            : context // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WritingPromptImpl implements _WritingPrompt {
  const _$WritingPromptImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'PromptText') required this.promptText,
    @JsonKey(name: 'Context') this.context,
  });

  factory _$WritingPromptImpl.fromJson(Map<String, dynamic> json) =>
      _$$WritingPromptImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'PromptText')
  final String promptText;
  @override
  @JsonKey(name: 'Context')
  final String? context;

  @override
  String toString() {
    return 'WritingPrompt(id: $id, promptText: $promptText, context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WritingPromptImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.promptText, promptText) ||
                other.promptText == promptText) &&
            (identical(other.context, context) || other.context == context));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, promptText, context);

  /// Create a copy of WritingPrompt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WritingPromptImplCopyWith<_$WritingPromptImpl> get copyWith =>
      __$$WritingPromptImplCopyWithImpl<_$WritingPromptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WritingPromptImplToJson(this);
  }
}

abstract class _WritingPrompt implements WritingPrompt {
  const factory _WritingPrompt({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'PromptText') required final String promptText,
    @JsonKey(name: 'Context') final String? context,
  }) = _$WritingPromptImpl;

  factory _WritingPrompt.fromJson(Map<String, dynamic> json) =
      _$WritingPromptImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'PromptText')
  String get promptText;
  @override
  @JsonKey(name: 'Context')
  String? get context;

  /// Create a copy of WritingPrompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WritingPromptImplCopyWith<_$WritingPromptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WritingCorrection _$WritingCorrectionFromJson(Map<String, dynamic> json) {
  return _WritingCorrection.fromJson(json);
}

/// @nodoc
mixin _$WritingCorrection {
  @JsonKey(name: 'Original')
  String get original => throw _privateConstructorUsedError;
  @JsonKey(name: 'Suggestion')
  String get suggestion => throw _privateConstructorUsedError;
  @JsonKey(name: 'Explanation')
  String get explanation => throw _privateConstructorUsedError;

  /// Serializes this WritingCorrection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WritingCorrection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WritingCorrectionCopyWith<WritingCorrection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WritingCorrectionCopyWith<$Res> {
  factory $WritingCorrectionCopyWith(
    WritingCorrection value,
    $Res Function(WritingCorrection) then,
  ) = _$WritingCorrectionCopyWithImpl<$Res, WritingCorrection>;
  @useResult
  $Res call({
    @JsonKey(name: 'Original') String original,
    @JsonKey(name: 'Suggestion') String suggestion,
    @JsonKey(name: 'Explanation') String explanation,
  });
}

/// @nodoc
class _$WritingCorrectionCopyWithImpl<$Res, $Val extends WritingCorrection>
    implements $WritingCorrectionCopyWith<$Res> {
  _$WritingCorrectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WritingCorrection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? original = null,
    Object? suggestion = null,
    Object? explanation = null,
  }) {
    return _then(
      _value.copyWith(
            original: null == original
                ? _value.original
                : original // ignore: cast_nullable_to_non_nullable
                      as String,
            suggestion: null == suggestion
                ? _value.suggestion
                : suggestion // ignore: cast_nullable_to_non_nullable
                      as String,
            explanation: null == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WritingCorrectionImplCopyWith<$Res>
    implements $WritingCorrectionCopyWith<$Res> {
  factory _$$WritingCorrectionImplCopyWith(
    _$WritingCorrectionImpl value,
    $Res Function(_$WritingCorrectionImpl) then,
  ) = __$$WritingCorrectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Original') String original,
    @JsonKey(name: 'Suggestion') String suggestion,
    @JsonKey(name: 'Explanation') String explanation,
  });
}

/// @nodoc
class __$$WritingCorrectionImplCopyWithImpl<$Res>
    extends _$WritingCorrectionCopyWithImpl<$Res, _$WritingCorrectionImpl>
    implements _$$WritingCorrectionImplCopyWith<$Res> {
  __$$WritingCorrectionImplCopyWithImpl(
    _$WritingCorrectionImpl _value,
    $Res Function(_$WritingCorrectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WritingCorrection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? original = null,
    Object? suggestion = null,
    Object? explanation = null,
  }) {
    return _then(
      _$WritingCorrectionImpl(
        original: null == original
            ? _value.original
            : original // ignore: cast_nullable_to_non_nullable
                  as String,
        suggestion: null == suggestion
            ? _value.suggestion
            : suggestion // ignore: cast_nullable_to_non_nullable
                  as String,
        explanation: null == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WritingCorrectionImpl implements _WritingCorrection {
  const _$WritingCorrectionImpl({
    @JsonKey(name: 'Original') required this.original,
    @JsonKey(name: 'Suggestion') required this.suggestion,
    @JsonKey(name: 'Explanation') required this.explanation,
  });

  factory _$WritingCorrectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WritingCorrectionImplFromJson(json);

  @override
  @JsonKey(name: 'Original')
  final String original;
  @override
  @JsonKey(name: 'Suggestion')
  final String suggestion;
  @override
  @JsonKey(name: 'Explanation')
  final String explanation;

  @override
  String toString() {
    return 'WritingCorrection(original: $original, suggestion: $suggestion, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WritingCorrectionImpl &&
            (identical(other.original, original) ||
                other.original == original) &&
            (identical(other.suggestion, suggestion) ||
                other.suggestion == suggestion) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, original, suggestion, explanation);

  /// Create a copy of WritingCorrection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WritingCorrectionImplCopyWith<_$WritingCorrectionImpl> get copyWith =>
      __$$WritingCorrectionImplCopyWithImpl<_$WritingCorrectionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WritingCorrectionImplToJson(this);
  }
}

abstract class _WritingCorrection implements WritingCorrection {
  const factory _WritingCorrection({
    @JsonKey(name: 'Original') required final String original,
    @JsonKey(name: 'Suggestion') required final String suggestion,
    @JsonKey(name: 'Explanation') required final String explanation,
  }) = _$WritingCorrectionImpl;

  factory _WritingCorrection.fromJson(Map<String, dynamic> json) =
      _$WritingCorrectionImpl.fromJson;

  @override
  @JsonKey(name: 'Original')
  String get original;
  @override
  @JsonKey(name: 'Suggestion')
  String get suggestion;
  @override
  @JsonKey(name: 'Explanation')
  String get explanation;

  /// Create a copy of WritingCorrection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WritingCorrectionImplCopyWith<_$WritingCorrectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WritingEvaluationResult _$WritingEvaluationResultFromJson(
  Map<String, dynamic> json,
) {
  return _WritingEvaluationResult.fromJson(json);
}

/// @nodoc
mixin _$WritingEvaluationResult {
  @JsonKey(name: 'Score')
  int get score => throw _privateConstructorUsedError;
  @JsonKey(name: 'Corrections')
  List<WritingCorrection> get corrections => throw _privateConstructorUsedError;
  @JsonKey(name: 'Feedback')
  String get feedback => throw _privateConstructorUsedError;
  @JsonKey(name: 'CoinsEarned')
  int get coinsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'StarsEarned')
  int get starsEarned => throw _privateConstructorUsedError;

  /// Serializes this WritingEvaluationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WritingEvaluationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WritingEvaluationResultCopyWith<WritingEvaluationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WritingEvaluationResultCopyWith<$Res> {
  factory $WritingEvaluationResultCopyWith(
    WritingEvaluationResult value,
    $Res Function(WritingEvaluationResult) then,
  ) = _$WritingEvaluationResultCopyWithImpl<$Res, WritingEvaluationResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'Score') int score,
    @JsonKey(name: 'Corrections') List<WritingCorrection> corrections,
    @JsonKey(name: 'Feedback') String feedback,
    @JsonKey(name: 'CoinsEarned') int coinsEarned,
    @JsonKey(name: 'StarsEarned') int starsEarned,
  });
}

/// @nodoc
class _$WritingEvaluationResultCopyWithImpl<
  $Res,
  $Val extends WritingEvaluationResult
>
    implements $WritingEvaluationResultCopyWith<$Res> {
  _$WritingEvaluationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WritingEvaluationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? corrections = null,
    Object? feedback = null,
    Object? coinsEarned = null,
    Object? starsEarned = null,
  }) {
    return _then(
      _value.copyWith(
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            corrections: null == corrections
                ? _value.corrections
                : corrections // ignore: cast_nullable_to_non_nullable
                      as List<WritingCorrection>,
            feedback: null == feedback
                ? _value.feedback
                : feedback // ignore: cast_nullable_to_non_nullable
                      as String,
            coinsEarned: null == coinsEarned
                ? _value.coinsEarned
                : coinsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
            starsEarned: null == starsEarned
                ? _value.starsEarned
                : starsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WritingEvaluationResultImplCopyWith<$Res>
    implements $WritingEvaluationResultCopyWith<$Res> {
  factory _$$WritingEvaluationResultImplCopyWith(
    _$WritingEvaluationResultImpl value,
    $Res Function(_$WritingEvaluationResultImpl) then,
  ) = __$$WritingEvaluationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Score') int score,
    @JsonKey(name: 'Corrections') List<WritingCorrection> corrections,
    @JsonKey(name: 'Feedback') String feedback,
    @JsonKey(name: 'CoinsEarned') int coinsEarned,
    @JsonKey(name: 'StarsEarned') int starsEarned,
  });
}

/// @nodoc
class __$$WritingEvaluationResultImplCopyWithImpl<$Res>
    extends
        _$WritingEvaluationResultCopyWithImpl<
          $Res,
          _$WritingEvaluationResultImpl
        >
    implements _$$WritingEvaluationResultImplCopyWith<$Res> {
  __$$WritingEvaluationResultImplCopyWithImpl(
    _$WritingEvaluationResultImpl _value,
    $Res Function(_$WritingEvaluationResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WritingEvaluationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? corrections = null,
    Object? feedback = null,
    Object? coinsEarned = null,
    Object? starsEarned = null,
  }) {
    return _then(
      _$WritingEvaluationResultImpl(
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        corrections: null == corrections
            ? _value._corrections
            : corrections // ignore: cast_nullable_to_non_nullable
                  as List<WritingCorrection>,
        feedback: null == feedback
            ? _value.feedback
            : feedback // ignore: cast_nullable_to_non_nullable
                  as String,
        coinsEarned: null == coinsEarned
            ? _value.coinsEarned
            : coinsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
        starsEarned: null == starsEarned
            ? _value.starsEarned
            : starsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WritingEvaluationResultImpl implements _WritingEvaluationResult {
  const _$WritingEvaluationResultImpl({
    @JsonKey(name: 'Score') required this.score,
    @JsonKey(name: 'Corrections')
    required final List<WritingCorrection> corrections,
    @JsonKey(name: 'Feedback') required this.feedback,
    @JsonKey(name: 'CoinsEarned') required this.coinsEarned,
    @JsonKey(name: 'StarsEarned') required this.starsEarned,
  }) : _corrections = corrections;

  factory _$WritingEvaluationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$WritingEvaluationResultImplFromJson(json);

  @override
  @JsonKey(name: 'Score')
  final int score;
  final List<WritingCorrection> _corrections;
  @override
  @JsonKey(name: 'Corrections')
  List<WritingCorrection> get corrections {
    if (_corrections is EqualUnmodifiableListView) return _corrections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_corrections);
  }

  @override
  @JsonKey(name: 'Feedback')
  final String feedback;
  @override
  @JsonKey(name: 'CoinsEarned')
  final int coinsEarned;
  @override
  @JsonKey(name: 'StarsEarned')
  final int starsEarned;

  @override
  String toString() {
    return 'WritingEvaluationResult(score: $score, corrections: $corrections, feedback: $feedback, coinsEarned: $coinsEarned, starsEarned: $starsEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WritingEvaluationResultImpl &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality().equals(
              other._corrections,
              _corrections,
            ) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback) &&
            (identical(other.coinsEarned, coinsEarned) ||
                other.coinsEarned == coinsEarned) &&
            (identical(other.starsEarned, starsEarned) ||
                other.starsEarned == starsEarned));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    score,
    const DeepCollectionEquality().hash(_corrections),
    feedback,
    coinsEarned,
    starsEarned,
  );

  /// Create a copy of WritingEvaluationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WritingEvaluationResultImplCopyWith<_$WritingEvaluationResultImpl>
  get copyWith =>
      __$$WritingEvaluationResultImplCopyWithImpl<
        _$WritingEvaluationResultImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WritingEvaluationResultImplToJson(this);
  }
}

abstract class _WritingEvaluationResult implements WritingEvaluationResult {
  const factory _WritingEvaluationResult({
    @JsonKey(name: 'Score') required final int score,
    @JsonKey(name: 'Corrections')
    required final List<WritingCorrection> corrections,
    @JsonKey(name: 'Feedback') required final String feedback,
    @JsonKey(name: 'CoinsEarned') required final int coinsEarned,
    @JsonKey(name: 'StarsEarned') required final int starsEarned,
  }) = _$WritingEvaluationResultImpl;

  factory _WritingEvaluationResult.fromJson(Map<String, dynamic> json) =
      _$WritingEvaluationResultImpl.fromJson;

  @override
  @JsonKey(name: 'Score')
  int get score;
  @override
  @JsonKey(name: 'Corrections')
  List<WritingCorrection> get corrections;
  @override
  @JsonKey(name: 'Feedback')
  String get feedback;
  @override
  @JsonKey(name: 'CoinsEarned')
  int get coinsEarned;
  @override
  @JsonKey(name: 'StarsEarned')
  int get starsEarned;

  /// Create a copy of WritingEvaluationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WritingEvaluationResultImplCopyWith<_$WritingEvaluationResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}
