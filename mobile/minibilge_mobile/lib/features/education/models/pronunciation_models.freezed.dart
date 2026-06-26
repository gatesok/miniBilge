// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pronunciation_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WordResult _$WordResultFromJson(Map<String, dynamic> json) {
  return _WordResult.fromJson(json);
}

/// @nodoc
mixin _$WordResult {
  @JsonKey(name: 'Word')
  String get word => throw _privateConstructorUsedError;
  @JsonKey(name: 'IsCorrect')
  bool get isCorrect => throw _privateConstructorUsedError;
  @JsonKey(name: 'Hint')
  String? get hint => throw _privateConstructorUsedError;

  /// Serializes this WordResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WordResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WordResultCopyWith<WordResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordResultCopyWith<$Res> {
  factory $WordResultCopyWith(
    WordResult value,
    $Res Function(WordResult) then,
  ) = _$WordResultCopyWithImpl<$Res, WordResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'Word') String word,
    @JsonKey(name: 'IsCorrect') bool isCorrect,
    @JsonKey(name: 'Hint') String? hint,
  });
}

/// @nodoc
class _$WordResultCopyWithImpl<$Res, $Val extends WordResult>
    implements $WordResultCopyWith<$Res> {
  _$WordResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WordResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? isCorrect = null,
    Object? hint = freezed,
  }) {
    return _then(
      _value.copyWith(
            word: null == word
                ? _value.word
                : word // ignore: cast_nullable_to_non_nullable
                      as String,
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
            hint: freezed == hint
                ? _value.hint
                : hint // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WordResultImplCopyWith<$Res>
    implements $WordResultCopyWith<$Res> {
  factory _$$WordResultImplCopyWith(
    _$WordResultImpl value,
    $Res Function(_$WordResultImpl) then,
  ) = __$$WordResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Word') String word,
    @JsonKey(name: 'IsCorrect') bool isCorrect,
    @JsonKey(name: 'Hint') String? hint,
  });
}

/// @nodoc
class __$$WordResultImplCopyWithImpl<$Res>
    extends _$WordResultCopyWithImpl<$Res, _$WordResultImpl>
    implements _$$WordResultImplCopyWith<$Res> {
  __$$WordResultImplCopyWithImpl(
    _$WordResultImpl _value,
    $Res Function(_$WordResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WordResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? isCorrect = null,
    Object? hint = freezed,
  }) {
    return _then(
      _$WordResultImpl(
        word: null == word
            ? _value.word
            : word // ignore: cast_nullable_to_non_nullable
                  as String,
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
        hint: freezed == hint
            ? _value.hint
            : hint // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WordResultImpl implements _WordResult {
  const _$WordResultImpl({
    @JsonKey(name: 'Word') required this.word,
    @JsonKey(name: 'IsCorrect') required this.isCorrect,
    @JsonKey(name: 'Hint') this.hint,
  });

  factory _$WordResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$WordResultImplFromJson(json);

  @override
  @JsonKey(name: 'Word')
  final String word;
  @override
  @JsonKey(name: 'IsCorrect')
  final bool isCorrect;
  @override
  @JsonKey(name: 'Hint')
  final String? hint;

  @override
  String toString() {
    return 'WordResult(word: $word, isCorrect: $isCorrect, hint: $hint)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordResultImpl &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.hint, hint) || other.hint == hint));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, word, isCorrect, hint);

  /// Create a copy of WordResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WordResultImplCopyWith<_$WordResultImpl> get copyWith =>
      __$$WordResultImplCopyWithImpl<_$WordResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WordResultImplToJson(this);
  }
}

abstract class _WordResult implements WordResult {
  const factory _WordResult({
    @JsonKey(name: 'Word') required final String word,
    @JsonKey(name: 'IsCorrect') required final bool isCorrect,
    @JsonKey(name: 'Hint') final String? hint,
  }) = _$WordResultImpl;

  factory _WordResult.fromJson(Map<String, dynamic> json) =
      _$WordResultImpl.fromJson;

  @override
  @JsonKey(name: 'Word')
  String get word;
  @override
  @JsonKey(name: 'IsCorrect')
  bool get isCorrect;
  @override
  @JsonKey(name: 'Hint')
  String? get hint;

  /// Create a copy of WordResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WordResultImplCopyWith<_$WordResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PronunciationResult _$PronunciationResultFromJson(Map<String, dynamic> json) {
  return _PronunciationResult.fromJson(json);
}

/// @nodoc
mixin _$PronunciationResult {
  @JsonKey(name: 'Words')
  List<WordResult> get words => throw _privateConstructorUsedError;
  @JsonKey(name: 'OverallScore')
  int get overallScore => throw _privateConstructorUsedError;

  /// Serializes this PronunciationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PronunciationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PronunciationResultCopyWith<PronunciationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PronunciationResultCopyWith<$Res> {
  factory $PronunciationResultCopyWith(
    PronunciationResult value,
    $Res Function(PronunciationResult) then,
  ) = _$PronunciationResultCopyWithImpl<$Res, PronunciationResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'Words') List<WordResult> words,
    @JsonKey(name: 'OverallScore') int overallScore,
  });
}

/// @nodoc
class _$PronunciationResultCopyWithImpl<$Res, $Val extends PronunciationResult>
    implements $PronunciationResultCopyWith<$Res> {
  _$PronunciationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PronunciationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? words = null, Object? overallScore = null}) {
    return _then(
      _value.copyWith(
            words: null == words
                ? _value.words
                : words // ignore: cast_nullable_to_non_nullable
                      as List<WordResult>,
            overallScore: null == overallScore
                ? _value.overallScore
                : overallScore // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PronunciationResultImplCopyWith<$Res>
    implements $PronunciationResultCopyWith<$Res> {
  factory _$$PronunciationResultImplCopyWith(
    _$PronunciationResultImpl value,
    $Res Function(_$PronunciationResultImpl) then,
  ) = __$$PronunciationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Words') List<WordResult> words,
    @JsonKey(name: 'OverallScore') int overallScore,
  });
}

/// @nodoc
class __$$PronunciationResultImplCopyWithImpl<$Res>
    extends _$PronunciationResultCopyWithImpl<$Res, _$PronunciationResultImpl>
    implements _$$PronunciationResultImplCopyWith<$Res> {
  __$$PronunciationResultImplCopyWithImpl(
    _$PronunciationResultImpl _value,
    $Res Function(_$PronunciationResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PronunciationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? words = null, Object? overallScore = null}) {
    return _then(
      _$PronunciationResultImpl(
        words: null == words
            ? _value._words
            : words // ignore: cast_nullable_to_non_nullable
                  as List<WordResult>,
        overallScore: null == overallScore
            ? _value.overallScore
            : overallScore // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PronunciationResultImpl implements _PronunciationResult {
  const _$PronunciationResultImpl({
    @JsonKey(name: 'Words') required final List<WordResult> words,
    @JsonKey(name: 'OverallScore') required this.overallScore,
  }) : _words = words;

  factory _$PronunciationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PronunciationResultImplFromJson(json);

  final List<WordResult> _words;
  @override
  @JsonKey(name: 'Words')
  List<WordResult> get words {
    if (_words is EqualUnmodifiableListView) return _words;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_words);
  }

  @override
  @JsonKey(name: 'OverallScore')
  final int overallScore;

  @override
  String toString() {
    return 'PronunciationResult(words: $words, overallScore: $overallScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PronunciationResultImpl &&
            const DeepCollectionEquality().equals(other._words, _words) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_words),
    overallScore,
  );

  /// Create a copy of PronunciationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PronunciationResultImplCopyWith<_$PronunciationResultImpl> get copyWith =>
      __$$PronunciationResultImplCopyWithImpl<_$PronunciationResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PronunciationResultImplToJson(this);
  }
}

abstract class _PronunciationResult implements PronunciationResult {
  const factory _PronunciationResult({
    @JsonKey(name: 'Words') required final List<WordResult> words,
    @JsonKey(name: 'OverallScore') required final int overallScore,
  }) = _$PronunciationResultImpl;

  factory _PronunciationResult.fromJson(Map<String, dynamic> json) =
      _$PronunciationResultImpl.fromJson;

  @override
  @JsonKey(name: 'Words')
  List<WordResult> get words;
  @override
  @JsonKey(name: 'OverallScore')
  int get overallScore;

  /// Create a copy of PronunciationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PronunciationResultImplCopyWith<_$PronunciationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
