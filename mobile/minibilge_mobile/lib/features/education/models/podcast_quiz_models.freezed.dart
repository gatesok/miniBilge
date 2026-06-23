// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_quiz_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PodcastQuizOption _$PodcastQuizOptionFromJson(Map<String, dynamic> json) {
  return _PodcastQuizOption.fromJson(json);
}

/// @nodoc
mixin _$PodcastQuizOption {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'OptionText')
  String get optionText => throw _privateConstructorUsedError;
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder => throw _privateConstructorUsedError;

  /// Serializes this PodcastQuizOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PodcastQuizOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastQuizOptionCopyWith<PodcastQuizOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastQuizOptionCopyWith<$Res> {
  factory $PodcastQuizOptionCopyWith(
    PodcastQuizOption value,
    $Res Function(PodcastQuizOption) then,
  ) = _$PodcastQuizOptionCopyWithImpl<$Res, PodcastQuizOption>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'OptionText') String optionText,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
  });
}

/// @nodoc
class _$PodcastQuizOptionCopyWithImpl<$Res, $Val extends PodcastQuizOption>
    implements $PodcastQuizOptionCopyWith<$Res> {
  _$PodcastQuizOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastQuizOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? optionText = null,
    Object? displayOrder = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            optionText: null == optionText
                ? _value.optionText
                : optionText // ignore: cast_nullable_to_non_nullable
                      as String,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PodcastQuizOptionImplCopyWith<$Res>
    implements $PodcastQuizOptionCopyWith<$Res> {
  factory _$$PodcastQuizOptionImplCopyWith(
    _$PodcastQuizOptionImpl value,
    $Res Function(_$PodcastQuizOptionImpl) then,
  ) = __$$PodcastQuizOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'OptionText') String optionText,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
  });
}

/// @nodoc
class __$$PodcastQuizOptionImplCopyWithImpl<$Res>
    extends _$PodcastQuizOptionCopyWithImpl<$Res, _$PodcastQuizOptionImpl>
    implements _$$PodcastQuizOptionImplCopyWith<$Res> {
  __$$PodcastQuizOptionImplCopyWithImpl(
    _$PodcastQuizOptionImpl _value,
    $Res Function(_$PodcastQuizOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PodcastQuizOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? optionText = null,
    Object? displayOrder = null,
  }) {
    return _then(
      _$PodcastQuizOptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        optionText: null == optionText
            ? _value.optionText
            : optionText // ignore: cast_nullable_to_non_nullable
                  as String,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastQuizOptionImpl implements _PodcastQuizOption {
  const _$PodcastQuizOptionImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'OptionText') required this.optionText,
    @JsonKey(name: 'DisplayOrder') required this.displayOrder,
  });

  factory _$PodcastQuizOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastQuizOptionImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'OptionText')
  final String optionText;
  @override
  @JsonKey(name: 'DisplayOrder')
  final int displayOrder;

  @override
  String toString() {
    return 'PodcastQuizOption(id: $id, optionText: $optionText, displayOrder: $displayOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastQuizOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.optionText, optionText) ||
                other.optionText == optionText) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, optionText, displayOrder);

  /// Create a copy of PodcastQuizOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastQuizOptionImplCopyWith<_$PodcastQuizOptionImpl> get copyWith =>
      __$$PodcastQuizOptionImplCopyWithImpl<_$PodcastQuizOptionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastQuizOptionImplToJson(this);
  }
}

abstract class _PodcastQuizOption implements PodcastQuizOption {
  const factory _PodcastQuizOption({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'OptionText') required final String optionText,
    @JsonKey(name: 'DisplayOrder') required final int displayOrder,
  }) = _$PodcastQuizOptionImpl;

  factory _PodcastQuizOption.fromJson(Map<String, dynamic> json) =
      _$PodcastQuizOptionImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'OptionText')
  String get optionText;
  @override
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder;

  /// Create a copy of PodcastQuizOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastQuizOptionImplCopyWith<_$PodcastQuizOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PodcastQuizQuestion _$PodcastQuizQuestionFromJson(Map<String, dynamic> json) {
  return _PodcastQuizQuestion.fromJson(json);
}

/// @nodoc
mixin _$PodcastQuizQuestion {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'QuestionText')
  String get questionText => throw _privateConstructorUsedError;
  @JsonKey(name: 'QuestionType')
  int get questionType => throw _privateConstructorUsedError;
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'Options')
  List<PodcastQuizOption> get options => throw _privateConstructorUsedError;

  /// Serializes this PodcastQuizQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PodcastQuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastQuizQuestionCopyWith<PodcastQuizQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastQuizQuestionCopyWith<$Res> {
  factory $PodcastQuizQuestionCopyWith(
    PodcastQuizQuestion value,
    $Res Function(PodcastQuizQuestion) then,
  ) = _$PodcastQuizQuestionCopyWithImpl<$Res, PodcastQuizQuestion>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'QuestionText') String questionText,
    @JsonKey(name: 'QuestionType') int questionType,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
    @JsonKey(name: 'Options') List<PodcastQuizOption> options,
  });
}

/// @nodoc
class _$PodcastQuizQuestionCopyWithImpl<$Res, $Val extends PodcastQuizQuestion>
    implements $PodcastQuizQuestionCopyWith<$Res> {
  _$PodcastQuizQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastQuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionText = null,
    Object? questionType = null,
    Object? displayOrder = null,
    Object? options = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            questionText: null == questionText
                ? _value.questionText
                : questionText // ignore: cast_nullable_to_non_nullable
                      as String,
            questionType: null == questionType
                ? _value.questionType
                : questionType // ignore: cast_nullable_to_non_nullable
                      as int,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<PodcastQuizOption>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PodcastQuizQuestionImplCopyWith<$Res>
    implements $PodcastQuizQuestionCopyWith<$Res> {
  factory _$$PodcastQuizQuestionImplCopyWith(
    _$PodcastQuizQuestionImpl value,
    $Res Function(_$PodcastQuizQuestionImpl) then,
  ) = __$$PodcastQuizQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'QuestionText') String questionText,
    @JsonKey(name: 'QuestionType') int questionType,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
    @JsonKey(name: 'Options') List<PodcastQuizOption> options,
  });
}

/// @nodoc
class __$$PodcastQuizQuestionImplCopyWithImpl<$Res>
    extends _$PodcastQuizQuestionCopyWithImpl<$Res, _$PodcastQuizQuestionImpl>
    implements _$$PodcastQuizQuestionImplCopyWith<$Res> {
  __$$PodcastQuizQuestionImplCopyWithImpl(
    _$PodcastQuizQuestionImpl _value,
    $Res Function(_$PodcastQuizQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PodcastQuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? questionText = null,
    Object? questionType = null,
    Object? displayOrder = null,
    Object? options = null,
  }) {
    return _then(
      _$PodcastQuizQuestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        questionText: null == questionText
            ? _value.questionText
            : questionText // ignore: cast_nullable_to_non_nullable
                  as String,
        questionType: null == questionType
            ? _value.questionType
            : questionType // ignore: cast_nullable_to_non_nullable
                  as int,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<PodcastQuizOption>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastQuizQuestionImpl implements _PodcastQuizQuestion {
  const _$PodcastQuizQuestionImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'QuestionText') required this.questionText,
    @JsonKey(name: 'QuestionType') required this.questionType,
    @JsonKey(name: 'DisplayOrder') required this.displayOrder,
    @JsonKey(name: 'Options') required final List<PodcastQuizOption> options,
  }) : _options = options;

  factory _$PodcastQuizQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastQuizQuestionImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'QuestionText')
  final String questionText;
  @override
  @JsonKey(name: 'QuestionType')
  final int questionType;
  @override
  @JsonKey(name: 'DisplayOrder')
  final int displayOrder;
  final List<PodcastQuizOption> _options;
  @override
  @JsonKey(name: 'Options')
  List<PodcastQuizOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'PodcastQuizQuestion(id: $id, questionText: $questionText, questionType: $questionType, displayOrder: $displayOrder, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastQuizQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.questionType, questionType) ||
                other.questionType == questionType) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    questionText,
    questionType,
    displayOrder,
    const DeepCollectionEquality().hash(_options),
  );

  /// Create a copy of PodcastQuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastQuizQuestionImplCopyWith<_$PodcastQuizQuestionImpl> get copyWith =>
      __$$PodcastQuizQuestionImplCopyWithImpl<_$PodcastQuizQuestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastQuizQuestionImplToJson(this);
  }
}

abstract class _PodcastQuizQuestion implements PodcastQuizQuestion {
  const factory _PodcastQuizQuestion({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'QuestionText') required final String questionText,
    @JsonKey(name: 'QuestionType') required final int questionType,
    @JsonKey(name: 'DisplayOrder') required final int displayOrder,
    @JsonKey(name: 'Options') required final List<PodcastQuizOption> options,
  }) = _$PodcastQuizQuestionImpl;

  factory _PodcastQuizQuestion.fromJson(Map<String, dynamic> json) =
      _$PodcastQuizQuestionImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'QuestionText')
  String get questionText;
  @override
  @JsonKey(name: 'QuestionType')
  int get questionType;
  @override
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder;
  @override
  @JsonKey(name: 'Options')
  List<PodcastQuizOption> get options;

  /// Create a copy of PodcastQuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastQuizQuestionImplCopyWith<_$PodcastQuizQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PodcastQuizAnswerResult _$PodcastQuizAnswerResultFromJson(
  Map<String, dynamic> json,
) {
  return _PodcastQuizAnswerResult.fromJson(json);
}

/// @nodoc
mixin _$PodcastQuizAnswerResult {
  @JsonKey(name: 'QuestionId')
  String get questionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'IsCorrect')
  bool get isCorrect => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectAnswer')
  String get correctAnswer => throw _privateConstructorUsedError;
  @JsonKey(name: 'Explanation')
  String? get explanation => throw _privateConstructorUsedError;

  /// Serializes this PodcastQuizAnswerResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PodcastQuizAnswerResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastQuizAnswerResultCopyWith<PodcastQuizAnswerResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastQuizAnswerResultCopyWith<$Res> {
  factory $PodcastQuizAnswerResultCopyWith(
    PodcastQuizAnswerResult value,
    $Res Function(PodcastQuizAnswerResult) then,
  ) = _$PodcastQuizAnswerResultCopyWithImpl<$Res, PodcastQuizAnswerResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'QuestionId') String questionId,
    @JsonKey(name: 'IsCorrect') bool isCorrect,
    @JsonKey(name: 'CorrectAnswer') String correctAnswer,
    @JsonKey(name: 'Explanation') String? explanation,
  });
}

/// @nodoc
class _$PodcastQuizAnswerResultCopyWithImpl<
  $Res,
  $Val extends PodcastQuizAnswerResult
>
    implements $PodcastQuizAnswerResultCopyWith<$Res> {
  _$PodcastQuizAnswerResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastQuizAnswerResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? isCorrect = null,
    Object? correctAnswer = null,
    Object? explanation = freezed,
  }) {
    return _then(
      _value.copyWith(
            questionId: null == questionId
                ? _value.questionId
                : questionId // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$PodcastQuizAnswerResultImplCopyWith<$Res>
    implements $PodcastQuizAnswerResultCopyWith<$Res> {
  factory _$$PodcastQuizAnswerResultImplCopyWith(
    _$PodcastQuizAnswerResultImpl value,
    $Res Function(_$PodcastQuizAnswerResultImpl) then,
  ) = __$$PodcastQuizAnswerResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'QuestionId') String questionId,
    @JsonKey(name: 'IsCorrect') bool isCorrect,
    @JsonKey(name: 'CorrectAnswer') String correctAnswer,
    @JsonKey(name: 'Explanation') String? explanation,
  });
}

/// @nodoc
class __$$PodcastQuizAnswerResultImplCopyWithImpl<$Res>
    extends
        _$PodcastQuizAnswerResultCopyWithImpl<
          $Res,
          _$PodcastQuizAnswerResultImpl
        >
    implements _$$PodcastQuizAnswerResultImplCopyWith<$Res> {
  __$$PodcastQuizAnswerResultImplCopyWithImpl(
    _$PodcastQuizAnswerResultImpl _value,
    $Res Function(_$PodcastQuizAnswerResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PodcastQuizAnswerResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? isCorrect = null,
    Object? correctAnswer = null,
    Object? explanation = freezed,
  }) {
    return _then(
      _$PodcastQuizAnswerResultImpl(
        questionId: null == questionId
            ? _value.questionId
            : questionId // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$PodcastQuizAnswerResultImpl implements _PodcastQuizAnswerResult {
  const _$PodcastQuizAnswerResultImpl({
    @JsonKey(name: 'QuestionId') required this.questionId,
    @JsonKey(name: 'IsCorrect') required this.isCorrect,
    @JsonKey(name: 'CorrectAnswer') required this.correctAnswer,
    @JsonKey(name: 'Explanation') this.explanation,
  });

  factory _$PodcastQuizAnswerResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastQuizAnswerResultImplFromJson(json);

  @override
  @JsonKey(name: 'QuestionId')
  final String questionId;
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
    return 'PodcastQuizAnswerResult(questionId: $questionId, isCorrect: $isCorrect, correctAnswer: $correctAnswer, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastQuizAnswerResultImpl &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionId,
    isCorrect,
    correctAnswer,
    explanation,
  );

  /// Create a copy of PodcastQuizAnswerResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastQuizAnswerResultImplCopyWith<_$PodcastQuizAnswerResultImpl>
  get copyWith =>
      __$$PodcastQuizAnswerResultImplCopyWithImpl<
        _$PodcastQuizAnswerResultImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastQuizAnswerResultImplToJson(this);
  }
}

abstract class _PodcastQuizAnswerResult implements PodcastQuizAnswerResult {
  const factory _PodcastQuizAnswerResult({
    @JsonKey(name: 'QuestionId') required final String questionId,
    @JsonKey(name: 'IsCorrect') required final bool isCorrect,
    @JsonKey(name: 'CorrectAnswer') required final String correctAnswer,
    @JsonKey(name: 'Explanation') final String? explanation,
  }) = _$PodcastQuizAnswerResultImpl;

  factory _PodcastQuizAnswerResult.fromJson(Map<String, dynamic> json) =
      _$PodcastQuizAnswerResultImpl.fromJson;

  @override
  @JsonKey(name: 'QuestionId')
  String get questionId;
  @override
  @JsonKey(name: 'IsCorrect')
  bool get isCorrect;
  @override
  @JsonKey(name: 'CorrectAnswer')
  String get correctAnswer;
  @override
  @JsonKey(name: 'Explanation')
  String? get explanation;

  /// Create a copy of PodcastQuizAnswerResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastQuizAnswerResultImplCopyWith<_$PodcastQuizAnswerResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PodcastQuizResult _$PodcastQuizResultFromJson(Map<String, dynamic> json) {
  return _PodcastQuizResult.fromJson(json);
}

/// @nodoc
mixin _$PodcastQuizResult {
  @JsonKey(name: 'CorrectCount')
  int get correctCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalQuestions')
  int get totalQuestions => throw _privateConstructorUsedError;
  @JsonKey(name: 'StarsEarned')
  int get starsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'CoinsEarned')
  int get coinsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'IsFirstCompletion')
  bool get isFirstCompletion => throw _privateConstructorUsedError;
  @JsonKey(name: 'AnswerResults')
  List<PodcastQuizAnswerResult> get answerResults =>
      throw _privateConstructorUsedError;

  /// Serializes this PodcastQuizResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PodcastQuizResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastQuizResultCopyWith<PodcastQuizResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastQuizResultCopyWith<$Res> {
  factory $PodcastQuizResultCopyWith(
    PodcastQuizResult value,
    $Res Function(PodcastQuizResult) then,
  ) = _$PodcastQuizResultCopyWithImpl<$Res, PodcastQuizResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'CorrectCount') int correctCount,
    @JsonKey(name: 'TotalQuestions') int totalQuestions,
    @JsonKey(name: 'StarsEarned') int starsEarned,
    @JsonKey(name: 'CoinsEarned') int coinsEarned,
    @JsonKey(name: 'IsFirstCompletion') bool isFirstCompletion,
    @JsonKey(name: 'AnswerResults') List<PodcastQuizAnswerResult> answerResults,
  });
}

/// @nodoc
class _$PodcastQuizResultCopyWithImpl<$Res, $Val extends PodcastQuizResult>
    implements $PodcastQuizResultCopyWith<$Res> {
  _$PodcastQuizResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastQuizResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? correctCount = null,
    Object? totalQuestions = null,
    Object? starsEarned = null,
    Object? coinsEarned = null,
    Object? isFirstCompletion = null,
    Object? answerResults = null,
  }) {
    return _then(
      _value.copyWith(
            correctCount: null == correctCount
                ? _value.correctCount
                : correctCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalQuestions: null == totalQuestions
                ? _value.totalQuestions
                : totalQuestions // ignore: cast_nullable_to_non_nullable
                      as int,
            starsEarned: null == starsEarned
                ? _value.starsEarned
                : starsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
            coinsEarned: null == coinsEarned
                ? _value.coinsEarned
                : coinsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
            isFirstCompletion: null == isFirstCompletion
                ? _value.isFirstCompletion
                : isFirstCompletion // ignore: cast_nullable_to_non_nullable
                      as bool,
            answerResults: null == answerResults
                ? _value.answerResults
                : answerResults // ignore: cast_nullable_to_non_nullable
                      as List<PodcastQuizAnswerResult>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PodcastQuizResultImplCopyWith<$Res>
    implements $PodcastQuizResultCopyWith<$Res> {
  factory _$$PodcastQuizResultImplCopyWith(
    _$PodcastQuizResultImpl value,
    $Res Function(_$PodcastQuizResultImpl) then,
  ) = __$$PodcastQuizResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'CorrectCount') int correctCount,
    @JsonKey(name: 'TotalQuestions') int totalQuestions,
    @JsonKey(name: 'StarsEarned') int starsEarned,
    @JsonKey(name: 'CoinsEarned') int coinsEarned,
    @JsonKey(name: 'IsFirstCompletion') bool isFirstCompletion,
    @JsonKey(name: 'AnswerResults') List<PodcastQuizAnswerResult> answerResults,
  });
}

/// @nodoc
class __$$PodcastQuizResultImplCopyWithImpl<$Res>
    extends _$PodcastQuizResultCopyWithImpl<$Res, _$PodcastQuizResultImpl>
    implements _$$PodcastQuizResultImplCopyWith<$Res> {
  __$$PodcastQuizResultImplCopyWithImpl(
    _$PodcastQuizResultImpl _value,
    $Res Function(_$PodcastQuizResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PodcastQuizResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? correctCount = null,
    Object? totalQuestions = null,
    Object? starsEarned = null,
    Object? coinsEarned = null,
    Object? isFirstCompletion = null,
    Object? answerResults = null,
  }) {
    return _then(
      _$PodcastQuizResultImpl(
        correctCount: null == correctCount
            ? _value.correctCount
            : correctCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalQuestions: null == totalQuestions
            ? _value.totalQuestions
            : totalQuestions // ignore: cast_nullable_to_non_nullable
                  as int,
        starsEarned: null == starsEarned
            ? _value.starsEarned
            : starsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
        coinsEarned: null == coinsEarned
            ? _value.coinsEarned
            : coinsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
        isFirstCompletion: null == isFirstCompletion
            ? _value.isFirstCompletion
            : isFirstCompletion // ignore: cast_nullable_to_non_nullable
                  as bool,
        answerResults: null == answerResults
            ? _value._answerResults
            : answerResults // ignore: cast_nullable_to_non_nullable
                  as List<PodcastQuizAnswerResult>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastQuizResultImpl implements _PodcastQuizResult {
  const _$PodcastQuizResultImpl({
    @JsonKey(name: 'CorrectCount') required this.correctCount,
    @JsonKey(name: 'TotalQuestions') required this.totalQuestions,
    @JsonKey(name: 'StarsEarned') required this.starsEarned,
    @JsonKey(name: 'CoinsEarned') required this.coinsEarned,
    @JsonKey(name: 'IsFirstCompletion') required this.isFirstCompletion,
    @JsonKey(name: 'AnswerResults')
    required final List<PodcastQuizAnswerResult> answerResults,
  }) : _answerResults = answerResults;

  factory _$PodcastQuizResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastQuizResultImplFromJson(json);

  @override
  @JsonKey(name: 'CorrectCount')
  final int correctCount;
  @override
  @JsonKey(name: 'TotalQuestions')
  final int totalQuestions;
  @override
  @JsonKey(name: 'StarsEarned')
  final int starsEarned;
  @override
  @JsonKey(name: 'CoinsEarned')
  final int coinsEarned;
  @override
  @JsonKey(name: 'IsFirstCompletion')
  final bool isFirstCompletion;
  final List<PodcastQuizAnswerResult> _answerResults;
  @override
  @JsonKey(name: 'AnswerResults')
  List<PodcastQuizAnswerResult> get answerResults {
    if (_answerResults is EqualUnmodifiableListView) return _answerResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_answerResults);
  }

  @override
  String toString() {
    return 'PodcastQuizResult(correctCount: $correctCount, totalQuestions: $totalQuestions, starsEarned: $starsEarned, coinsEarned: $coinsEarned, isFirstCompletion: $isFirstCompletion, answerResults: $answerResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastQuizResultImpl &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.starsEarned, starsEarned) ||
                other.starsEarned == starsEarned) &&
            (identical(other.coinsEarned, coinsEarned) ||
                other.coinsEarned == coinsEarned) &&
            (identical(other.isFirstCompletion, isFirstCompletion) ||
                other.isFirstCompletion == isFirstCompletion) &&
            const DeepCollectionEquality().equals(
              other._answerResults,
              _answerResults,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    correctCount,
    totalQuestions,
    starsEarned,
    coinsEarned,
    isFirstCompletion,
    const DeepCollectionEquality().hash(_answerResults),
  );

  /// Create a copy of PodcastQuizResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastQuizResultImplCopyWith<_$PodcastQuizResultImpl> get copyWith =>
      __$$PodcastQuizResultImplCopyWithImpl<_$PodcastQuizResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastQuizResultImplToJson(this);
  }
}

abstract class _PodcastQuizResult implements PodcastQuizResult {
  const factory _PodcastQuizResult({
    @JsonKey(name: 'CorrectCount') required final int correctCount,
    @JsonKey(name: 'TotalQuestions') required final int totalQuestions,
    @JsonKey(name: 'StarsEarned') required final int starsEarned,
    @JsonKey(name: 'CoinsEarned') required final int coinsEarned,
    @JsonKey(name: 'IsFirstCompletion') required final bool isFirstCompletion,
    @JsonKey(name: 'AnswerResults')
    required final List<PodcastQuizAnswerResult> answerResults,
  }) = _$PodcastQuizResultImpl;

  factory _PodcastQuizResult.fromJson(Map<String, dynamic> json) =
      _$PodcastQuizResultImpl.fromJson;

  @override
  @JsonKey(name: 'CorrectCount')
  int get correctCount;
  @override
  @JsonKey(name: 'TotalQuestions')
  int get totalQuestions;
  @override
  @JsonKey(name: 'StarsEarned')
  int get starsEarned;
  @override
  @JsonKey(name: 'CoinsEarned')
  int get coinsEarned;
  @override
  @JsonKey(name: 'IsFirstCompletion')
  bool get isFirstCompletion;
  @override
  @JsonKey(name: 'AnswerResults')
  List<PodcastQuizAnswerResult> get answerResults;

  /// Create a copy of PodcastQuizResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastQuizResultImplCopyWith<_$PodcastQuizResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
