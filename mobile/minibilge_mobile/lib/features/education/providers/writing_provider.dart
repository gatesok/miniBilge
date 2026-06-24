import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../models/writing_models.dart';
import '../services/writing_service.dart';

// ─── Service Provider ─────────────────────────────────────────────────────────

final writingServiceProvider = Provider<WritingService>((ref) {
  final dio = ref.read(dioProvider);
  return WritingService(dio);
});

// ─── State ────────────────────────────────────────────────────────────────────

class WritingState {
  final List<WritingPrompt> prompts;
  final WritingPrompt? selectedPrompt;
  final WritingEvaluationResult? result;
  final bool isLoadingPrompts;
  final bool isEvaluating;
  final String? error;

  const WritingState({
    this.prompts = const [],
    this.selectedPrompt,
    this.result,
    this.isLoadingPrompts = false,
    this.isEvaluating = false,
    this.error,
  });

  WritingState copyWith({
    List<WritingPrompt>? prompts,
    WritingPrompt? selectedPrompt,
    bool clearSelectedPrompt = false,
    WritingEvaluationResult? result,
    bool clearResult = false,
    bool? isLoadingPrompts,
    bool? isEvaluating,
    String? error,
    bool clearError = false,
  }) {
    return WritingState(
      prompts: prompts ?? this.prompts,
      selectedPrompt: clearSelectedPrompt ? null : (selectedPrompt ?? this.selectedPrompt),
      result: clearResult ? null : (result ?? this.result),
      isLoadingPrompts: isLoadingPrompts ?? this.isLoadingPrompts,
      isEvaluating: isEvaluating ?? this.isEvaluating,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class WritingNotifier extends StateNotifier<WritingState> {
  final WritingService _service;
  final Ref _ref;

  WritingNotifier(this._service, this._ref) : super(const WritingState());

  Future<void> loadPrompts(String level, {String? episodeId}) async {
    state = state.copyWith(
      isLoadingPrompts: true,
      clearError: true,
      clearResult: true,
      clearSelectedPrompt: true,
    );
    try {
      final prompts = await _service.getPrompts(level: level, episodeId: episodeId);
      state = state.copyWith(isLoadingPrompts: false, prompts: prompts);
    } catch (e) {
      state = state.copyWith(
        isLoadingPrompts: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void selectPrompt(WritingPrompt prompt) {
    state = state.copyWith(selectedPrompt: prompt, clearResult: true, clearError: true);
  }

  Future<void> evaluate(String text, {String inputMethod = 'keyboard'}) async {
    final prompt = state.selectedPrompt;
    if (prompt == null) return;

    final child = _ref.read(selectedChildProvider);
    state = state.copyWith(isEvaluating: true, clearError: true, clearResult: true);
    try {
      final result = await _service.evaluate(
        text: text,
        promptText: prompt.promptText,
        level: _currentLevel,
        inputMethod: inputMethod,
        childProfileId: child?.id,
      );
      state = state.copyWith(isEvaluating: false, result: result);
    } catch (e) {
      state = state.copyWith(
        isEvaluating: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void reset() {
    state = const WritingState();
  }

  // Level bilgisini provider'da tutmak için
  String _currentLevel = 'B1';

  void setLevel(String level) {
    _currentLevel = level;
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final writingProvider =
    StateNotifierProvider.autoDispose<WritingNotifier, WritingState>((ref) {
  final service = ref.read(writingServiceProvider);
  return WritingNotifier(service, ref);
});
