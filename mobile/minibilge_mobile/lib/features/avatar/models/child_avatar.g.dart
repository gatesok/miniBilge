// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_avatar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChildAvatarImpl _$$ChildAvatarImplFromJson(Map<String, dynamic> json) =>
    _$ChildAvatarImpl(
      childProfileId: json['ChildProfileId'] as String,
      childName: json['ChildName'] as String,
      avatar: json['Avatar'] == null
          ? null
          : Avatar.fromJson(json['Avatar'] as Map<String, dynamic>),
      equippedItems: (json['EquippedItems'] as List<dynamic>?)
              ?.map((e) => EquippedItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalPoints: (json['TotalPoints'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ChildAvatarImplToJson(_$ChildAvatarImpl instance) =>
    <String, dynamic>{
      'ChildProfileId': instance.childProfileId,
      'ChildName': instance.childName,
      'Avatar': instance.avatar,
      'EquippedItems': instance.equippedItems,
      'TotalPoints': instance.totalPoints,
    };
