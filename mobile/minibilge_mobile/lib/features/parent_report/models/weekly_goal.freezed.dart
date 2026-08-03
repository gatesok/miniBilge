// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WeeklyGoal _$WeeklyGoalFromJson(Map<String, dynamic> json) {
  return _WeeklyGoal.fromJson(json);
}

/// @nodoc
mixin _$WeeklyGoal {
  @JsonKey(name: 'ChildId')
  String get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'WeeklyStudyMinutesGoal')
  int? get weeklyStudyMinutesGoal => throw _privateConstructorUsedError;
  @JsonKey(name: 'FocusTopicId')
  String? get focusTopicId => throw _privateConstructorUsedError;
  @JsonKey(name: 'FocusTopicName')
  String? get focusTopicName => throw _privateConstructorUsedError;
  @JsonKey(name: 'WeekStart')
  DateTime get weekStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'WeekEnd')
  DateTime get weekEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'StudyMinutesThisWeek')
  int get studyMinutesThisWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'QuestionsThisWeek')
  int get questionsThisWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'FocusTopicSuccessRate')
  double? get focusTopicSuccessRate => throw _privateConstructorUsedError;

  /// Serializes this WeeklyGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyGoalCopyWith<WeeklyGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyGoalCopyWith<$Res> {
  factory $WeeklyGoalCopyWith(
    WeeklyGoal value,
    $Res Function(WeeklyGoal) then,
  ) = _$WeeklyGoalCopyWithImpl<$Res, WeeklyGoal>;
  @useResult
  $Res call({
    @JsonKey(name: 'ChildId') String childId,
    @JsonKey(name: 'WeeklyStudyMinutesGoal') int? weeklyStudyMinutesGoal,
    @JsonKey(name: 'FocusTopicId') String? focusTopicId,
    @JsonKey(name: 'FocusTopicName') String? focusTopicName,
    @JsonKey(name: 'WeekStart') DateTime weekStart,
    @JsonKey(name: 'WeekEnd') DateTime weekEnd,
    @JsonKey(name: 'StudyMinutesThisWeek') int studyMinutesThisWeek,
    @JsonKey(name: 'QuestionsThisWeek') int questionsThisWeek,
    @JsonKey(name: 'FocusTopicSuccessRate') double? focusTopicSuccessRate,
  });
}

/// @nodoc
class _$WeeklyGoalCopyWithImpl<$Res, $Val extends WeeklyGoal>
    implements $WeeklyGoalCopyWith<$Res> {
  _$WeeklyGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? weeklyStudyMinutesGoal = freezed,
    Object? focusTopicId = freezed,
    Object? focusTopicName = freezed,
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? studyMinutesThisWeek = null,
    Object? questionsThisWeek = null,
    Object? focusTopicSuccessRate = freezed,
  }) {
    return _then(
      _value.copyWith(
            childId: null == childId
                ? _value.childId
                : childId // ignore: cast_nullable_to_non_nullable
                      as String,
            weeklyStudyMinutesGoal: freezed == weeklyStudyMinutesGoal
                ? _value.weeklyStudyMinutesGoal
                : weeklyStudyMinutesGoal // ignore: cast_nullable_to_non_nullable
                      as int?,
            focusTopicId: freezed == focusTopicId
                ? _value.focusTopicId
                : focusTopicId // ignore: cast_nullable_to_non_nullable
                      as String?,
            focusTopicName: freezed == focusTopicName
                ? _value.focusTopicName
                : focusTopicName // ignore: cast_nullable_to_non_nullable
                      as String?,
            weekStart: null == weekStart
                ? _value.weekStart
                : weekStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            weekEnd: null == weekEnd
                ? _value.weekEnd
                : weekEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            studyMinutesThisWeek: null == studyMinutesThisWeek
                ? _value.studyMinutesThisWeek
                : studyMinutesThisWeek // ignore: cast_nullable_to_non_nullable
                      as int,
            questionsThisWeek: null == questionsThisWeek
                ? _value.questionsThisWeek
                : questionsThisWeek // ignore: cast_nullable_to_non_nullable
                      as int,
            focusTopicSuccessRate: freezed == focusTopicSuccessRate
                ? _value.focusTopicSuccessRate
                : focusTopicSuccessRate // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeeklyGoalImplCopyWith<$Res>
    implements $WeeklyGoalCopyWith<$Res> {
  factory _$$WeeklyGoalImplCopyWith(
    _$WeeklyGoalImpl value,
    $Res Function(_$WeeklyGoalImpl) then,
  ) = __$$WeeklyGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ChildId') String childId,
    @JsonKey(name: 'WeeklyStudyMinutesGoal') int? weeklyStudyMinutesGoal,
    @JsonKey(name: 'FocusTopicId') String? focusTopicId,
    @JsonKey(name: 'FocusTopicName') String? focusTopicName,
    @JsonKey(name: 'WeekStart') DateTime weekStart,
    @JsonKey(name: 'WeekEnd') DateTime weekEnd,
    @JsonKey(name: 'StudyMinutesThisWeek') int studyMinutesThisWeek,
    @JsonKey(name: 'QuestionsThisWeek') int questionsThisWeek,
    @JsonKey(name: 'FocusTopicSuccessRate') double? focusTopicSuccessRate,
  });
}

/// @nodoc
class __$$WeeklyGoalImplCopyWithImpl<$Res>
    extends _$WeeklyGoalCopyWithImpl<$Res, _$WeeklyGoalImpl>
    implements _$$WeeklyGoalImplCopyWith<$Res> {
  __$$WeeklyGoalImplCopyWithImpl(
    _$WeeklyGoalImpl _value,
    $Res Function(_$WeeklyGoalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeeklyGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? weeklyStudyMinutesGoal = freezed,
    Object? focusTopicId = freezed,
    Object? focusTopicName = freezed,
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? studyMinutesThisWeek = null,
    Object? questionsThisWeek = null,
    Object? focusTopicSuccessRate = freezed,
  }) {
    return _then(
      _$WeeklyGoalImpl(
        childId: null == childId
            ? _value.childId
            : childId // ignore: cast_nullable_to_non_nullable
                  as String,
        weeklyStudyMinutesGoal: freezed == weeklyStudyMinutesGoal
            ? _value.weeklyStudyMinutesGoal
            : weeklyStudyMinutesGoal // ignore: cast_nullable_to_non_nullable
                  as int?,
        focusTopicId: freezed == focusTopicId
            ? _value.focusTopicId
            : focusTopicId // ignore: cast_nullable_to_non_nullable
                  as String?,
        focusTopicName: freezed == focusTopicName
            ? _value.focusTopicName
            : focusTopicName // ignore: cast_nullable_to_non_nullable
                  as String?,
        weekStart: null == weekStart
            ? _value.weekStart
            : weekStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        weekEnd: null == weekEnd
            ? _value.weekEnd
            : weekEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        studyMinutesThisWeek: null == studyMinutesThisWeek
            ? _value.studyMinutesThisWeek
            : studyMinutesThisWeek // ignore: cast_nullable_to_non_nullable
                  as int,
        questionsThisWeek: null == questionsThisWeek
            ? _value.questionsThisWeek
            : questionsThisWeek // ignore: cast_nullable_to_non_nullable
                  as int,
        focusTopicSuccessRate: freezed == focusTopicSuccessRate
            ? _value.focusTopicSuccessRate
            : focusTopicSuccessRate // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyGoalImpl implements _WeeklyGoal {
  const _$WeeklyGoalImpl({
    @JsonKey(name: 'ChildId') required this.childId,
    @JsonKey(name: 'WeeklyStudyMinutesGoal') this.weeklyStudyMinutesGoal,
    @JsonKey(name: 'FocusTopicId') this.focusTopicId,
    @JsonKey(name: 'FocusTopicName') this.focusTopicName,
    @JsonKey(name: 'WeekStart') required this.weekStart,
    @JsonKey(name: 'WeekEnd') required this.weekEnd,
    @JsonKey(name: 'StudyMinutesThisWeek') required this.studyMinutesThisWeek,
    @JsonKey(name: 'QuestionsThisWeek') required this.questionsThisWeek,
    @JsonKey(name: 'FocusTopicSuccessRate') this.focusTopicSuccessRate,
  });

  factory _$WeeklyGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyGoalImplFromJson(json);

  @override
  @JsonKey(name: 'ChildId')
  final String childId;
  @override
  @JsonKey(name: 'WeeklyStudyMinutesGoal')
  final int? weeklyStudyMinutesGoal;
  @override
  @JsonKey(name: 'FocusTopicId')
  final String? focusTopicId;
  @override
  @JsonKey(name: 'FocusTopicName')
  final String? focusTopicName;
  @override
  @JsonKey(name: 'WeekStart')
  final DateTime weekStart;
  @override
  @JsonKey(name: 'WeekEnd')
  final DateTime weekEnd;
  @override
  @JsonKey(name: 'StudyMinutesThisWeek')
  final int studyMinutesThisWeek;
  @override
  @JsonKey(name: 'QuestionsThisWeek')
  final int questionsThisWeek;
  @override
  @JsonKey(name: 'FocusTopicSuccessRate')
  final double? focusTopicSuccessRate;

  @override
  String toString() {
    return 'WeeklyGoal(childId: $childId, weeklyStudyMinutesGoal: $weeklyStudyMinutesGoal, focusTopicId: $focusTopicId, focusTopicName: $focusTopicName, weekStart: $weekStart, weekEnd: $weekEnd, studyMinutesThisWeek: $studyMinutesThisWeek, questionsThisWeek: $questionsThisWeek, focusTopicSuccessRate: $focusTopicSuccessRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyGoalImpl &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.weeklyStudyMinutesGoal, weeklyStudyMinutesGoal) ||
                other.weeklyStudyMinutesGoal == weeklyStudyMinutesGoal) &&
            (identical(other.focusTopicId, focusTopicId) ||
                other.focusTopicId == focusTopicId) &&
            (identical(other.focusTopicName, focusTopicName) ||
                other.focusTopicName == focusTopicName) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.weekEnd, weekEnd) || other.weekEnd == weekEnd) &&
            (identical(other.studyMinutesThisWeek, studyMinutesThisWeek) ||
                other.studyMinutesThisWeek == studyMinutesThisWeek) &&
            (identical(other.questionsThisWeek, questionsThisWeek) ||
                other.questionsThisWeek == questionsThisWeek) &&
            (identical(other.focusTopicSuccessRate, focusTopicSuccessRate) ||
                other.focusTopicSuccessRate == focusTopicSuccessRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    childId,
    weeklyStudyMinutesGoal,
    focusTopicId,
    focusTopicName,
    weekStart,
    weekEnd,
    studyMinutesThisWeek,
    questionsThisWeek,
    focusTopicSuccessRate,
  );

  /// Create a copy of WeeklyGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyGoalImplCopyWith<_$WeeklyGoalImpl> get copyWith =>
      __$$WeeklyGoalImplCopyWithImpl<_$WeeklyGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyGoalImplToJson(this);
  }
}

abstract class _WeeklyGoal implements WeeklyGoal {
  const factory _WeeklyGoal({
    @JsonKey(name: 'ChildId') required final String childId,
    @JsonKey(name: 'WeeklyStudyMinutesGoal') final int? weeklyStudyMinutesGoal,
    @JsonKey(name: 'FocusTopicId') final String? focusTopicId,
    @JsonKey(name: 'FocusTopicName') final String? focusTopicName,
    @JsonKey(name: 'WeekStart') required final DateTime weekStart,
    @JsonKey(name: 'WeekEnd') required final DateTime weekEnd,
    @JsonKey(name: 'StudyMinutesThisWeek')
    required final int studyMinutesThisWeek,
    @JsonKey(name: 'QuestionsThisWeek') required final int questionsThisWeek,
    @JsonKey(name: 'FocusTopicSuccessRate') final double? focusTopicSuccessRate,
  }) = _$WeeklyGoalImpl;

  factory _WeeklyGoal.fromJson(Map<String, dynamic> json) =
      _$WeeklyGoalImpl.fromJson;

  @override
  @JsonKey(name: 'ChildId')
  String get childId;
  @override
  @JsonKey(name: 'WeeklyStudyMinutesGoal')
  int? get weeklyStudyMinutesGoal;
  @override
  @JsonKey(name: 'FocusTopicId')
  String? get focusTopicId;
  @override
  @JsonKey(name: 'FocusTopicName')
  String? get focusTopicName;
  @override
  @JsonKey(name: 'WeekStart')
  DateTime get weekStart;
  @override
  @JsonKey(name: 'WeekEnd')
  DateTime get weekEnd;
  @override
  @JsonKey(name: 'StudyMinutesThisWeek')
  int get studyMinutesThisWeek;
  @override
  @JsonKey(name: 'QuestionsThisWeek')
  int get questionsThisWeek;
  @override
  @JsonKey(name: 'FocusTopicSuccessRate')
  double? get focusTopicSuccessRate;

  /// Create a copy of WeeklyGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyGoalImplCopyWith<_$WeeklyGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
