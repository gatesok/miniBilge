// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ParentProfileDto _$ParentProfileDtoFromJson(Map<String, dynamic> json) {
  return _ParentProfileDto.fromJson(json);
}

/// @nodoc
mixin _$ParentProfileDto {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'FirstName')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'LastName')
  String get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'PhoneNumber')
  String? get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'ChildrenCount')
  int get childrenCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ParentProfileDtoCopyWith<ParentProfileDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentProfileDtoCopyWith<$Res> {
  factory $ParentProfileDtoCopyWith(
          ParentProfileDto value, $Res Function(ParentProfileDto) then) =
      _$ParentProfileDtoCopyWithImpl<$Res, ParentProfileDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') String id,
      @JsonKey(name: 'FirstName') String firstName,
      @JsonKey(name: 'LastName') String lastName,
      @JsonKey(name: 'PhoneNumber') String? phoneNumber,
      @JsonKey(name: 'ChildrenCount') int childrenCount});
}

/// @nodoc
class _$ParentProfileDtoCopyWithImpl<$Res, $Val extends ParentProfileDto>
    implements $ParentProfileDtoCopyWith<$Res> {
  _$ParentProfileDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? phoneNumber = freezed,
    Object? childrenCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      childrenCount: null == childrenCount
          ? _value.childrenCount
          : childrenCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ParentProfileDtoImplCopyWith<$Res>
    implements $ParentProfileDtoCopyWith<$Res> {
  factory _$$ParentProfileDtoImplCopyWith(_$ParentProfileDtoImpl value,
          $Res Function(_$ParentProfileDtoImpl) then) =
      __$$ParentProfileDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') String id,
      @JsonKey(name: 'FirstName') String firstName,
      @JsonKey(name: 'LastName') String lastName,
      @JsonKey(name: 'PhoneNumber') String? phoneNumber,
      @JsonKey(name: 'ChildrenCount') int childrenCount});
}

/// @nodoc
class __$$ParentProfileDtoImplCopyWithImpl<$Res>
    extends _$ParentProfileDtoCopyWithImpl<$Res, _$ParentProfileDtoImpl>
    implements _$$ParentProfileDtoImplCopyWith<$Res> {
  __$$ParentProfileDtoImplCopyWithImpl(_$ParentProfileDtoImpl _value,
      $Res Function(_$ParentProfileDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? phoneNumber = freezed,
    Object? childrenCount = null,
  }) {
    return _then(_$ParentProfileDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      childrenCount: null == childrenCount
          ? _value.childrenCount
          : childrenCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ParentProfileDtoImpl implements _ParentProfileDto {
  const _$ParentProfileDtoImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'FirstName') required this.firstName,
      @JsonKey(name: 'LastName') required this.lastName,
      @JsonKey(name: 'PhoneNumber') this.phoneNumber,
      @JsonKey(name: 'ChildrenCount') required this.childrenCount});

  factory _$ParentProfileDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentProfileDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'FirstName')
  final String firstName;
  @override
  @JsonKey(name: 'LastName')
  final String lastName;
  @override
  @JsonKey(name: 'PhoneNumber')
  final String? phoneNumber;
  @override
  @JsonKey(name: 'ChildrenCount')
  final int childrenCount;

  @override
  String toString() {
    return 'ParentProfileDto(id: $id, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, childrenCount: $childrenCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentProfileDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.childrenCount, childrenCount) ||
                other.childrenCount == childrenCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, firstName, lastName, phoneNumber, childrenCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentProfileDtoImplCopyWith<_$ParentProfileDtoImpl> get copyWith =>
      __$$ParentProfileDtoImplCopyWithImpl<_$ParentProfileDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentProfileDtoImplToJson(
      this,
    );
  }
}

abstract class _ParentProfileDto implements ParentProfileDto {
  const factory _ParentProfileDto(
          {@JsonKey(name: 'Id') required final String id,
          @JsonKey(name: 'FirstName') required final String firstName,
          @JsonKey(name: 'LastName') required final String lastName,
          @JsonKey(name: 'PhoneNumber') final String? phoneNumber,
          @JsonKey(name: 'ChildrenCount') required final int childrenCount}) =
      _$ParentProfileDtoImpl;

  factory _ParentProfileDto.fromJson(Map<String, dynamic> json) =
      _$ParentProfileDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'FirstName')
  String get firstName;
  @override
  @JsonKey(name: 'LastName')
  String get lastName;
  @override
  @JsonKey(name: 'PhoneNumber')
  String? get phoneNumber;
  @override
  @JsonKey(name: 'ChildrenCount')
  int get childrenCount;
  @override
  @JsonKey(ignore: true)
  _$$ParentProfileDtoImplCopyWith<_$ParentProfileDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
