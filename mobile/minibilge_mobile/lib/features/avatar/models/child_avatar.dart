import 'package:freezed_annotation/freezed_annotation.dart';
import 'avatar.dart';
import 'equipped_item.dart';

part 'child_avatar.freezed.dart';
part 'child_avatar.g.dart';

@freezed
class ChildAvatar with _$ChildAvatar {
  const factory ChildAvatar({
    @JsonKey(name: 'ChildProfileId') required String childProfileId,
    @JsonKey(name: 'ChildName') required String childName,
    @JsonKey(name: 'Avatar') Avatar? avatar,
    @JsonKey(name: 'EquippedItems') @Default([]) List<EquippedItem> equippedItems,
    @JsonKey(name: 'TotalPoints') @Default(0) int totalPoints,
  }) = _ChildAvatar;

  factory ChildAvatar.fromJson(Map<String, dynamic> json) =>
      _$ChildAvatarFromJson(json);
}
