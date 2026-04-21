import 'package:freezed_annotation/freezed_annotation.dart';
import 'item_type.dart';

part 'avatar_item.freezed.dart';
part 'avatar_item.g.dart';

@freezed
class AvatarItem with _$AvatarItem {
  const factory AvatarItem({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'ItemType') required int itemType,
    @JsonKey(name: 'ItemTypeName') required String itemTypeName,
    @JsonKey(name: 'PointCost') required int pointCost,
    @JsonKey(name: 'ImageUrl') required String imageUrl,
    @JsonKey(name: 'Category') required String category,
    @JsonKey(name: 'IsOwned') @Default(false) bool isOwned,
    @JsonKey(name: 'IsEquipped') @Default(false) bool isEquipped,
  }) = _AvatarItem;

  factory AvatarItem.fromJson(Map<String, dynamic> json) =>
      _$AvatarItemFromJson(json);
}

extension AvatarItemX on AvatarItem {
  ItemType get type => ItemType.fromValue(itemType);
}
