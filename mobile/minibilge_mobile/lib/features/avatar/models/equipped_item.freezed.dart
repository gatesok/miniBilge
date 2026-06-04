// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equipped_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EquippedItem _$EquippedItemFromJson(Map<String, dynamic> json) {
  return _EquippedItem.fromJson(json);
}

/// @nodoc
mixin _$EquippedItem {
  @JsonKey(name: 'ItemId')
  String get itemId => throw _privateConstructorUsedError;
  @JsonKey(name: 'Name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'ItemType')
  int get itemType => throw _privateConstructorUsedError;
  @JsonKey(name: 'ItemTypeName')
  String get itemTypeName => throw _privateConstructorUsedError;
  @JsonKey(name: 'ImageUrl')
  String get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'EquippedAt')
  DateTime get equippedAt => throw _privateConstructorUsedError;

  /// Serializes this EquippedItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EquippedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquippedItemCopyWith<EquippedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquippedItemCopyWith<$Res> {
  factory $EquippedItemCopyWith(
    EquippedItem value,
    $Res Function(EquippedItem) then,
  ) = _$EquippedItemCopyWithImpl<$Res, EquippedItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'ItemId') String itemId,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'ItemType') int itemType,
    @JsonKey(name: 'ItemTypeName') String itemTypeName,
    @JsonKey(name: 'ImageUrl') String imageUrl,
    @JsonKey(name: 'EquippedAt') DateTime equippedAt,
  });
}

/// @nodoc
class _$EquippedItemCopyWithImpl<$Res, $Val extends EquippedItem>
    implements $EquippedItemCopyWith<$Res> {
  _$EquippedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquippedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? name = null,
    Object? itemType = null,
    Object? itemTypeName = null,
    Object? imageUrl = null,
    Object? equippedAt = null,
  }) {
    return _then(
      _value.copyWith(
            itemId: null == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            itemType: null == itemType
                ? _value.itemType
                : itemType // ignore: cast_nullable_to_non_nullable
                      as int,
            itemTypeName: null == itemTypeName
                ? _value.itemTypeName
                : itemTypeName // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            equippedAt: null == equippedAt
                ? _value.equippedAt
                : equippedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EquippedItemImplCopyWith<$Res>
    implements $EquippedItemCopyWith<$Res> {
  factory _$$EquippedItemImplCopyWith(
    _$EquippedItemImpl value,
    $Res Function(_$EquippedItemImpl) then,
  ) = __$$EquippedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ItemId') String itemId,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'ItemType') int itemType,
    @JsonKey(name: 'ItemTypeName') String itemTypeName,
    @JsonKey(name: 'ImageUrl') String imageUrl,
    @JsonKey(name: 'EquippedAt') DateTime equippedAt,
  });
}

/// @nodoc
class __$$EquippedItemImplCopyWithImpl<$Res>
    extends _$EquippedItemCopyWithImpl<$Res, _$EquippedItemImpl>
    implements _$$EquippedItemImplCopyWith<$Res> {
  __$$EquippedItemImplCopyWithImpl(
    _$EquippedItemImpl _value,
    $Res Function(_$EquippedItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EquippedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? name = null,
    Object? itemType = null,
    Object? itemTypeName = null,
    Object? imageUrl = null,
    Object? equippedAt = null,
  }) {
    return _then(
      _$EquippedItemImpl(
        itemId: null == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        itemType: null == itemType
            ? _value.itemType
            : itemType // ignore: cast_nullable_to_non_nullable
                  as int,
        itemTypeName: null == itemTypeName
            ? _value.itemTypeName
            : itemTypeName // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        equippedAt: null == equippedAt
            ? _value.equippedAt
            : equippedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EquippedItemImpl implements _EquippedItem {
  const _$EquippedItemImpl({
    @JsonKey(name: 'ItemId') required this.itemId,
    @JsonKey(name: 'Name') required this.name,
    @JsonKey(name: 'ItemType') required this.itemType,
    @JsonKey(name: 'ItemTypeName') required this.itemTypeName,
    @JsonKey(name: 'ImageUrl') required this.imageUrl,
    @JsonKey(name: 'EquippedAt') required this.equippedAt,
  });

  factory _$EquippedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquippedItemImplFromJson(json);

  @override
  @JsonKey(name: 'ItemId')
  final String itemId;
  @override
  @JsonKey(name: 'Name')
  final String name;
  @override
  @JsonKey(name: 'ItemType')
  final int itemType;
  @override
  @JsonKey(name: 'ItemTypeName')
  final String itemTypeName;
  @override
  @JsonKey(name: 'ImageUrl')
  final String imageUrl;
  @override
  @JsonKey(name: 'EquippedAt')
  final DateTime equippedAt;

  @override
  String toString() {
    return 'EquippedItem(itemId: $itemId, name: $name, itemType: $itemType, itemTypeName: $itemTypeName, imageUrl: $imageUrl, equippedAt: $equippedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquippedItemImpl &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.itemType, itemType) ||
                other.itemType == itemType) &&
            (identical(other.itemTypeName, itemTypeName) ||
                other.itemTypeName == itemTypeName) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.equippedAt, equippedAt) ||
                other.equippedAt == equippedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemId,
    name,
    itemType,
    itemTypeName,
    imageUrl,
    equippedAt,
  );

  /// Create a copy of EquippedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquippedItemImplCopyWith<_$EquippedItemImpl> get copyWith =>
      __$$EquippedItemImplCopyWithImpl<_$EquippedItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EquippedItemImplToJson(this);
  }
}

abstract class _EquippedItem implements EquippedItem {
  const factory _EquippedItem({
    @JsonKey(name: 'ItemId') required final String itemId,
    @JsonKey(name: 'Name') required final String name,
    @JsonKey(name: 'ItemType') required final int itemType,
    @JsonKey(name: 'ItemTypeName') required final String itemTypeName,
    @JsonKey(name: 'ImageUrl') required final String imageUrl,
    @JsonKey(name: 'EquippedAt') required final DateTime equippedAt,
  }) = _$EquippedItemImpl;

  factory _EquippedItem.fromJson(Map<String, dynamic> json) =
      _$EquippedItemImpl.fromJson;

  @override
  @JsonKey(name: 'ItemId')
  String get itemId;
  @override
  @JsonKey(name: 'Name')
  String get name;
  @override
  @JsonKey(name: 'ItemType')
  int get itemType;
  @override
  @JsonKey(name: 'ItemTypeName')
  String get itemTypeName;
  @override
  @JsonKey(name: 'ImageUrl')
  String get imageUrl;
  @override
  @JsonKey(name: 'EquippedAt')
  DateTime get equippedAt;

  /// Create a copy of EquippedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquippedItemImplCopyWith<_$EquippedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
