// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PurchaseItemResponseImpl _$$PurchaseItemResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PurchaseItemResponseImpl(
      success: json['Success'] as bool,
      message: json['Message'] as String,
      remainingPoints: (json['RemainingPoints'] as num).toInt(),
      purchasedItem: json['PurchasedItem'] == null
          ? null
          : AvatarItem.fromJson(json['PurchasedItem'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PurchaseItemResponseImplToJson(
        _$PurchaseItemResponseImpl instance) =>
    <String, dynamic>{
      'Success': instance.success,
      'Message': instance.message,
      'RemainingPoints': instance.remainingPoints,
      'PurchasedItem': instance.purchasedItem,
    };
