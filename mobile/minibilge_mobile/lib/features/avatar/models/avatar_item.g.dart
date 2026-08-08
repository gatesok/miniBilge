// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AvatarItemImpl _$$AvatarItemImplFromJson(Map<String, dynamic> json) =>
    _$AvatarItemImpl(
      id: json['Id'] as String,
      name: json['Name'] as String,
      itemType: (json['ItemType'] as num).toInt(),
      itemTypeName: json['ItemTypeName'] as String,
      pointCost: (json['PointCost'] as num).toInt(),
      imageUrl: json['ImageUrl'] as String,
      category: json['Category'] as String,
      isOwned: json['IsOwned'] as bool? ?? false,
      isEquipped: json['IsEquipped'] as bool? ?? false,
    );

Map<String, dynamic> _$$AvatarItemImplToJson(_$AvatarItemImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'ItemType': instance.itemType,
      'ItemTypeName': instance.itemTypeName,
      'PointCost': instance.pointCost,
      'ImageUrl': instance.imageUrl,
      'Category': instance.category,
      'IsOwned': instance.isOwned,
      'IsEquipped': instance.isEquipped,
    };
