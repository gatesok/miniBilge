import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_provider.dart';
import '../models/child_profile_dto.dart';
import 'child_profile_provider.dart';
import 'child_profile_state.dart';

const String _selectedChildIdKey = 'selected_child_id';

class SelectedChildNotifier extends StateNotifier<ChildProfileDto?> {
  final SharedPreferences _prefs;
  final Ref _ref;

  SelectedChildNotifier(this._prefs, this._ref) : super(null) {
    // Immediately try to restore if profiles already loaded
    _tryRestoreSelection(_ref.read(childProfileProvider));
    // Also listen for when profiles load later
    _ref.listen<ChildProfileState>(childProfileProvider, (_, newState) {
      if (state == null) {
        _tryRestoreSelection(newState);
      } else {
        // Keep selected child in sync when profiles are refreshed (e.g. after purchase)
        newState.maybeWhen(
          loaded: (profiles) {
            final updated = profiles.firstWhere(
              (p) => p.id == state!.id,
              orElse: () => state!,
            );
            if (updated != state) state = updated;
          },
          orElse: () {},
        );
      }
    });
  }

  /// Try to restore previously selected child from profiles
  void _tryRestoreSelection(ChildProfileState profileState) {
    final childId = _prefs.getString(_selectedChildIdKey);
    if (childId == null) return;

    profileState.maybeWhen(
      loaded: (profiles) {
        if (profiles.isEmpty) return;
        final child = profiles.firstWhere(
          (p) => p.id == childId,
          orElse: () => profiles.first,
        );
        state = child;
        // Register pending FCM token if one was saved from a previous session
        _registerPendingFcmToken(child.id);
      },
      orElse: () {},
    );
  }

  /// Called when a new FCM token is obtained (from main.dart callback).
  /// Immediately registers it with the backend if a child is selected.
  Future<void> onNewFcmToken(String token) async {
    await _prefs.setString(StorageKeys.pendingFcmToken, token);
    if (state != null) {
      await _registerPendingFcmToken(state!.id);
    }
  }

  /// Select a child profile
  Future<void> selectChild(ChildProfileDto child) async {
    state = child;
    await _prefs.setString(_selectedChildIdKey, child.id);
    // Register pending FCM token with backend
    await _registerPendingFcmToken(child.id);
  }

  /// Register FCM token with backend if one is pending
  Future<void> _registerPendingFcmToken(String childId) async {
    final token = _prefs.getString(StorageKeys.pendingFcmToken);
    if (token == null || token.isEmpty) return;
    try {
      final dio = _ref.read(dioProvider);
      await dio.post(
        '/api/notification/register',
        data: {
          'childProfileId': childId,
          'token': token,
          'platform': 'ios',
        },
      );
      // Clear pending token after successful registration
      await _prefs.remove(StorageKeys.pendingFcmToken);
    } catch (e) {
      // Non-critical — token will be retried on next child selection
      debugPrint('[FCM] Token registration failed: $e');
    }
  }

  /// Auto-select child (used for single child or first-time)
  Future<void> autoSelectChild(List<ChildProfileDto> profiles) async {
    if (profiles.isEmpty) {
      state = null;
      return;
    }

    // If only one child, auto-select
    if (profiles.length == 1) {
      await selectChild(profiles.first);
      return;
    }

    // Check if we have a saved selection
    final savedId = _prefs.getString(_selectedChildIdKey);
    if (savedId != null) {
      final savedChild = profiles.firstWhere(
        (p) => p.id == savedId,
        orElse: () => profiles.first,
      );
      await selectChild(savedChild);
    }
  }

  /// Clear selected child
  Future<void> clearSelection() async {
    state = null;
    await _prefs.remove(_selectedChildIdKey);
  }

  /// Check if a child is currently selected
  bool get hasSelection => state != null;
}

final selectedChildProvider = StateNotifierProvider<SelectedChildNotifier, ChildProfileDto?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SelectedChildNotifier(prefs, ref);
});
