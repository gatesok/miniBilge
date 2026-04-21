// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_item_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PurchaseItemRequest _$PurchaseItemRequestFromJson(Map<String, dynamic> json) {
  return _PurchaseItemRequest.fromJson(json);
}

/// @nodoc
mixin _$PurchaseItemRequest {
  @JsonKey(name: 'ChildProfileId')
  String get childProfileId => throw _privateConstructorUsedError;
  @JsonKey(name: 'ItemId')
  String get itemId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PurchaseItemRequestCopyWith<PurchaseItemRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseItemRequestCopyWith<$Res> {
  factory $PurchaseItemRequestCopyWith(
          PurchaseItemRequest value, $Res Function(PurchaseItemRequest) then) =
      _$PurchaseItemRequestCopyWithImpl<$Res, PurchaseItemRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'ChildProfileId') String childProfileId,
      @JsonKey(name: 'ItemId') String itemId});
}

/// @nodoc
class _$PurchaseItemRequestCopyWithImpl<$Res, $Val extends PurchaseItemRequest>
    implements $PurchaseItemRequestCopyWith<$Res> {
  _$PurchaseItemRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childProfileId = null,
    Object? itemId = null,
  }) {
    return _then(_value.copyWith(
      childProfileId: null == childProfileId
          ? _value.childProfileId
          : childProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurchaseItemRequestImplCopyWith<$Res>
    implements $PurchaseItemRequestCopyWith<$Res> {
  factory _$$PurchaseItemRequestImplCopyWith(_$PurchaseItemRequestImpl value,
          $Res Function(_$PurchaseItemRequestImpl) then) =
      __$$PurchaseItemRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'ChildProfileId') String childProfileId,
      @JsonKey(name: 'ItemId') String itemId});
}

/// @nodoc
class __$$PurchaseItemRequestImplCopyWithImpl<$Res>
    extends _$PurchaseItemRequestCopyWithImpl<$Res, _$PurchaseItemRequestImpl>
    implements _$$PurchaseItemRequestImplCopyWith<$Res> {
  __$$PurchaseItemRequestImplCopyWithImpl(_$PurchaseItemRequestImpl _value,
      $Res Function(_$PurchaseItemRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? childProfileId = null,
    Object? itemId = null,
  }) {
    return _then(_$PurchaseItemRequestImpl(
      childProfileId: null == childProfileId
          ? _value.childProfileId
          : childProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseItemRequestImpl implements _PurchaseItemRequest {
  const _$PurchaseItemRequestImpl(
      {@JsonKey(name: 'ChildProfileId') required this.childProfileId,
      @JsonKey(name: 'ItemId') required this.itemId});

  factory _$PurchaseItemRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseItemRequestImplFromJson(json);

  @override
  @JsonKey(name: 'ChildProfileId')
  final String childProfileId;
  @override
  @JsonKey(name: 'ItemId')
  final String itemId;

  @override
  String toString() {
    return 'PurchaseItemRequest(childProfileId: $childProfileId, itemId: $itemId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseItemRequestImpl &&
            (identical(other.childProfileId, childProfileId) ||
                other.childProfileId == childProfileId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, childProfileId, itemId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseItemRequestImplCopyWith<_$PurchaseItemRequestImpl> get copyWith =>
      __$$PurchaseItemRequestImplCopyWithImpl<_$PurchaseItemRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseItemRequestImplToJson(
      this,
    );
  }
}

abstract class _PurchaseItemRequest implements PurchaseItemRequest {
  const factory _PurchaseItemRequest(
      {@JsonKey(name: 'ChildProfileId') required final String childProfileId,
      @JsonKey(name: 'ItemId')
      required final String itemId}) = _$PurchaseItemRequestImpl;

  factory _PurchaseItemRequest.fromJson(Map<String, dynamic> json) =
      _$PurchaseItemRequestImpl.fromJson;

  @override
  @JsonKey(name: 'ChildProfileId')
  String get childProfileId;
  @override
  @JsonKey(name: 'ItemId')
  String get itemId;
  @override
  @JsonKey(ignore: true)
  _$$PurchaseItemRequestImplCopyWith<_$PurchaseItemRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
