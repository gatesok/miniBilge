import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../models/flashcard_models.dart';
import '../services/flashcard_service.dart';

// ─── Service Provider ────────────────────────────────────────────────────────

final flashcardServiceProvider = Provider<FlashcardService>((ref) {
  final dio = ref.read(dioProvider);
  return FlashcardService(dio);
});

// ─── Deck List Provider ───────────────────────────────────────────────────────

final flashcardDeckListProvider =
    FutureProvider.family<List<FlashcardDeck>, int>((ref, level) async {
  final service = ref.read(flashcardServiceProvider);
  final child = ref.watch(selectedChildProvider);
  if (child == null) return [];
  return service.getDecksByLevel(level, child.id);
});

// ─── Deck by Episode Provider ─────────────────────────────────────────────────

final flashcardDeckByEpisodeProvider =
    FutureProvider.family<FlashcardDeck?, String>((ref, episodeId) async {
  final service = ref.read(flashcardServiceProvider);
  final child = ref.watch(selectedChildProvider);
  if (child == null) return null;
  return service.getDeckByEpisode(episodeId, child.id);
});

// ─── Study Session State ──────────────────────────────────────────────────────

class FlashcardStudyState {
  final List<FlashcardItem> queue;       // çalışılacak sıradaki kartlar
  final List<FlashcardItem> learned;     // biliyorum denilen kartlar
  final int currentIndex;
  final bool isFlipped;
  final bool isLoading;
  final bool isComplete;
  final String? error;

  const FlashcardStudyState({
    this.queue = const [],
    this.learned = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.isLoading = false,
    this.isComplete = false,
    this.error,
  });

  FlashcardItem? get currentCard =>
      queue.isNotEmpty ? queue[currentIndex] : null;

  int get totalCards => queue.length + learned.length;

  FlashcardStudyState copyWith({
    List<FlashcardItem>? queue,
    List<FlashcardItem>? learned,
    int? currentIndex,
    bool? isFlipped,
    bool? isLoading,
    bool? isComplete,
    String? error,
  }) {
    return FlashcardStudyState(
      queue: queue ?? this.queue,
      learned: learned ?? this.learned,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      isLoading: isLoading ?? this.isLoading,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
    );
  }
}

class FlashcardStudyNotifier extends StateNotifier<FlashcardStudyState> {
  final FlashcardService _service;
  final String _childId;
  final String _deckId;

  FlashcardStudyNotifier(this._service, this._childId, this._deckId)
      : super(const FlashcardStudyState(isLoading: true));

  Future<void> loadCards() async {
    try {
      final cards = await _service.getCards(_deckId, _childId);
      // Bilinmeyenler önce, bilinenlerin reviewCount'u yüksek olanlar arkaya
      final sorted = [...cards]..sort((a, b) {
          if (a.isLearned != b.isLearned) return a.isLearned ? 1 : -1;
          return a.reviewCount.compareTo(b.reviewCount);
        });
      state = FlashcardStudyState(queue: sorted);
    } catch (e) {
      state = FlashcardStudyState(error: e.toString());
    }
  }

  void flip() {
    state = state.copyWith(isFlipped: !state.isFlipped);
  }

  Future<void> markKnown() async {
    final card = state.currentCard;
    if (card == null) return;
    await _service.markCard(card.id, _childId, true);
    _advance(isLearned: true);
  }

  Future<void> markUnknown() async {
    final card = state.currentCard;
    if (card == null) return;
    await _service.markCard(card.id, _childId, false);
    _advance(isLearned: false);
  }

  void _advance({required bool isLearned}) {
    final card = state.currentCard!;
    final newQueue = [...state.queue];
    newQueue.removeAt(state.currentIndex);

    final newLearned = [...state.learned];

    if (isLearned) {
      newLearned.add(card);
    } else {
      // Bilmiyorum: kartı kuyruğun sonuna ekle
      newQueue.add(card);
    }

    final isComplete = newQueue.isEmpty;

    state = state.copyWith(
      queue: newQueue,
      learned: newLearned,
      currentIndex: 0,
      isFlipped: false,
      isComplete: isComplete,
    );
  }

  Future<FlashcardSessionResult> completeSession() async {
    return _service.completeSession(_deckId, _childId);
  }
}

final flashcardStudyProvider = StateNotifierProvider.autoDispose
    .family<FlashcardStudyNotifier, FlashcardStudyState, String>(
  (ref, deckId) {
    final service = ref.read(flashcardServiceProvider);
    final child = ref.read(selectedChildProvider);
    final notifier = FlashcardStudyNotifier(service, child?.id ?? '', deckId);
    notifier.loadCards();
    return notifier;
  },
);
