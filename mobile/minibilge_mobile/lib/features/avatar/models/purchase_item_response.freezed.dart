// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_item_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PurchaseItemResponse _$PurchaseItemResponseFromJson(Map<String, dynamic> json) {
  return _PurchaseItemResponse.fromJson(json);
}

/// @nodoc
mixin _$PurchaseItemResponse {
  @JsonKey(name: 'Success')
  bool get success => throw _privateConstructorUsedError;
  @JsonKey(name: 'Message')
  String get message => throw _privateConstructorUsedError;
  @JsonKey(name: 'RemainingPoints')
  int get remainingPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'PurchasedItem')
  AvatarItem? get purchasedItem => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PurchaseItemResponseCopyWith<PurchaseItemResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseItemResponseCopyWith<$Res> {
  factory $PurchaseItemResponseCopyWith(PurchaseItemResponse value,
          $Res Function(PurchaseItemResponse) then) =
      _$PurchaseItemResponseCopyWithImpl<$Res, PurchaseItemResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Success') bool success,
      @JsonKey(name: 'Message') String message,
      @JsonKey(name: 'RemainingPoints') int remainingPoints,
      @JsonKey(name: 'PurchasedItem') AvatarItem? purchasedItem});

  $AvatarItemCopyWith<$Res>? get purchasedItem;
}

/// @nodoc
class _$PurchaseItemResponseCopyWithImpl<$Res,
        $Val extends PurchaseItemResponse>
    implements $PurchaseItemResponseCopyWith<$Res> {
  _$PurchaseItemResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? remainingPoints = null,
    Object? purchasedItem = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      remainingPoints: null == remainingPoints
          ? _value.remainingPoints
          : remainingPoints // ignore: cast_nullable_to_non_nullable
              as int,
      purchasedItem: freezed == purchasedItem
          ? _value.purchasedItem
          : purchasedItem // ignore: cast_nullable_to_non_nullable
              as AvatarItem?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AvatarItemCopyWith<$Res>? get purchasedItem {
    if (_value.purchasedItem == null) {
      return null;
    }

    return $AvatarItemCopyWith<$Res>(_value.purchasedItem!, (value) {
      return _then(_value.copyWith(purchasedItem: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PurchaseItemResponseImplCopyWith<$Res>
    implements $PurchaseItemResponseCopyWith<$Res> {
  factory _$$PurchaseItemResponseImplCopyWith(_$PurchaseItemResponseImpl value,
          $Res Function(_$PurchaseItemResponseImpl) then) =
      __$$PurchaseItemResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Success') bool success,
      @JsonKey(name: 'Message') String message,
      @JsonKey(name: 'RemainingPoints') int remainingPoints,
      @JsonKey(name: 'PurchasedItem') AvatarItem? purchasedItem});

  @override
  $AvatarItemCopyWith<$Res>? get purchasedItem;
}

/// @nodoc
class __$$PurchaseItemResponseImplCopyWithImpl<$Res>
    extends _$PurchaseItemResponseCopyWithImpl<$Res, _$PurchaseItemResponseImpl>
    implements _$$PurchaseItemResponseImplCopyWith<$Res> {
  __$$PurchaseItemResponseImplCopyWithImpl(_$PurchaseItemResponseImpl _value,
      $Res Function(_$PurchaseItemResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? remainingPoints = null,
    Object? purchasedItem = freezed,
  }) {
    return _then(_$PurchaseItemResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      remainingPoints: null == remainingPoints
          ? _value.remainingPoints
          : remainingPoints // ignore: cast_nullable_to_non_nullable
              as int,
      purchasedItem: freezed == purchasedItem
          ? _value.purchasedItem
          : purchasedItem // ignore: cast_nullable_to_non_nullable
              as AvatarItem?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseItemResponseImpl implements _PurchaseItemResponse {
  const _$PurchaseItemResponseImpl(
      {@JsonKey(name: 'Success') required this.success,
      @JsonKey(name: 'Message') required this.message,
      @JsonKey(name: 'RemainingPoints') required this.remainingPoints,
      @JsonKey(name: 'PurchasedItem') this.purchasedItem});

  factory _$PurchaseItemResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseItemResponseImplFromJson(json);

  @override
  @JsonKey(name: 'Success')
  final bool success;
  @override
  @JsonKey(name: 'Message')
  final String message;
  @override
  @JsonKey(name: 'RemainingPoints')
  final int remainingPoints;
  @override
  @JsonKey(name: 'PurchasedItem')
  final AvatarItem? purchasedItem;

  @override
  String toString() {
    return 'PurchaseItemResponse(success: $success, message: $message, remainingPoints: $remainingPoints, purchasedItem: $purchasedItem)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseItemResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.remainingPoints, remainingPoints) ||
                other.remainingPoints == remainingPoints) &&
            (identical(other.purchasedItem, purchasedItem) ||
                other.purchasedItem == purchasedItem));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, success, message, remainingPoints, purchasedItem);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseItemResponseImplCopyWith<_$PurchaseItemResponseImpl>
      get copyWith =>
          __$$PurchaseItemResponseImplCopyWithImpl<_$PurchaseItemResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseItemResponseImplToJson(
      this,
    );
  }
}

abstract class _PurchaseItemResponse implements PurchaseItemResponse {
  const factory _PurchaseItemResponse(
          {@JsonKey(name: 'Success') required final bool success,
          @JsonKey(name: 'Message') required final String message,
          @JsonKey(name: 'RemainingPoints') required final int remainingPoints,
          @JsonKey(name: 'PurchasedItem') final AvatarItem? purchasedItem}) =
      _$PurchaseItemResponseImpl;

  factory _PurchaseItemResponse.fromJson(Map<String, dynamic> json) =
      _$PurchaseItemResponseImpl.fromJson;

  @override
  @JsonKey(name: 'Success')
  bool get success;
  @override
  @JsonKey(name: 'Message')
  String get message;
  @override
  @JsonKey(name: 'RemainingPoints')
  int get remainingPoints;
  @override
  @JsonKey(name: 'PurchasedItem')
  AvatarItem? get purchasedItem;
  @override
  @JsonKey(ignore: true)
  _$$PurchaseItemResponseImplCopyWith<_$PurchaseItemResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
