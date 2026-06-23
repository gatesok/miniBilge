import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard_models.freezed.dart';
part 'flashcard_models.g.dart';

@freezed
class FlashcardDeck with _$FlashcardDeck {
  const factory FlashcardDeck({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'Title') required String title,
    @JsonKey(name: 'Level') required int level,
    @JsonKey(name: 'EpisodeId') String? episodeId,
    @JsonKey(name: 'TotalCards') required int totalCards,
    @JsonKey(name: 'LearnedCount') required int learnedCount,
  }) = _FlashcardDeck;

  factory FlashcardDeck.fromJson(Map<String, dynamic> json) =>
      _$FlashcardDeckFromJson(json);
}

@freezed
class FlashcardItem with _$FlashcardItem {
  const factory FlashcardItem({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'DeckId') required String deckId,
    @JsonKey(name: 'FrontText') required String frontText,
    @JsonKey(name: 'BackText') required String backText,
    @JsonKey(name: 'ExampleSentence') String? exampleSentence,
    @JsonKey(name: 'AudioUrl') String? audioUrl,
    @JsonKey(name: 'DisplayOrder') required int displayOrder,
    @JsonKey(name: 'IsLearned') required bool isLearned,
    @JsonKey(name: 'ReviewCount') required int reviewCount,
  }) = _FlashcardItem;

  factory FlashcardItem.fromJson(Map<String, dynamic> json) =>
      _$FlashcardItemFromJson(json);
}

@freezed
class FlashcardSessionResult with _$FlashcardSessionResult {
  const factory FlashcardSessionResult({
    @JsonKey(name: 'DeckId') required String deckId,
    @JsonKey(name: 'LearnedCount') required int learnedCount,
    @JsonKey(name: 'TotalCards') required int totalCards,
    @JsonKey(name: 'CoinEarned') required int coinEarned,
    @JsonKey(name: 'IsFirstCompletion') required bool isFirstCompletion,
  }) = _FlashcardSessionResult;

  factory FlashcardSessionResult.fromJson(Map<String, dynamic> json) =>
      _$FlashcardSessionResultFromJson(json);
}
