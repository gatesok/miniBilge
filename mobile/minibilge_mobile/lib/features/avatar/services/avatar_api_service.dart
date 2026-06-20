import 'package:dio/dio.dart';
import '../models/avatar_item.dart';
import '../models/equipped_item.dart';
import '../models/child_avatar.dart';
import '../models/purchase_item_response.dart';

class AvatarApiService {
  final Dio _dio;

  AvatarApiService(this._dio);

  /// Get all available avatar items for shopping
  /// GET /api/avatar/items?childProfileId={id}
  Future<List<AvatarItem>> getAvailableItems(String childProfileId) async {
    try {
      final response = await _dio.get(
        '/avatar/items',
        queryParameters: {'childProfileId': childProfileId},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => AvatarItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get child's owned items (inventory)
  /// GET /api/avatar/child/{id}/owned
  Future<List<AvatarItem>> getOwnedItems(String childProfileId) async {
    try {
      final response = await _dio.get('/avatar/child/$childProfileId/owned');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => AvatarItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get child's currently equipped items
  /// GET /api/avatar/child/{id}/equipped
  Future<List<EquippedItem>> getEquippedItems(String childProfileId) async {
    try {
      final response = await _dio.get('/avatar/child/$childProfileId/equipped');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => EquippedItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Purchase an avatar item
  /// POST /api/avatar/child/{id}/purchase/{itemId}
  Future<PurchaseItemResponse> purchaseItem({
    required String childProfileId,
    required String itemId,
  }) async {
    try {
      final response = await _dio.post(
        '/avatar/child/$childProfileId/purchase/$itemId',
      );

      return PurchaseItemResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Equip an avatar item
  /// POST /api/avatar/child/{id}/equip/{itemId}
  Future<void> equipItem({
    required String childProfileId,
    required String itemId,
  }) async {
    try {
      await _dio.post('/avatar/child/$childProfileId/equip/$itemId');
    } catch (e) {
      rethrow;
    }
  }

  /// Unequip an avatar item
  /// DELETE /api/avatar/child/{id}/unequip/{itemId}
  Future<void> unequipItem({
    required String childProfileId,
    required String itemId,
  }) async {
    try {
      await _dio.delete('/avatar/child/$childProfileId/unequip/$itemId');
    } catch (e) {
      rethrow;
    }
  }

  /// Update selected character
  /// PATCH /api/avatar/child/{id}/character
  Future<void> updateCharacter({
    required String childProfileId,
    required String characterKey,
  }) async {
    try {
      await _dio.patch(
        '/avatar/child/$childProfileId/character',
        data: {'CharacterKey': characterKey},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get child's complete avatar data
  /// This is a convenience method that combines multiple API calls
  Future<ChildAvatar> getChildAvatar(String childProfileId) async {
    try {
      final equippedItems = await getEquippedItems(childProfileId);
      
      // Note: This would need to be extended with actual avatar data
      // For now, returning a basic structure
      return ChildAvatar(
        childProfileId: childProfileId,
        childName: '',
        equippedItems: equippedItems,
      );
    } catch (e) {
      rethrow;
    }
  }
}
