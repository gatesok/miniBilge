// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipped_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EquippedItemImpl _$$EquippedItemImplFromJson(Map<String, dynamic> json) =>
    _$EquippedItemImpl(
      itemId: json['ItemId'] as String,
      name: json['Name'] as String,
      itemType: (json['ItemType'] as num).toInt(),
      itemTypeName: json['ItemTypeName'] as String,
      imageUrl: json['ImageUrl'] as String,
      equippedAt: DateTime.parse(json['EquippedAt'] as String),
    );

Map<String, dynamic> _$$EquippedItemImplToJson(_$EquippedItemImpl instance) =>
    <String, dynamic>{
      'ItemId': instance.itemId,
      'Name': instance.name,
      'ItemType': instance.itemType,
      'ItemTypeName': instance.itemTypeName,
      'ImageUrl': instance.imageUrl,
      'EquippedAt': instance.equippedAt.toIso8601String(),
    };
