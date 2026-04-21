import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_item_request.freezed.dart';
part 'purchase_item_request.g.dart';

@freezed
class PurchaseItemRequest with _$PurchaseItemRequest {
  const factory PurchaseItemRequest({
    @JsonKey(name: 'ChildProfileId') required String childProfileId,
    @JsonKey(name: 'ItemId') required String itemId,
  }) = _PurchaseItemRequest;

  factory PurchaseItemRequest.fromJson(Map<String, dynamic> json) =>
      _$PurchaseItemRequestFromJson(json);
}
