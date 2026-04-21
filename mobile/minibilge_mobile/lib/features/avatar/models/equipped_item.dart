import 'package:freezed_annotation/freezed_annotation.dart';
import 'item_type.dart';

part 'equipped_item.freezed.dart';
part 'equipped_item.g.dart';

@freezed
class EquippedItem with _$EquippedItem {
  const factory EquippedItem({
    @JsonKey(name: 'ItemId') required String itemId,
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'ItemType') required int itemType,
    @JsonKey(name: 'ItemTypeName') required String itemTypeName,
    @JsonKey(name: 'ImageUrl') required String imageUrl,
    @JsonKey(name: 'EquippedAt') required DateTime equippedAt,
  }) = _EquippedItem;

  factory EquippedItem.fromJson(Map<String, dynamic> json) =>
      _$EquippedItemFromJson(json);
}

extension EquippedItemX on EquippedItem {
  ItemType get type => ItemType.fromValue(itemType);
}
