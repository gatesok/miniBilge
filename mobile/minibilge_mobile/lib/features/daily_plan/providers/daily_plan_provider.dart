import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../models/daily_plan_models.dart';
import '../services/daily_plan_service.dart';
import '../services/daily_plan_reminder_service.dart';

final dailyPlanServiceProvider = Provider<DailyPlanService>((ref) {
  return DailyPlanService(ref.read(dioProvider));
});
class DailyPlanState {
  final bool isLoading;
  final DailyPlanDto? plan;
  final String? error;
  final String? completingItemId;

  const DailyPlanState({
    this.isLoading = false,
    this.plan,
    this.error,
    this.completingItemId,
  });

  DailyPlanState copyWith({
    bool? isLoading,
    DailyPlanDto? plan,
    String? error,
    String? completingItemId,
    bool clearError = false,
    bool clearCompleting = false,
  }) {
    return DailyPlanState(
      isLoading: isLoading ?? this.isLoading,
      plan: plan ?? this.plan,
      error: clearError ? null : (error ?? this.error),
      completingItemId:
          clearCompleting ? null : (completingItemId ?? this.completingItemId),
    );
  }
}

class DailyPlanNotifier extends StateNotifier<DailyPlanState> {
  final DailyPlanService _service;
  final String _childId;

  DailyPlanNotifier(this._service, this._childId)
      : super(const DailyPlanState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final plan = await _service.getToday(_childId);
      state = DailyPlanState(plan: plan);
    } catch (_) {
      state = const DailyPlanState(error: 'Günlük plan yüklenemedi.');
    }
  }

  /// Maddeyi tamamlar. Bu çağrı sonucu plan ilk kez tamamlandıysa `true` döner
  /// (ödül ekranını tetiklemek için).
  Future<bool> completeItem(String itemId) async {
    final wasCompleted = state.plan?.isCompleted ?? false;
    state = state.copyWith(completingItemId: itemId, clearError: true);
    try {
      final plan = await _service.completeItem(_childId, itemId);
      state = state.copyWith(plan: plan, clearCompleting: true);
      return !wasCompleted && plan.isCompleted;
    } catch (_) {
      state = state.copyWith(
        error: 'Madde tamamlanamadı.',
        clearCompleting: true,
      );
      return false;
    }
  }
}

final dailyPlanProvider = StateNotifierProvider.autoDispose
    .family<DailyPlanNotifier, DailyPlanState, String>((ref, childId) {
  return DailyPlanNotifier(ref.read(dailyPlanServiceProvider), childId);
});

/// Günlük plan hatırlatma bildirimi tercihi (M07).
class DailyPlanReminderNotifier extends StateNotifier<bool> {
  DailyPlanReminderNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    state = await DailyPlanReminderService.isEnabled();
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await DailyPlanReminderService.setEnabled(enabled);
  }
}

final dailyPlanReminderProvider =
    StateNotifierProvider<DailyPlanReminderNotifier, bool>((ref) {
  return DailyPlanReminderNotifier();
});
