import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/services/notification_service.dart';
import '../models/child_profile_dto.dart';
import 'child_profile_provider.dart';
import 'child_profile_state.dart';
import '../../friends/services/social_hub_service.dart';
import '../../../core/services/analytics_service.dart';

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
        unawaited(
          AnalyticsService.setGradeGroup(
            AnalyticsService.gradeGroupForAge(child.age),
          ),
        );
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

  /// Uygulama resume'da veya dışarıdan tetiklenince çağrılır.
  /// Kayıt bekleyen token varsa ya da Firebase'den alınabiliyorsa kaydeder.
  Future<void> retryFcmRegistration(String childId) async {
    await _registerPendingFcmToken(childId);
  }

  /// Select a child profile
  Future<void> selectChild(ChildProfileDto child) async {
    // Eski profil varsa önce offline yap, ardından yeni profil ile reconnect
    if (state != null && state!.id != child.id) {
      try {
        final hub = _ref.read(socialHubServiceProvider);
        await hub.disconnect(); // SetOffline(oldId) + heartbeat timer iptal
        await hub.connect(child.id); // RegisterPresence(newId) + yeni heartbeat
      } catch (_) {}
    }
    state = child;
    await _prefs.setString(_selectedChildIdKey, child.id);
    final gradeGroup = AnalyticsService.gradeGroupForAge(child.age);
    unawaited(AnalyticsService.setGradeGroup(gradeGroup));
    unawaited(
      AnalyticsService.logEvent(
        AnalyticsEvents.childProfileSelected,
        parameters: {'grade_group': gradeGroup},
      ),
    );
    // Register pending FCM token in background — do NOT await (must not block navigation)
    unawaited(_registerPendingFcmToken(child.id));
  }

  /// Register FCM token with backend if one is pending.
  /// If no token is cached, tries to get one directly from Firebase.
  Future<void> _registerPendingFcmToken(String childId) async {
    try {
      // Cached token yoksa Firebase'den direkt çekmeyi dene
      String? token = _prefs.getString(StorageKeys.pendingFcmToken);
      if (token == null || token.isEmpty) {
        token = await NotificationService.getToken();
        if (token != null && token.isNotEmpty) {
          await _prefs.setString(StorageKeys.pendingFcmToken, token);
        }
      }
      if (token == null || token.isEmpty) return;

      try {
        final dio = _ref.read(dioProvider);
        await dio.post(
          '/notification/register',
          data: {'childProfileId': childId, 'token': token, 'platform': 'ios'},
        );
        await _prefs.remove(StorageKeys.pendingFcmToken);
        debugPrint('[FCM] Token kaydedildi: ${token.substring(0, 20)}...');
      } on DioException catch (e) {
        final body = e.response?.data?.toString() ?? '';
        debugPrint(
          '[FCM] Token kaydı başarısız (HTTP ${e.response?.statusCode}): ${e.message} | body: ${body.length > 200 ? body.substring(0, 200) : body}',
        );
      } catch (e) {
        debugPrint('[FCM] Token kaydı başarısız: $e');
      }
    } catch (e) {
      // FCM hatası giriş akışını engellemesin
      debugPrint('[FCM] _registerPendingFcmToken hata (ignored): $e');
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

final selectedChildProvider =
    StateNotifierProvider<SelectedChildNotifier, ChildProfileDto?>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return SelectedChildNotifier(prefs, ref);
    });
