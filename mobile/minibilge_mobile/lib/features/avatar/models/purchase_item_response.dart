import 'package:freezed_annotation/freezed_annotation.dart';
import 'avatar_item.dart';

part 'purchase_item_response.freezed.dart';
part 'purchase_item_response.g.dart';

@freezed
class PurchaseItemResponse with _$PurchaseItemResponse {
  const factory PurchaseItemResponse({
    @JsonKey(name: 'Success') required bool success,
    @JsonKey(name: 'Message') required String message,
    @JsonKey(name: 'RemainingPoints') required int remainingPoints,
    @JsonKey(name: 'PurchasedItem') AvatarItem? purchasedItem,
  }) = _PurchaseItemResponse;

  factory PurchaseItemResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseItemResponseFromJson(json);
}
