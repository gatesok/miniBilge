// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlashcardDeckImpl _$$FlashcardDeckImplFromJson(Map<String, dynamic> json) =>
    _$FlashcardDeckImpl(
      id: json['Id'] as String,
      title: json['Title'] as String,
      level: (json['Level'] as num).toInt(),
      episodeId: json['EpisodeId'] as String?,
      totalCards: (json['TotalCards'] as num).toInt(),
      learnedCount: (json['LearnedCount'] as num).toInt(),
    );

Map<String, dynamic> _$$FlashcardDeckImplToJson(_$FlashcardDeckImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Title': instance.title,
      'Level': instance.level,
      'EpisodeId': instance.episodeId,
      'TotalCards': instance.totalCards,
      'LearnedCount': instance.learnedCount,
    };

_$FlashcardItemImpl _$$FlashcardItemImplFromJson(Map<String, dynamic> json) =>
    _$FlashcardItemImpl(
      id: json['Id'] as String,
      deckId: json['DeckId'] as String,
      frontText: json['FrontText'] as String,
      backText: json['BackText'] as String,
      exampleSentence: json['ExampleSentence'] as String?,
      audioUrl: json['AudioUrl'] as String?,
      displayOrder: (json['DisplayOrder'] as num).toInt(),
      isLearned: json['IsLearned'] as bool,
      reviewCount: (json['ReviewCount'] as num).toInt(),
    );

Map<String, dynamic> _$$FlashcardItemImplToJson(_$FlashcardItemImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'DeckId': instance.deckId,
      'FrontText': instance.frontText,
      'BackText': instance.backText,
      'ExampleSentence': instance.exampleSentence,
      'AudioUrl': instance.audioUrl,
      'DisplayOrder': instance.displayOrder,
      'IsLearned': instance.isLearned,
      'ReviewCount': instance.reviewCount,
    };

_$FlashcardSessionResultImpl _$$FlashcardSessionResultImplFromJson(
  Map<String, dynamic> json,
) => _$FlashcardSessionResultImpl(
  deckId: json['DeckId'] as String,
  learnedCount: (json['LearnedCount'] as num).toInt(),
  totalCards: (json['TotalCards'] as num).toInt(),
  coinEarned: (json['CoinEarned'] as num).toInt(),
  isFirstCompletion: json['IsFirstCompletion'] as bool,
);

Map<String, dynamic> _$$FlashcardSessionResultImplToJson(
  _$FlashcardSessionResultImpl instance,
) => <String, dynamic>{
  'DeckId': instance.deckId,
  'LearnedCount': instance.learnedCount,
  'TotalCards': instance.totalCards,
  'CoinEarned': instance.coinEarned,
  'IsFirstCompletion': instance.isFirstCompletion,
};
