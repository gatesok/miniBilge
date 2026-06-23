// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flashcard_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FlashcardDeck _$FlashcardDeckFromJson(Map<String, dynamic> json) {
  return _FlashcardDeck.fromJson(json);
}

/// @nodoc
mixin _$FlashcardDeck {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Title')
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'Level')
  int get level => throw _privateConstructorUsedError;
  @JsonKey(name: 'EpisodeId')
  String? get episodeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalCards')
  int get totalCards => throw _privateConstructorUsedError;
  @JsonKey(name: 'LearnedCount')
  int get learnedCount => throw _privateConstructorUsedError;

  /// Serializes this FlashcardDeck to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlashcardDeck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlashcardDeckCopyWith<FlashcardDeck> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlashcardDeckCopyWith<$Res> {
  factory $FlashcardDeckCopyWith(
    FlashcardDeck value,
    $Res Function(FlashcardDeck) then,
  ) = _$FlashcardDeckCopyWithImpl<$Res, FlashcardDeck>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Title') String title,
    @JsonKey(name: 'Level') int level,
    @JsonKey(name: 'EpisodeId') String? episodeId,
    @JsonKey(name: 'TotalCards') int totalCards,
    @JsonKey(name: 'LearnedCount') int learnedCount,
  });
}

/// @nodoc
class _$FlashcardDeckCopyWithImpl<$Res, $Val extends FlashcardDeck>
    implements $FlashcardDeckCopyWith<$Res> {
  _$FlashcardDeckCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlashcardDeck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? level = null,
    Object? episodeId = freezed,
    Object? totalCards = null,
    Object? learnedCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            episodeId: freezed == episodeId
                ? _value.episodeId
                : episodeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalCards: null == totalCards
                ? _value.totalCards
                : totalCards // ignore: cast_nullable_to_non_nullable
                      as int,
            learnedCount: null == learnedCount
                ? _value.learnedCount
                : learnedCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FlashcardDeckImplCopyWith<$Res>
    implements $FlashcardDeckCopyWith<$Res> {
  factory _$$FlashcardDeckImplCopyWith(
    _$FlashcardDeckImpl value,
    $Res Function(_$FlashcardDeckImpl) then,
  ) = __$$FlashcardDeckImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Title') String title,
    @JsonKey(name: 'Level') int level,
    @JsonKey(name: 'EpisodeId') String? episodeId,
    @JsonKey(name: 'TotalCards') int totalCards,
    @JsonKey(name: 'LearnedCount') int learnedCount,
  });
}

/// @nodoc
class __$$FlashcardDeckImplCopyWithImpl<$Res>
    extends _$FlashcardDeckCopyWithImpl<$Res, _$FlashcardDeckImpl>
    implements _$$FlashcardDeckImplCopyWith<$Res> {
  __$$FlashcardDeckImplCopyWithImpl(
    _$FlashcardDeckImpl _value,
    $Res Function(_$FlashcardDeckImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FlashcardDeck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? level = null,
    Object? episodeId = freezed,
    Object? totalCards = null,
    Object? learnedCount = null,
  }) {
    return _then(
      _$FlashcardDeckImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        episodeId: freezed == episodeId
            ? _value.episodeId
            : episodeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalCards: null == totalCards
            ? _value.totalCards
            : totalCards // ignore: cast_nullable_to_non_nullable
                  as int,
        learnedCount: null == learnedCount
            ? _value.learnedCount
            : learnedCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FlashcardDeckImpl implements _FlashcardDeck {
  const _$FlashcardDeckImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'Title') required this.title,
    @JsonKey(name: 'Level') required this.level,
    @JsonKey(name: 'EpisodeId') this.episodeId,
    @JsonKey(name: 'TotalCards') required this.totalCards,
    @JsonKey(name: 'LearnedCount') required this.learnedCount,
  });

  factory _$FlashcardDeckImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlashcardDeckImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'Title')
  final String title;
  @override
  @JsonKey(name: 'Level')
  final int level;
  @override
  @JsonKey(name: 'EpisodeId')
  final String? episodeId;
  @override
  @JsonKey(name: 'TotalCards')
  final int totalCards;
  @override
  @JsonKey(name: 'LearnedCount')
  final int learnedCount;

  @override
  String toString() {
    return 'FlashcardDeck(id: $id, title: $title, level: $level, episodeId: $episodeId, totalCards: $totalCards, learnedCount: $learnedCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlashcardDeckImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.episodeId, episodeId) ||
                other.episodeId == episodeId) &&
            (identical(other.totalCards, totalCards) ||
                other.totalCards == totalCards) &&
            (identical(other.learnedCount, learnedCount) ||
                other.learnedCount == learnedCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    level,
    episodeId,
    totalCards,
    learnedCount,
  );

  /// Create a copy of FlashcardDeck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlashcardDeckImplCopyWith<_$FlashcardDeckImpl> get copyWith =>
      __$$FlashcardDeckImplCopyWithImpl<_$FlashcardDeckImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlashcardDeckImplToJson(this);
  }
}

abstract class _FlashcardDeck implements FlashcardDeck {
  const factory _FlashcardDeck({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'Title') required final String title,
    @JsonKey(name: 'Level') required final int level,
    @JsonKey(name: 'EpisodeId') final String? episodeId,
    @JsonKey(name: 'TotalCards') required final int totalCards,
    @JsonKey(name: 'LearnedCount') required final int learnedCount,
  }) = _$FlashcardDeckImpl;

  factory _FlashcardDeck.fromJson(Map<String, dynamic> json) =
      _$FlashcardDeckImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'Title')
  String get title;
  @override
  @JsonKey(name: 'Level')
  int get level;
  @override
  @JsonKey(name: 'EpisodeId')
  String? get episodeId;
  @override
  @JsonKey(name: 'TotalCards')
  int get totalCards;
  @override
  @JsonKey(name: 'LearnedCount')
  int get learnedCount;

  /// Create a copy of FlashcardDeck
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlashcardDeckImplCopyWith<_$FlashcardDeckImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FlashcardItem _$FlashcardItemFromJson(Map<String, dynamic> json) {
  return _FlashcardItem.fromJson(json);
}

/// @nodoc
mixin _$FlashcardItem {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'DeckId')
  String get deckId => throw _privateConstructorUsedError;
  @JsonKey(name: 'FrontText')
  String get frontText => throw _privateConstructorUsedError;
  @JsonKey(name: 'BackText')
  String get backText => throw _privateConstructorUsedError;
  @JsonKey(name: 'ExampleSentence')
  String? get exampleSentence => throw _privateConstructorUsedError;
  @JsonKey(name: 'AudioUrl')
  String? get audioUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'IsLearned')
  bool get isLearned => throw _privateConstructorUsedError;
  @JsonKey(name: 'ReviewCount')
  int get reviewCount => throw _privateConstructorUsedError;

  /// Serializes this FlashcardItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlashcardItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlashcardItemCopyWith<FlashcardItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlashcardItemCopyWith<$Res> {
  factory $FlashcardItemCopyWith(
    FlashcardItem value,
    $Res Function(FlashcardItem) then,
  ) = _$FlashcardItemCopyWithImpl<$Res, FlashcardItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'DeckId') String deckId,
    @JsonKey(name: 'FrontText') String frontText,
    @JsonKey(name: 'BackText') String backText,
    @JsonKey(name: 'ExampleSentence') String? exampleSentence,
    @JsonKey(name: 'AudioUrl') String? audioUrl,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
    @JsonKey(name: 'IsLearned') bool isLearned,
    @JsonKey(name: 'ReviewCount') int reviewCount,
  });
}

/// @nodoc
class _$FlashcardItemCopyWithImpl<$Res, $Val extends FlashcardItem>
    implements $FlashcardItemCopyWith<$Res> {
  _$FlashcardItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlashcardItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deckId = null,
    Object? frontText = null,
    Object? backText = null,
    Object? exampleSentence = freezed,
    Object? audioUrl = freezed,
    Object? displayOrder = null,
    Object? isLearned = null,
    Object? reviewCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            deckId: null == deckId
                ? _value.deckId
                : deckId // ignore: cast_nullable_to_non_nullable
                      as String,
            frontText: null == frontText
                ? _value.frontText
                : frontText // ignore: cast_nullable_to_non_nullable
                      as String,
            backText: null == backText
                ? _value.backText
                : backText // ignore: cast_nullable_to_non_nullable
                      as String,
            exampleSentence: freezed == exampleSentence
                ? _value.exampleSentence
                : exampleSentence // ignore: cast_nullable_to_non_nullable
                      as String?,
            audioUrl: freezed == audioUrl
                ? _value.audioUrl
                : audioUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isLearned: null == isLearned
                ? _value.isLearned
                : isLearned // ignore: cast_nullable_to_non_nullable
                      as bool,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FlashcardItemImplCopyWith<$Res>
    implements $FlashcardItemCopyWith<$Res> {
  factory _$$FlashcardItemImplCopyWith(
    _$FlashcardItemImpl value,
    $Res Function(_$FlashcardItemImpl) then,
  ) = __$$FlashcardItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'DeckId') String deckId,
    @JsonKey(name: 'FrontText') String frontText,
    @JsonKey(name: 'BackText') String backText,
    @JsonKey(name: 'ExampleSentence') String? exampleSentence,
    @JsonKey(name: 'AudioUrl') String? audioUrl,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
    @JsonKey(name: 'IsLearned') bool isLearned,
    @JsonKey(name: 'ReviewCount') int reviewCount,
  });
}

/// @nodoc
class __$$FlashcardItemImplCopyWithImpl<$Res>
    extends _$FlashcardItemCopyWithImpl<$Res, _$FlashcardItemImpl>
    implements _$$FlashcardItemImplCopyWith<$Res> {
  __$$FlashcardItemImplCopyWithImpl(
    _$FlashcardItemImpl _value,
    $Res Function(_$FlashcardItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FlashcardItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deckId = null,
    Object? frontText = null,
    Object? backText = null,
    Object? exampleSentence = freezed,
    Object? audioUrl = freezed,
    Object? displayOrder = null,
    Object? isLearned = null,
    Object? reviewCount = null,
  }) {
    return _then(
      _$FlashcardItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        deckId: null == deckId
            ? _value.deckId
            : deckId // ignore: cast_nullable_to_non_nullable
                  as String,
        frontText: null == frontText
            ? _value.frontText
            : frontText // ignore: cast_nullable_to_non_nullable
                  as String,
        backText: null == backText
            ? _value.backText
            : backText // ignore: cast_nullable_to_non_nullable
                  as String,
        exampleSentence: freezed == exampleSentence
            ? _value.exampleSentence
            : exampleSentence // ignore: cast_nullable_to_non_nullable
                  as String?,
        audioUrl: freezed == audioUrl
            ? _value.audioUrl
            : audioUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isLearned: null == isLearned
            ? _value.isLearned
            : isLearned // ignore: cast_nullable_to_non_nullable
                  as bool,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FlashcardItemImpl implements _FlashcardItem {
  const _$FlashcardItemImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'DeckId') required this.deckId,
    @JsonKey(name: 'FrontText') required this.frontText,
    @JsonKey(name: 'BackText') required this.backText,
    @JsonKey(name: 'ExampleSentence') this.exampleSentence,
    @JsonKey(name: 'AudioUrl') this.audioUrl,
    @JsonKey(name: 'DisplayOrder') required this.displayOrder,
    @JsonKey(name: 'IsLearned') required this.isLearned,
    @JsonKey(name: 'ReviewCount') required this.reviewCount,
  });

  factory _$FlashcardItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlashcardItemImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'DeckId')
  final String deckId;
  @override
  @JsonKey(name: 'FrontText')
  final String frontText;
  @override
  @JsonKey(name: 'BackText')
  final String backText;
  @override
  @JsonKey(name: 'ExampleSentence')
  final String? exampleSentence;
  @override
  @JsonKey(name: 'AudioUrl')
  final String? audioUrl;
  @override
  @JsonKey(name: 'DisplayOrder')
  final int displayOrder;
  @override
  @JsonKey(name: 'IsLearned')
  final bool isLearned;
  @override
  @JsonKey(name: 'ReviewCount')
  final int reviewCount;

  @override
  String toString() {
    return 'FlashcardItem(id: $id, deckId: $deckId, frontText: $frontText, backText: $backText, exampleSentence: $exampleSentence, audioUrl: $audioUrl, displayOrder: $displayOrder, isLearned: $isLearned, reviewCount: $reviewCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlashcardItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.frontText, frontText) ||
                other.frontText == frontText) &&
            (identical(other.backText, backText) ||
                other.backText == backText) &&
            (identical(other.exampleSentence, exampleSentence) ||
                other.exampleSentence == exampleSentence) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.isLearned, isLearned) ||
                other.isLearned == isLearned) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    deckId,
    frontText,
    backText,
    exampleSentence,
    audioUrl,
    displayOrder,
    isLearned,
    reviewCount,
  );

  /// Create a copy of FlashcardItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlashcardItemImplCopyWith<_$FlashcardItemImpl> get copyWith =>
      __$$FlashcardItemImplCopyWithImpl<_$FlashcardItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlashcardItemImplToJson(this);
  }
}

abstract class _FlashcardItem implements FlashcardItem {
  const factory _FlashcardItem({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'DeckId') required final String deckId,
    @JsonKey(name: 'FrontText') required final String frontText,
    @JsonKey(name: 'BackText') required final String backText,
    @JsonKey(name: 'ExampleSentence') final String? exampleSentence,
    @JsonKey(name: 'AudioUrl') final String? audioUrl,
    @JsonKey(name: 'DisplayOrder') required final int displayOrder,
    @JsonKey(name: 'IsLearned') required final bool isLearned,
    @JsonKey(name: 'ReviewCount') required final int reviewCount,
  }) = _$FlashcardItemImpl;

  factory _FlashcardItem.fromJson(Map<String, dynamic> json) =
      _$FlashcardItemImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'DeckId')
  String get deckId;
  @override
  @JsonKey(name: 'FrontText')
  String get frontText;
  @override
  @JsonKey(name: 'BackText')
  String get backText;
  @override
  @JsonKey(name: 'ExampleSentence')
  String? get exampleSentence;
  @override
  @JsonKey(name: 'AudioUrl')
  String? get audioUrl;
  @override
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder;
  @override
  @JsonKey(name: 'IsLearned')
  bool get isLearned;
  @override
  @JsonKey(name: 'ReviewCount')
  int get reviewCount;

  /// Create a copy of FlashcardItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlashcardItemImplCopyWith<_$FlashcardItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FlashcardSessionResult _$FlashcardSessionResultFromJson(
  Map<String, dynamic> json,
) {
  return _FlashcardSessionResult.fromJson(json);
}

/// @nodoc
mixin _$FlashcardSessionResult {
  @JsonKey(name: 'DeckId')
  String get deckId => throw _privateConstructorUsedError;
  @JsonKey(name: 'LearnedCount')
  int get learnedCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'TotalCards')
  int get totalCards => throw _privateConstructorUsedError;
  @JsonKey(name: 'StarEarned')
  int get starEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'IsFirstCompletion')
  bool get isFirstCompletion => throw _privateConstructorUsedError;

  /// Serializes this FlashcardSessionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlashcardSessionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlashcardSessionResultCopyWith<FlashcardSessionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlashcardSessionResultCopyWith<$Res> {
  factory $FlashcardSessionResultCopyWith(
    FlashcardSessionResult value,
    $Res Function(FlashcardSessionResult) then,
  ) = _$FlashcardSessionResultCopyWithImpl<$Res, FlashcardSessionResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'DeckId') String deckId,
    @JsonKey(name: 'LearnedCount') int learnedCount,
    @JsonKey(name: 'TotalCards') int totalCards,
    @JsonKey(name: 'StarEarned') int starEarned,
    @JsonKey(name: 'IsFirstCompletion') bool isFirstCompletion,
  });
}

/// @nodoc
class _$FlashcardSessionResultCopyWithImpl<
  $Res,
  $Val extends FlashcardSessionResult
>
    implements $FlashcardSessionResultCopyWith<$Res> {
  _$FlashcardSessionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlashcardSessionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deckId = null,
    Object? learnedCount = null,
    Object? totalCards = null,
    Object? starEarned = null,
    Object? isFirstCompletion = null,
  }) {
    return _then(
      _value.copyWith(
            deckId: null == deckId
                ? _value.deckId
                : deckId // ignore: cast_nullable_to_non_nullable
                      as String,
            learnedCount: null == learnedCount
                ? _value.learnedCount
                : learnedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCards: null == totalCards
                ? _value.totalCards
                : totalCards // ignore: cast_nullable_to_non_nullable
                      as int,
            starEarned: null == starEarned
                ? _value.starEarned
                : starEarned // ignore: cast_nullable_to_non_nullable
                      as int,
            isFirstCompletion: null == isFirstCompletion
                ? _value.isFirstCompletion
                : isFirstCompletion // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FlashcardSessionResultImplCopyWith<$Res>
    implements $FlashcardSessionResultCopyWith<$Res> {
  factory _$$FlashcardSessionResultImplCopyWith(
    _$FlashcardSessionResultImpl value,
    $Res Function(_$FlashcardSessionResultImpl) then,
  ) = __$$FlashcardSessionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'DeckId') String deckId,
    @JsonKey(name: 'LearnedCount') int learnedCount,
    @JsonKey(name: 'TotalCards') int totalCards,
    @JsonKey(name: 'StarEarned') int starEarned,
    @JsonKey(name: 'IsFirstCompletion') bool isFirstCompletion,
  });
}

/// @nodoc
class __$$FlashcardSessionResultImplCopyWithImpl<$Res>
    extends
        _$FlashcardSessionResultCopyWithImpl<$Res, _$FlashcardSessionResultImpl>
    implements _$$FlashcardSessionResultImplCopyWith<$Res> {
  __$$FlashcardSessionResultImplCopyWithImpl(
    _$FlashcardSessionResultImpl _value,
    $Res Function(_$FlashcardSessionResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FlashcardSessionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deckId = null,
    Object? learnedCount = null,
    Object? totalCards = null,
    Object? starEarned = null,
    Object? isFirstCompletion = null,
  }) {
    return _then(
      _$FlashcardSessionResultImpl(
        deckId: null == deckId
            ? _value.deckId
            : deckId // ignore: cast_nullable_to_non_nullable
                  as String,
        learnedCount: null == learnedCount
            ? _value.learnedCount
            : learnedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCards: null == totalCards
            ? _value.totalCards
            : totalCards // ignore: cast_nullable_to_non_nullable
                  as int,
        starEarned: null == starEarned
            ? _value.starEarned
            : starEarned // ignore: cast_nullable_to_non_nullable
                  as int,
        isFirstCompletion: null == isFirstCompletion
            ? _value.isFirstCompletion
            : isFirstCompletion // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FlashcardSessionResultImpl implements _FlashcardSessionResult {
  const _$FlashcardSessionResultImpl({
    @JsonKey(name: 'DeckId') required this.deckId,
    @JsonKey(name: 'LearnedCount') required this.learnedCount,
    @JsonKey(name: 'TotalCards') required this.totalCards,
    @JsonKey(name: 'StarEarned') required this.starEarned,
    @JsonKey(name: 'IsFirstCompletion') required this.isFirstCompletion,
  });

  factory _$FlashcardSessionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlashcardSessionResultImplFromJson(json);

  @override
  @JsonKey(name: 'DeckId')
  final String deckId;
  @override
  @JsonKey(name: 'LearnedCount')
  final int learnedCount;
  @override
  @JsonKey(name: 'TotalCards')
  final int totalCards;
  @override
  @JsonKey(name: 'StarEarned')
  final int starEarned;
  @override
  @JsonKey(name: 'IsFirstCompletion')
  final bool isFirstCompletion;

  @override
  String toString() {
    return 'FlashcardSessionResult(deckId: $deckId, learnedCount: $learnedCount, totalCards: $totalCards, starEarned: $starEarned, isFirstCompletion: $isFirstCompletion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlashcardSessionResultImpl &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.learnedCount, learnedCount) ||
                other.learnedCount == learnedCount) &&
            (identical(other.totalCards, totalCards) ||
                other.totalCards == totalCards) &&
            (identical(other.starEarned, starEarned) ||
                other.starEarned == starEarned) &&
            (identical(other.isFirstCompletion, isFirstCompletion) ||
                other.isFirstCompletion == isFirstCompletion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    deckId,
    learnedCount,
    totalCards,
    starEarned,
    isFirstCompletion,
  );

  /// Create a copy of FlashcardSessionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlashcardSessionResultImplCopyWith<_$FlashcardSessionResultImpl>
  get copyWith =>
      __$$FlashcardSessionResultImplCopyWithImpl<_$FlashcardSessionResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FlashcardSessionResultImplToJson(this);
  }
}

abstract class _FlashcardSessionResult implements FlashcardSessionResult {
  const factory _FlashcardSessionResult({
    @JsonKey(name: 'DeckId') required final String deckId,
    @JsonKey(name: 'LearnedCount') required final int learnedCount,
    @JsonKey(name: 'TotalCards') required final int totalCards,
    @JsonKey(name: 'StarEarned') required final int starEarned,
    @JsonKey(name: 'IsFirstCompletion') required final bool isFirstCompletion,
  }) = _$FlashcardSessionResultImpl;

  factory _FlashcardSessionResult.fromJson(Map<String, dynamic> json) =
      _$FlashcardSessionResultImpl.fromJson;

  @override
  @JsonKey(name: 'DeckId')
  String get deckId;
  @override
  @JsonKey(name: 'LearnedCount')
  int get learnedCount;
  @override
  @JsonKey(name: 'TotalCards')
  int get totalCards;
  @override
  @JsonKey(name: 'StarEarned')
  int get starEarned;
  @override
  @JsonKey(name: 'IsFirstCompletion')
  bool get isFirstCompletion;

  /// Create a copy of FlashcardSessionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlashcardSessionResultImplCopyWith<_$FlashcardSessionResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}
