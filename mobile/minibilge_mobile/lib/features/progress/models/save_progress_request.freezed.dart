// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'save_progress_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SaveProgressRequest _$SaveProgressRequestFromJson(Map<String, dynamic> json) {
  return _SaveProgressRequest.fromJson(json);
}

/// @nodoc
mixin _$SaveProgressRequest {
  @JsonKey(name: 'ChildId')
  String get childId => throw _privateConstructorUsedError;
  @JsonKey(name: 'LevelId')
  String get levelId => throw _privateConstructorUsedError;
  @JsonKey(name: 'CorrectCount')
  int get correctCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalQuestions')
  int get totalQuestions => throw _privateConstructorUsedError;
  @JsonKey(name: 'SuccessPercentage')
  double get successPercentage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SaveProgressRequestCopyWith<SaveProgressRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaveProgressRequestCopyWith<$Res> {
  factory $SaveProgressRequestCopyWith(
          SaveProgressRequest value, $Res Function(SaveProgressRequest) then) =
      _$SaveProgressRequestCopyWithImpl<$Res, SaveProgressRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'ChildId') String childId,
      @JsonKey(name: 'LevelId') String levelId,
      @JsonKey(name: 'CorrectCount') int correctCount,
      @JsonKey(name: 'TotalQuestions') int totalQuestions,
      @JsonKey(name: 'SuccessPercentage') double successPercentage});
}

/// @nodoc
class _$SaveProgressRequestCopyWithImpl<$Res, $Val extends SaveProgressRequest>
    implements $SaveProgressRequestCopyWith<$Res> {
  _$SaveProgressRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? levelId = null,
    Object? correctCount = null,
    Object? totalQuestions = null,
    Object? successPercentage = null,
  }) {
    return _then(_value.copyWith(
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      levelId: null == levelId
          ? _value.levelId
          : levelId // ignore: cast_nullable_to_non_nullable
              as String,
      correctCount: null == correctCount
          ? _value.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      successPercentage: null == successPercentage
          ? _value.successPercentage
          : successPercentage // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SaveProgressRequestImplCopyWith<$Res>
    implements $SaveProgressRequestCopyWith<$Res> {
  factory _$$SaveProgressRequestImplCopyWith(_$SaveProgressRequestImpl value,
          $Res Function(_$SaveProgressRequestImpl) then) =
      __$$SaveProgressRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'ChildId') String childId,
      @JsonKey(name: 'LevelId') String levelId,
      @JsonKey(name: 'CorrectCount') int correctCount,
      @JsonKey(name: 'TotalQuestions') int totalQuestions,
      @JsonKey(name: 'SuccessPercentage') double successPercentage});
}

/// @nodoc
class __$$SaveProgressRequestImplCopyWithImpl<$Res>
    extends _$SaveProgressRequestCopyWithImpl<$Res, _$SaveProgressRequestImpl>
    implements _$$SaveProgressRequestImplCopyWith<$Res> {
  __$$SaveProgressRequestImplCopyWithImpl(_$SaveProgressRequestImpl _value,
      $Res Function(_$SaveProgressRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childId = null,
    Object? levelId = null,
    Object? correctCount = null,
    Object? totalQuestions = null,
    Object? successPercentage = null,
  }) {
    return _then(_$SaveProgressRequestImpl(
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      levelId: null == levelId
          ? _value.levelId
          : levelId // ignore: cast_nullable_to_non_nullable
              as String,
      correctCount: null == correctCount
          ? _value.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      successPercentage: null == successPercentage
          ? _value.successPercentage
          : successPercentage // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SaveProgressRequestImpl implements _SaveProgressRequest {
  const _$SaveProgressRequestImpl(
      {@JsonKey(name: 'ChildId') required this.childId,
      @JsonKey(name: 'LevelId') required this.levelId,
      @JsonKey(name: 'CorrectCount') required this.correctCount,
      @JsonKey(name: 'TotalQuestions') required this.totalQuestions,
      @JsonKey(name: 'SuccessPercentage') required this.successPercentage});

  factory _$SaveProgressRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaveProgressRequestImplFromJson(json);

  @override
  @JsonKey(name: 'ChildId')
  final String childId;
  @override
  @JsonKey(name: 'LevelId')
  final String levelId;
  @override
  @JsonKey(name: 'CorrectCount')
  final int correctCount;
  @override
  @JsonKey(name: 'TotalQuestions')
  final int totalQuestions;
  @override
  @JsonKey(name: 'SuccessPercentage')
  final double successPercentage;

  @override
  String toString() {
    return 'SaveProgressRequest(childId: $childId, levelId: $levelId, correctCount: $correctCount, totalQuestions: $totalQuestions, successPercentage: $successPercentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaveProgressRequestImpl &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.levelId, levelId) || other.levelId == levelId) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.successPercentage, successPercentage) ||
                other.successPercentage == successPercentage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, childId, levelId, correctCount,
      totalQuestions, successPercentage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SaveProgressRequestImplCopyWith<_$SaveProgressRequestImpl> get copyWith =>
      __$$SaveProgressRequestImplCopyWithImpl<_$SaveProgressRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaveProgressRequestImplToJson(
      this,
    );
  }
}

abstract class _SaveProgressRequest implements SaveProgressRequest {
  const factory _SaveProgressRequest(
      {@JsonKey(name: 'ChildId') required final String childId,
      @JsonKey(name: 'LevelId') required final String levelId,
      @JsonKey(name: 'CorrectCount') required final int correctCount,
      @JsonKey(name: 'TotalQuestions') required final int totalQuestions,
      @JsonKey(name: 'SuccessPercentage')
      required final double successPercentage}) = _$SaveProgressRequestImpl;

  factory _SaveProgressRequest.fromJson(Map<String, dynamic> json) =
      _$SaveProgressRequestImpl.fromJson;

  @override
  @JsonKey(name: 'ChildId')
  String get childId;
  @override
  @JsonKey(name: 'LevelId')
  String get levelId;
  @override
  @JsonKey(name: 'CorrectCount')
  int get correctCount;
  @override
  @JsonKey(name: 'TotalQuestions')
  int get totalQuestions;
  @override
  @JsonKey(name: 'SuccessPercentage')
  double get successPercentage;
  @override
  @JsonKey(ignore: true)
  _$$SaveProgressRequestImplCopyWith<_$SaveProgressRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
