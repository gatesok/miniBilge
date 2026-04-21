// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChildProgress _$ChildProgressFromJson(Map<String, dynamic> json) {
  return _ChildProgress.fromJson(json);
}

/// @nodoc
mixin _$ChildProgress {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'ChildId')
  String get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalScore')
  int get totalScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalStars')
  int get totalStars => throw _privateConstructorUsedError;
  @JsonKey(name: 'CompletedLevelsCount')
  int get completedLevelsCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChildProgressCopyWith<ChildProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildProgressCopyWith<$Res> {
  factory $ChildProgressCopyWith(
          ChildProgress value, $Res Function(ChildProgress) then) =
      _$ChildProgressCopyWithImpl<$Res, ChildProgress>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') String id,
      @JsonKey(name: 'ChildId') String childId,
      @JsonKey(name: 'TotalScore') int totalScore,
      @JsonKey(name: 'TotalStars') int totalStars,
      @JsonKey(name: 'CompletedLevelsCount') int completedLevelsCount});
}

/// @nodoc
class _$ChildProgressCopyWithImpl<$Res, $Val extends ChildProgress>
    implements $ChildProgressCopyWith<$Res> {
  _$ChildProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? totalScore = null,
    Object? totalStars = null,
    Object? completedLevelsCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      totalScore: null == totalScore
          ? _value.totalScore
          : totalScore // ignore: cast_nullable_to_non_nullable
              as int,
      totalStars: null == totalStars
          ? _value.totalStars
          : totalStars // ignore: cast_nullable_to_non_nullable
              as int,
      completedLevelsCount: null == completedLevelsCount
          ? _value.completedLevelsCount
          : completedLevelsCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChildProgressImplCopyWith<$Res>
    implements $ChildProgressCopyWith<$Res> {
  factory _$$ChildProgressImplCopyWith(
          _$ChildProgressImpl value, $Res Function(_$ChildProgressImpl) then) =
      __$$ChildProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') String id,
      @JsonKey(name: 'ChildId') String childId,
      @JsonKey(name: 'TotalScore') int totalScore,
      @JsonKey(name: 'TotalStars') int totalStars,
      @JsonKey(name: 'CompletedLevelsCount') int completedLevelsCount});
}

/// @nodoc
class __$$ChildProgressImplCopyWithImpl<$Res>
    extends _$ChildProgressCopyWithImpl<$Res, _$ChildProgressImpl>
    implements _$$ChildProgressImplCopyWith<$Res> {
  __$$ChildProgressImplCopyWithImpl(
      _$ChildProgressImpl _value, $Res Function(_$ChildProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? totalScore = null,
    Object? totalStars = null,
    Object? completedLevelsCount = null,
  }) {
    return _then(_$ChildProgressImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      totalScore: null == totalScore
          ? _value.totalScore
          : totalScore // ignore: cast_nullable_to_non_nullable
              as int,
      totalStars: null == totalStars
          ? _value.totalStars
          : totalStars // ignore: cast_nullable_to_non_nullable
              as int,
      completedLevelsCount: null == completedLevelsCount
          ? _value.completedLevelsCount
          : completedLevelsCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChildProgressImpl implements _ChildProgress {
  const _$ChildProgressImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'ChildId') required this.childId,
      @JsonKey(name: 'TotalScore') required this.totalScore,
      @JsonKey(name: 'TotalStars') required this.totalStars,
      @JsonKey(name: 'CompletedLevelsCount')
      required this.completedLevelsCount});

  factory _$ChildProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChildProgressImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'ChildId')
  final String childId;
  @override
  @JsonKey(name: 'TotalScore')
  final int totalScore;
  @override
  @JsonKey(name: 'TotalStars')
  final int totalStars;
  @override
  @JsonKey(name: 'CompletedLevelsCount')
  final int completedLevelsCount;

  @override
  String toString() {
    return 'ChildProgress(id: $id, childId: $childId, totalScore: $totalScore, totalStars: $totalStars, completedLevelsCount: $completedLevelsCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildProgressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.totalStars, totalStars) ||
                other.totalStars == totalStars) &&
            (identical(other.completedLevelsCount, completedLevelsCount) ||
                other.completedLevelsCount == completedLevelsCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, childId, totalScore, totalStars, completedLevelsCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildProgressImplCopyWith<_$ChildProgressImpl> get copyWith =>
      __$$ChildProgressImplCopyWithImpl<_$ChildProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChildProgressImplToJson(
      this,
    );
  }
}

abstract class _ChildProgress implements ChildProgress {
  const factory _ChildProgress(
      {@JsonKey(name: 'Id') required final String id,
      @JsonKey(name: 'ChildId') required final String childId,
      @JsonKey(name: 'TotalScore') required final int totalScore,
      @JsonKey(name: 'TotalStars') required final int totalStars,
      @JsonKey(name: 'CompletedLevelsCount')
      required final int completedLevelsCount}) = _$ChildProgressImpl;

  factory _ChildProgress.fromJson(Map<String, dynamic> json) =
      _$ChildProgressImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'ChildId')
  String get childId;
  @override
  @JsonKey(name: 'TotalScore')
  int get totalScore;
  @override
  @JsonKey(name: 'TotalStars')
  int get totalStars;
  @override
  @JsonKey(name: 'CompletedLevelsCount')
  int get completedLevelsCount;
  @override
  @JsonKey(ignore: true)
  _$$ChildProgressImplCopyWith<_$ChildProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
