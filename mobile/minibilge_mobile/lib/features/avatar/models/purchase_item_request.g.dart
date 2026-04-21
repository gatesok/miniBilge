// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_item_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PurchaseItemRequestImpl _$$PurchaseItemRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$PurchaseItemRequestImpl(
      childProfileId: json['ChildProfileId'] as String,
      itemId: json['ItemId'] as String,
    );

Map<String, dynamic> _$$PurchaseItemRequestImplToJson(
        _$PurchaseItemRequestImpl instance) =>
    <String, dynamic>{
      'ChildProfileId': instance.childProfileId,
      'ItemId': instance.itemId,
    };
