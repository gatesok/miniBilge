import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/avatar_item.dart';
import '../models/equipped_item.dart';
import '../services/avatar_api_service.dart';
import 'avatar_service_provider.dart';
import 'avatar_state.dart';

class AvatarNotifier extends StateNotifier<AvatarState> {
  final AvatarApiService _apiService;

  AvatarNotifier(this._apiService) : super(const AvatarState.initial());

  /// Load all avatar data for a child
  Future<void> loadAvatarData(String childProfileId) async {
    state = const AvatarState.loading();

    try {
      final results = await Future.wait([
        _apiService.getAvailableItems(childProfileId),
        _apiService.getOwnedItems(childProfileId),
        _apiService.getEquippedItems(childProfileId),
      ]);

      state = AvatarState.loaded(
        availableItems: results[0] as List<AvatarItem>,
        ownedItems: results[1] as List<AvatarItem>,
        equippedItems: results[2] as List<EquippedItem>,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = AvatarState.error(message);
    } catch (e) {
      state = AvatarState.error('Avatar verileri yüklenirken bir hata oluştu');
    }
  }

  /// Load only available items for shopping
  Future<void> loadAvailableItems(String childProfileId) async {
    try {
      final items = await _apiService.getAvailableItems(childProfileId);
      
      state.maybeWhen(
        loaded: (available, owned, equipped) {
          state = AvatarState.loaded(
            availableItems: items,
            ownedItems: owned,
            equippedItems: equipped,
          );
        },
        orElse: () {
          state = AvatarState.loaded(availableItems: items);
        },
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = AvatarState.error(message);
    } catch (e) {
      state = AvatarState.error('Mağaza ürünleri yüklenirken bir hata oluştu');
    }
  }

  /// Load owned items (inventory)
  Future<void> loadOwnedItems(String childProfileId) async {
    try {
      final items = await _apiService.getOwnedItems(childProfileId);
      
      state.maybeWhen(
        loaded: (available, owned, equipped) {
          state = AvatarState.loaded(
            availableItems: available,
            ownedItems: items,
            equippedItems: equipped,
          );
        },
        orElse: () {
          state = AvatarState.loaded(ownedItems: items);
        },
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = AvatarState.error(message);
    } catch (e) {
      state = AvatarState.error('Envanter yüklenirken bir hata oluştu');
    }
  }

  /// Load equipped items
  Future<void> loadEquippedItems(String childProfileId) async {
    try {
      final items = await _apiService.getEquippedItems(childProfileId);
      
      state.maybeWhen(
        loaded: (available, owned, equipped) {
          state = AvatarState.loaded(
            availableItems: available,
            ownedItems: owned,
            equippedItems: items,
          );
        },
        orElse: () {
          state = AvatarState.loaded(equippedItems: items);
        },
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = AvatarState.error(message);
    } catch (e) {
      state = AvatarState.error('Ekipmanlar yüklenirken bir hata oluştu');
    }
  }

  /// Purchase an avatar item
  Future<bool> purchaseItem({
    required String childProfileId,
    required String itemId,
  }) async {
    try {
      final response = await _apiService.purchaseItem(
        childProfileId: childProfileId,
        itemId: itemId,
      );

      if (response.success) {
        // Reload data to reflect the purchase
        await loadAvatarData(childProfileId);
        return true;
      } else {
        state = AvatarState.error(response.message);
        return false;
      }
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = AvatarState.error(message);
      return false;
    } catch (e) {
      state = AvatarState.error('Satın alma işlemi başarısız oldu');
      return false;
    }
  }

  /// Equip an avatar item
  Future<bool> equipItem({
    required String childProfileId,
    required String itemId,
  }) async {
    try {
      await _apiService.equipItem(
        childProfileId: childProfileId,
        itemId: itemId,
      );
      // Reload both equipped and owned items to reflect the change
      await loadAvatarData(childProfileId);
      return true;
    } on DioException catch (_) {
      // Do NOT set error state — preserve current loaded state
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Unequip an avatar item
  Future<bool> unequipItem({
    required String childProfileId,
    required String itemId,
  }) async {
    try {
      await _apiService.unequipItem(
        childProfileId: childProfileId,
        itemId: itemId,
      );
      // Reload both equipped and owned items to reflect the change
      await loadAvatarData(childProfileId);
      return true;
    } on DioException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Extract error message from DioException
  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
      if (data.containsKey('title')) {
        return data['title'] as String;
      }
    }
    
    return e.message ?? 'Bir hata oluştu';
  }
}

/// Provider for AvatarNotifier
final avatarProvider = StateNotifierProvider<AvatarNotifier, AvatarState>((ref) {
  final apiService = ref.watch(avatarApiServiceProvider);
  return AvatarNotifier(apiService);
});
