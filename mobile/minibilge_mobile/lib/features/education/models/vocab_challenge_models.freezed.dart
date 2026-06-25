// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vocab_challenge_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VocabChallengeTask _$VocabChallengeTaskFromJson(Map<String, dynamic> json) {
  return _VocabChallengeTask.fromJson(json);
}

/// @nodoc
mixin _$VocabChallengeTask {
  @JsonKey(name: 'Task')
  String get task => throw _privateConstructorUsedError;
  @JsonKey(name: 'TargetWords')
  List<String> get targetWords => throw _privateConstructorUsedError;

  /// Serializes this VocabChallengeTask to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VocabChallengeTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VocabChallengeTaskCopyWith<VocabChallengeTask> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VocabChallengeTaskCopyWith<$Res> {
  factory $VocabChallengeTaskCopyWith(
    VocabChallengeTask value,
    $Res Function(VocabChallengeTask) then,
  ) = _$VocabChallengeTaskCopyWithImpl<$Res, VocabChallengeTask>;
  @useResult
  $Res call({
    @JsonKey(name: 'Task') String task,
    @JsonKey(name: 'TargetWords') List<String> targetWords,
  });
}

/// @nodoc
class _$VocabChallengeTaskCopyWithImpl<$Res, $Val extends VocabChallengeTask>
    implements $VocabChallengeTaskCopyWith<$Res> {
  _$VocabChallengeTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VocabChallengeTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? task = null, Object? targetWords = null}) {
    return _then(
      _value.copyWith(
            task: null == task
                ? _value.task
                : task // ignore: cast_nullable_to_non_nullable
                      as String,
            targetWords: null == targetWords
                ? _value.targetWords
                : targetWords // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VocabChallengeTaskImplCopyWith<$Res>
    implements $VocabChallengeTaskCopyWith<$Res> {
  factory _$$VocabChallengeTaskImplCopyWith(
    _$VocabChallengeTaskImpl value,
    $Res Function(_$VocabChallengeTaskImpl) then,
  ) = __$$VocabChallengeTaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Task') String task,
    @JsonKey(name: 'TargetWords') List<String> targetWords,
  });
}

/// @nodoc
class __$$VocabChallengeTaskImplCopyWithImpl<$Res>
    extends _$VocabChallengeTaskCopyWithImpl<$Res, _$VocabChallengeTaskImpl>
    implements _$$VocabChallengeTaskImplCopyWith<$Res> {
  __$$VocabChallengeTaskImplCopyWithImpl(
    _$VocabChallengeTaskImpl _value,
    $Res Function(_$VocabChallengeTaskImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VocabChallengeTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? task = null, Object? targetWords = null}) {
    return _then(
      _$VocabChallengeTaskImpl(
        task: null == task
            ? _value.task
            : task // ignore: cast_nullable_to_non_nullable
                  as String,
        targetWords: null == targetWords
            ? _value._targetWords
            : targetWords // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VocabChallengeTaskImpl implements _VocabChallengeTask {
  const _$VocabChallengeTaskImpl({
    @JsonKey(name: 'Task') required this.task,
    @JsonKey(name: 'TargetWords') required final List<String> targetWords,
  }) : _targetWords = targetWords;

  factory _$VocabChallengeTaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$VocabChallengeTaskImplFromJson(json);

  @override
  @JsonKey(name: 'Task')
  final String task;
  final List<String> _targetWords;
  @override
  @JsonKey(name: 'TargetWords')
  List<String> get targetWords {
    if (_targetWords is EqualUnmodifiableListView) return _targetWords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetWords);
  }

  @override
  String toString() {
    return 'VocabChallengeTask(task: $task, targetWords: $targetWords)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VocabChallengeTaskImpl &&
            (identical(other.task, task) || other.task == task) &&
            const DeepCollectionEquality().equals(
              other._targetWords,
              _targetWords,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    task,
    const DeepCollectionEquality().hash(_targetWords),
  );

  /// Create a copy of VocabChallengeTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VocabChallengeTaskImplCopyWith<_$VocabChallengeTaskImpl> get copyWith =>
      __$$VocabChallengeTaskImplCopyWithImpl<_$VocabChallengeTaskImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VocabChallengeTaskImplToJson(this);
  }
}

abstract class _VocabChallengeTask implements VocabChallengeTask {
  const factory _VocabChallengeTask({
    @JsonKey(name: 'Task') required final String task,
    @JsonKey(name: 'TargetWords') required final List<String> targetWords,
  }) = _$VocabChallengeTaskImpl;

  factory _VocabChallengeTask.fromJson(Map<String, dynamic> json) =
      _$VocabChallengeTaskImpl.fromJson;

  @override
  @JsonKey(name: 'Task')
  String get task;
  @override
  @JsonKey(name: 'TargetWords')
  List<String> get targetWords;

  /// Create a copy of VocabChallengeTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VocabChallengeTaskImplCopyWith<_$VocabChallengeTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VocabChallengeResult _$VocabChallengeResultFromJson(Map<String, dynamic> json) {
  return _VocabChallengeResult.fromJson(json);
}

/// @nodoc
mixin _$VocabChallengeResult {
  @JsonKey(name: 'Score')
  int get score => throw _privateConstructorUsedError;

  /// Her hedef kelimenin doğru kullanılıp kullanılmadığı: {"explore": true, "happy": false}
  @JsonKey(name: 'TargetWordUsage')
  Map<String, bool> get targetWordUsage => throw _privateConstructorUsedError;
  @JsonKey(name: 'Corrections')
  List<WritingCorrection> get corrections => throw _privateConstructorUsedError;
  @JsonKey(name: 'Feedback')
  String get feedback => throw _privateConstructorUsedError;
  @JsonKey(name: 'CoinsEarned')
  int get coinsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'StarsEarned')
  int get starsEarned => throw _privateConstructorUsedError;

  /// Serializes this VocabChallengeResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VocabChallengeResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VocabChallengeResultCopyWith<VocabChallengeResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VocabChallengeResultCopyWith<$Res> {
  factory $VocabChallengeResultCopyWith(
    VocabChallengeResult value,
    $Res Function(VocabChallengeResult) then,
  ) = _$VocabChallengeResultCopyWithImpl<$Res, VocabChallengeResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'Score') int score,
    @JsonKey(name: 'TargetWordUsage') Map<String, bool> targetWordUsage,
    @JsonKey(name: 'Corrections') List<WritingCorrection> corrections,
    @JsonKey(name: 'Feedback') String feedback,
    @JsonKey(name: 'CoinsEarned') int coinsEarned,
    @JsonKey(name: 'StarsEarned') int starsEarned,
  });
}

/// @nodoc
class _$VocabChallengeResultCopyWithImpl<
  $Res,
  $Val extends VocabChallengeResult
>
    implements $VocabChallengeResultCopyWith<$Res> {
  _$VocabChallengeResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VocabChallengeResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? targetWordUsage = null,
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
            targetWordUsage: null == targetWordUsage
                ? _value.targetWordUsage
                : targetWordUsage // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
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
abstract class _$$VocabChallengeResultImplCopyWith<$Res>
    implements $VocabChallengeResultCopyWith<$Res> {
  factory _$$VocabChallengeResultImplCopyWith(
    _$VocabChallengeResultImpl value,
    $Res Function(_$VocabChallengeResultImpl) then,
  ) = __$$VocabChallengeResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Score') int score,
    @JsonKey(name: 'TargetWordUsage') Map<String, bool> targetWordUsage,
    @JsonKey(name: 'Corrections') List<WritingCorrection> corrections,
    @JsonKey(name: 'Feedback') String feedback,
    @JsonKey(name: 'CoinsEarned') int coinsEarned,
    @JsonKey(name: 'StarsEarned') int starsEarned,
  });
}

/// @nodoc
class __$$VocabChallengeResultImplCopyWithImpl<$Res>
    extends _$VocabChallengeResultCopyWithImpl<$Res, _$VocabChallengeResultImpl>
    implements _$$VocabChallengeResultImplCopyWith<$Res> {
  __$$VocabChallengeResultImplCopyWithImpl(
    _$VocabChallengeResultImpl _value,
    $Res Function(_$VocabChallengeResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VocabChallengeResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? targetWordUsage = null,
    Object? corrections = null,
    Object? feedback = null,
    Object? coinsEarned = null,
    Object? starsEarned = null,
  }) {
    return _then(
      _$VocabChallengeResultImpl(
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        targetWordUsage: null == targetWordUsage
            ? _value._targetWordUsage
            : targetWordUsage // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
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
class _$VocabChallengeResultImpl implements _VocabChallengeResult {
  const _$VocabChallengeResultImpl({
    @JsonKey(name: 'Score') required this.score,
    @JsonKey(name: 'TargetWordUsage')
    required final Map<String, bool> targetWordUsage,
    @JsonKey(name: 'Corrections')
    required final List<WritingCorrection> corrections,
    @JsonKey(name: 'Feedback') required this.feedback,
    @JsonKey(name: 'CoinsEarned') this.coinsEarned = 0,
    @JsonKey(name: 'StarsEarned') this.starsEarned = 0,
  }) : _targetWordUsage = targetWordUsage,
       _corrections = corrections;

  factory _$VocabChallengeResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$VocabChallengeResultImplFromJson(json);

  @override
  @JsonKey(name: 'Score')
  final int score;

  /// Her hedef kelimenin doğru kullanılıp kullanılmadığı: {"explore": true, "happy": false}
  final Map<String, bool> _targetWordUsage;

  /// Her hedef kelimenin doğru kullanılıp kullanılmadığı: {"explore": true, "happy": false}
  @override
  @JsonKey(name: 'TargetWordUsage')
  Map<String, bool> get targetWordUsage {
    if (_targetWordUsage is EqualUnmodifiableMapView) return _targetWordUsage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_targetWordUsage);
  }

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
    return 'VocabChallengeResult(score: $score, targetWordUsage: $targetWordUsage, corrections: $corrections, feedback: $feedback, coinsEarned: $coinsEarned, starsEarned: $starsEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VocabChallengeResultImpl &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality().equals(
              other._targetWordUsage,
              _targetWordUsage,
            ) &&
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
    const DeepCollectionEquality().hash(_targetWordUsage),
    const DeepCollectionEquality().hash(_corrections),
    feedback,
    coinsEarned,
    starsEarned,
  );

  /// Create a copy of VocabChallengeResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VocabChallengeResultImplCopyWith<_$VocabChallengeResultImpl>
  get copyWith =>
      __$$VocabChallengeResultImplCopyWithImpl<_$VocabChallengeResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VocabChallengeResultImplToJson(this);
  }
}

abstract class _VocabChallengeResult implements VocabChallengeResult {
  const factory _VocabChallengeResult({
    @JsonKey(name: 'Score') required final int score,
    @JsonKey(name: 'TargetWordUsage')
    required final Map<String, bool> targetWordUsage,
    @JsonKey(name: 'Corrections')
    required final List<WritingCorrection> corrections,
    @JsonKey(name: 'Feedback') required final String feedback,
    @JsonKey(name: 'CoinsEarned') final int coinsEarned,
    @JsonKey(name: 'StarsEarned') final int starsEarned,
  }) = _$VocabChallengeResultImpl;

  factory _VocabChallengeResult.fromJson(Map<String, dynamic> json) =
      _$VocabChallengeResultImpl.fromJson;

  @override
  @JsonKey(name: 'Score')
  int get score;

  /// Her hedef kelimenin doğru kullanılıp kullanılmadığı: {"explore": true, "happy": false}
  @override
  @JsonKey(name: 'TargetWordUsage')
  Map<String, bool> get targetWordUsage;
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

  /// Create a copy of VocabChallengeResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VocabChallengeResultImplCopyWith<_$VocabChallengeResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}
