import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/avatar_item.dart';
import '../models/equipped_item.dart';

part 'avatar_state.freezed.dart';

@freezed
class AvatarState with _$AvatarState {
  const factory AvatarState.initial() = _Initial;
  const factory AvatarState.loading() = _Loading;
  const factory AvatarState.loaded({
    @Default([]) List<AvatarItem> availableItems,
    @Default([]) List<AvatarItem> ownedItems,
    @Default([]) List<EquippedItem> equippedItems,
  }) = _Loaded;
  const factory AvatarState.error(String message) = _Error;
}
