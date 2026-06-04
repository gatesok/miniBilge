// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return _Question.fromJson(json);
}

/// @nodoc
mixin _$Question {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'LevelId')
  String get levelId => throw _privateConstructorUsedError;
  @JsonKey(name: 'QuestionText')
  String get questionText => throw _privateConstructorUsedError;
  @JsonKey(name: 'QuestionType')
  QuestionType get questionType => throw _privateConstructorUsedError;
  @JsonKey(name: 'Explanation')
  String? get explanation => throw _privateConstructorUsedError;
  @JsonKey(name: 'HasLatex')
  bool get hasLatex => throw _privateConstructorUsedError;
  @JsonKey(name: 'Options')
  List<QuestionOption> get options => throw _privateConstructorUsedError;

  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionCopyWith<Question> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionCopyWith<$Res> {
  factory $QuestionCopyWith(Question value, $Res Function(Question) then) =
      _$QuestionCopyWithImpl<$Res, Question>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'LevelId') String levelId,
    @JsonKey(name: 'QuestionText') String questionText,
    @JsonKey(name: 'QuestionType') QuestionType questionType,
    @JsonKey(name: 'Explanation') String? explanation,
    @JsonKey(name: 'HasLatex') bool hasLatex,
    @JsonKey(name: 'Options') List<QuestionOption> options,
  });
}

/// @nodoc
class _$QuestionCopyWithImpl<$Res, $Val extends Question>
    implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? levelId = null,
    Object? questionText = null,
    Object? questionType = null,
    Object? explanation = freezed,
    Object? hasLatex = null,
    Object? options = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            levelId: null == levelId
                ? _value.levelId
                : levelId // ignore: cast_nullable_to_non_nullable
                      as String,
            questionText: null == questionText
                ? _value.questionText
                : questionText // ignore: cast_nullable_to_non_nullable
                      as String,
            questionType: null == questionType
                ? _value.questionType
                : questionType // ignore: cast_nullable_to_non_nullable
                      as QuestionType,
            explanation: freezed == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String?,
            hasLatex: null == hasLatex
                ? _value.hasLatex
                : hasLatex // ignore: cast_nullable_to_non_nullable
                      as bool,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<QuestionOption>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionImplCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory _$$QuestionImplCopyWith(
    _$QuestionImpl value,
    $Res Function(_$QuestionImpl) then,
  ) = __$$QuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'LevelId') String levelId,
    @JsonKey(name: 'QuestionText') String questionText,
    @JsonKey(name: 'QuestionType') QuestionType questionType,
    @JsonKey(name: 'Explanation') String? explanation,
    @JsonKey(name: 'HasLatex') bool hasLatex,
    @JsonKey(name: 'Options') List<QuestionOption> options,
  });
}

/// @nodoc
class __$$QuestionImplCopyWithImpl<$Res>
    extends _$QuestionCopyWithImpl<$Res, _$QuestionImpl>
    implements _$$QuestionImplCopyWith<$Res> {
  __$$QuestionImplCopyWithImpl(
    _$QuestionImpl _value,
    $Res Function(_$QuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? levelId = null,
    Object? questionText = null,
    Object? questionType = null,
    Object? explanation = freezed,
    Object? hasLatex = null,
    Object? options = null,
  }) {
    return _then(
      _$QuestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        levelId: null == levelId
            ? _value.levelId
            : levelId // ignore: cast_nullable_to_non_nullable
                  as String,
        questionText: null == questionText
            ? _value.questionText
            : questionText // ignore: cast_nullable_to_non_nullable
                  as String,
        questionType: null == questionType
            ? _value.questionType
            : questionType // ignore: cast_nullable_to_non_nullable
                  as QuestionType,
        explanation: freezed == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasLatex: null == hasLatex
            ? _value.hasLatex
            : hasLatex // ignore: cast_nullable_to_non_nullable
                  as bool,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<QuestionOption>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionImpl implements _Question {
  const _$QuestionImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'LevelId') required this.levelId,
    @JsonKey(name: 'QuestionText') required this.questionText,
    @JsonKey(name: 'QuestionType') required this.questionType,
    @JsonKey(name: 'Explanation') this.explanation,
    @JsonKey(name: 'HasLatex') this.hasLatex = false,
    @JsonKey(name: 'Options') final List<QuestionOption> options = const [],
  }) : _options = options;

  factory _$QuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'LevelId')
  final String levelId;
  @override
  @JsonKey(name: 'QuestionText')
  final String questionText;
  @override
  @JsonKey(name: 'QuestionType')
  final QuestionType questionType;
  @override
  @JsonKey(name: 'Explanation')
  final String? explanation;
  @override
  @JsonKey(name: 'HasLatex')
  final bool hasLatex;
  final List<QuestionOption> _options;
  @override
  @JsonKey(name: 'Options')
  List<QuestionOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'Question(id: $id, levelId: $levelId, questionText: $questionText, questionType: $questionType, explanation: $explanation, hasLatex: $hasLatex, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.levelId, levelId) || other.levelId == levelId) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.questionType, questionType) ||
                other.questionType == questionType) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.hasLatex, hasLatex) ||
                other.hasLatex == hasLatex) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    levelId,
    questionText,
    questionType,
    explanation,
    hasLatex,
    const DeepCollectionEquality().hash(_options),
  );

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionImplCopyWith<_$QuestionImpl> get copyWith =>
      __$$QuestionImplCopyWithImpl<_$QuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionImplToJson(this);
  }
}

abstract class _Question implements Question {
  const factory _Question({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'LevelId') required final String levelId,
    @JsonKey(name: 'QuestionText') required final String questionText,
    @JsonKey(name: 'QuestionType') required final QuestionType questionType,
    @JsonKey(name: 'Explanation') final String? explanation,
    @JsonKey(name: 'HasLatex') final bool hasLatex,
    @JsonKey(name: 'Options') final List<QuestionOption> options,
  }) = _$QuestionImpl;

  factory _Question.fromJson(Map<String, dynamic> json) =
      _$QuestionImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'LevelId')
  String get levelId;
  @override
  @JsonKey(name: 'QuestionText')
  String get questionText;
  @override
  @JsonKey(name: 'QuestionType')
  QuestionType get questionType;
  @override
  @JsonKey(name: 'Explanation')
  String? get explanation;
  @override
  @JsonKey(name: 'HasLatex')
  bool get hasLatex;
  @override
  @JsonKey(name: 'Options')
  List<QuestionOption> get options;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionImplCopyWith<_$QuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
