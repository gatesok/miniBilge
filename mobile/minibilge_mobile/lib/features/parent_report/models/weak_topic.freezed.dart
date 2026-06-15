// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weak_topic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WeakTopic _$WeakTopicFromJson(Map<String, dynamic> json) {
  return _WeakTopic.fromJson(json);
}

/// @nodoc
mixin _$WeakTopic {
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

  /// Serializes this WeakTopic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeakTopic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeakTopicCopyWith<WeakTopic> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeakTopicCopyWith<$Res> {
  factory $WeakTopicCopyWith(WeakTopic value, $Res Function(WeakTopic) then) =
      _$WeakTopicCopyWithImpl<$Res, WeakTopic>;
  @useResult
  $Res call({
    @JsonKey(name: 'TopicId') String topicId,
    @JsonKey(name: 'TopicName') String topicName,
    @JsonKey(name: 'SubjectName') String subjectName,
    @JsonKey(name: 'TotalAttempts') int totalAttempts,
    @JsonKey(name: 'CorrectAttempts') int correctAttempts,
    @JsonKey(name: 'SuccessRate') double successRate,
  });
}

/// @nodoc
class _$WeakTopicCopyWithImpl<$Res, $Val extends WeakTopic>
    implements $WeakTopicCopyWith<$Res> {
  _$WeakTopicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeakTopic
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeakTopicImplCopyWith<$Res>
    implements $WeakTopicCopyWith<$Res> {
  factory _$$WeakTopicImplCopyWith(
    _$WeakTopicImpl value,
    $Res Function(_$WeakTopicImpl) then,
  ) = __$$WeakTopicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'TopicId') String topicId,
    @JsonKey(name: 'TopicName') String topicName,
    @JsonKey(name: 'SubjectName') String subjectName,
    @JsonKey(name: 'TotalAttempts') int totalAttempts,
    @JsonKey(name: 'CorrectAttempts') int correctAttempts,
    @JsonKey(name: 'SuccessRate') double successRate,
  });
}

/// @nodoc
class __$$WeakTopicImplCopyWithImpl<$Res>
    extends _$WeakTopicCopyWithImpl<$Res, _$WeakTopicImpl>
    implements _$$WeakTopicImplCopyWith<$Res> {
  __$$WeakTopicImplCopyWithImpl(
    _$WeakTopicImpl _value,
    $Res Function(_$WeakTopicImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeakTopic
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
  }) {
    return _then(
      _$WeakTopicImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeakTopicImpl implements _WeakTopic {
  const _$WeakTopicImpl({
    @JsonKey(name: 'TopicId') required this.topicId,
    @JsonKey(name: 'TopicName') required this.topicName,
    @JsonKey(name: 'SubjectName') required this.subjectName,
    @JsonKey(name: 'TotalAttempts') required this.totalAttempts,
    @JsonKey(name: 'CorrectAttempts') required this.correctAttempts,
    @JsonKey(name: 'SuccessRate') required this.successRate,
  });

  factory _$WeakTopicImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeakTopicImplFromJson(json);

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
  String toString() {
    return 'WeakTopic(topicId: $topicId, topicName: $topicName, subjectName: $subjectName, totalAttempts: $totalAttempts, correctAttempts: $correctAttempts, successRate: $successRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeakTopicImpl &&
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
                other.successRate == successRate));
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
  );

  /// Create a copy of WeakTopic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeakTopicImplCopyWith<_$WeakTopicImpl> get copyWith =>
      __$$WeakTopicImplCopyWithImpl<_$WeakTopicImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeakTopicImplToJson(this);
  }
}

abstract class _WeakTopic implements WeakTopic {
  const factory _WeakTopic({
    @JsonKey(name: 'TopicId') required final String topicId,
    @JsonKey(name: 'TopicName') required final String topicName,
    @JsonKey(name: 'SubjectName') required final String subjectName,
    @JsonKey(name: 'TotalAttempts') required final int totalAttempts,
    @JsonKey(name: 'CorrectAttempts') required final int correctAttempts,
    @JsonKey(name: 'SuccessRate') required final double successRate,
  }) = _$WeakTopicImpl;

  factory _WeakTopic.fromJson(Map<String, dynamic> json) =
      _$WeakTopicImpl.fromJson;

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

  /// Create a copy of WeakTopic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeakTopicImplCopyWith<_$WeakTopicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
