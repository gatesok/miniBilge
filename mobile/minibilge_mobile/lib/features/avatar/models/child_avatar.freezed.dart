// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_avatar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChildAvatar _$ChildAvatarFromJson(Map<String, dynamic> json) {
  return _ChildAvatar.fromJson(json);
}

/// @nodoc
mixin _$ChildAvatar {
  @JsonKey(name: 'ChildProfileId')
  String get childProfileId => throw _privateConstructorUsedError;
  @JsonKey(name: 'ChildName')
  String get childName => throw _privateConstructorUsedError;
  @JsonKey(name: 'Avatar')
  Avatar? get avatar => throw _privateConstructorUsedError;
  @JsonKey(name: 'EquippedItems')
  List<EquippedItem> get equippedItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalPoints')
  int get totalPoints => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChildAvatarCopyWith<ChildAvatar> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildAvatarCopyWith<$Res> {
  factory $ChildAvatarCopyWith(
          ChildAvatar value, $Res Function(ChildAvatar) then) =
      _$ChildAvatarCopyWithImpl<$Res, ChildAvatar>;
  @useResult
  $Res call(
      {@JsonKey(name: 'ChildProfileId') String childProfileId,
      @JsonKey(name: 'ChildName') String childName,
      @JsonKey(name: 'Avatar') Avatar? avatar,
      @JsonKey(name: 'EquippedItems') List<EquippedItem> equippedItems,
      @JsonKey(name: 'TotalPoints') int totalPoints});

  $AvatarCopyWith<$Res>? get avatar;
}

/// @nodoc
class _$ChildAvatarCopyWithImpl<$Res, $Val extends ChildAvatar>
    implements $ChildAvatarCopyWith<$Res> {
  _$ChildAvatarCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childProfileId = null,
    Object? childName = null,
    Object? avatar = freezed,
    Object? equippedItems = null,
    Object? totalPoints = null,
  }) {
    return _then(_value.copyWith(
      childProfileId: null == childProfileId
          ? _value.childProfileId
          : childProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      childName: null == childName
          ? _value.childName
          : childName // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as Avatar?,
      equippedItems: null == equippedItems
          ? _value.equippedItems
          : equippedItems // ignore: cast_nullable_to_non_nullable
              as List<EquippedItem>,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AvatarCopyWith<$Res>? get avatar {
    if (_value.avatar == null) {
      return null;
    }

    return $AvatarCopyWith<$Res>(_value.avatar!, (value) {
      return _then(_value.copyWith(avatar: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChildAvatarImplCopyWith<$Res>
    implements $ChildAvatarCopyWith<$Res> {
  factory _$$ChildAvatarImplCopyWith(
          _$ChildAvatarImpl value, $Res Function(_$ChildAvatarImpl) then) =
      __$$ChildAvatarImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'ChildProfileId') String childProfileId,
      @JsonKey(name: 'ChildName') String childName,
      @JsonKey(name: 'Avatar') Avatar? avatar,
      @JsonKey(name: 'EquippedItems') List<EquippedItem> equippedItems,
      @JsonKey(name: 'TotalPoints') int totalPoints});

  @override
  $AvatarCopyWith<$Res>? get avatar;
}

/// @nodoc
class __$$ChildAvatarImplCopyWithImpl<$Res>
    extends _$ChildAvatarCopyWithImpl<$Res, _$ChildAvatarImpl>
    implements _$$ChildAvatarImplCopyWith<$Res> {
  __$$ChildAvatarImplCopyWithImpl(
      _$ChildAvatarImpl _value, $Res Function(_$ChildAvatarImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childProfileId = null,
    Object? childName = null,
    Object? avatar = freezed,
    Object? equippedItems = null,
    Object? totalPoints = null,
  }) {
    return _then(_$ChildAvatarImpl(
      childProfileId: null == childProfileId
          ? _value.childProfileId
          : childProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      childName: null == childName
          ? _value.childName
          : childName // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as Avatar?,
      equippedItems: null == equippedItems
          ? _value._equippedItems
          : equippedItems // ignore: cast_nullable_to_non_nullable
              as List<EquippedItem>,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChildAvatarImpl implements _ChildAvatar {
  const _$ChildAvatarImpl(
      {@JsonKey(name: 'ChildProfileId') required this.childProfileId,
      @JsonKey(name: 'ChildName') required this.childName,
      @JsonKey(name: 'Avatar') this.avatar,
      @JsonKey(name: 'EquippedItems')
      final List<EquippedItem> equippedItems = const [],
      @JsonKey(name: 'TotalPoints') this.totalPoints = 0})
      : _equippedItems = equippedItems;

  factory _$ChildAvatarImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChildAvatarImplFromJson(json);

  @override
  @JsonKey(name: 'ChildProfileId')
  final String childProfileId;
  @override
  @JsonKey(name: 'ChildName')
  final String childName;
  @override
  @JsonKey(name: 'Avatar')
  final Avatar? avatar;
  final List<EquippedItem> _equippedItems;
  @override
  @JsonKey(name: 'EquippedItems')
  List<EquippedItem> get equippedItems {
    if (_equippedItems is EqualUnmodifiableListView) return _equippedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equippedItems);
  }

  @override
  @JsonKey(name: 'TotalPoints')
  final int totalPoints;

  @override
  String toString() {
    return 'ChildAvatar(childProfileId: $childProfileId, childName: $childName, avatar: $avatar, equippedItems: $equippedItems, totalPoints: $totalPoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildAvatarImpl &&
            (identical(other.childProfileId, childProfileId) ||
                other.childProfileId == childProfileId) &&
            (identical(other.childName, childName) ||
                other.childName == childName) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            const DeepCollectionEquality()
                .equals(other._equippedItems, _equippedItems) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, childProfileId, childName,
      avatar, const DeepCollectionEquality().hash(_equippedItems), totalPoints);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildAvatarImplCopyWith<_$ChildAvatarImpl> get copyWith =>
      __$$ChildAvatarImplCopyWithImpl<_$ChildAvatarImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChildAvatarImplToJson(
      this,
    );
  }
}

abstract class _ChildAvatar implements ChildAvatar {
  const factory _ChildAvatar(
      {@JsonKey(name: 'ChildProfileId') required final String childProfileId,
      @JsonKey(name: 'ChildName') required final String childName,
      @JsonKey(name: 'Avatar') final Avatar? avatar,
      @JsonKey(name: 'EquippedItems') final List<EquippedItem> equippedItems,
      @JsonKey(name: 'TotalPoints') final int totalPoints}) = _$ChildAvatarImpl;

  factory _ChildAvatar.fromJson(Map<String, dynamic> json) =
      _$ChildAvatarImpl.fromJson;

  @override
  @JsonKey(name: 'ChildProfileId')
  String get childProfileId;
  @override
  @JsonKey(name: 'ChildName')
  String get childName;
  @override
  @JsonKey(name: 'Avatar')
  Avatar? get avatar;
  @override
  @JsonKey(name: 'EquippedItems')
  List<EquippedItem> get equippedItems;
  @override
  @JsonKey(name: 'TotalPoints')
  int get totalPoints;
  @override
  @JsonKey(ignore: true)
  _$$ChildAvatarImplCopyWith<_$ChildAvatarImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
