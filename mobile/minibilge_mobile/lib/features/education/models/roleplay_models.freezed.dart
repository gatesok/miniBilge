// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'roleplay_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScenarioDto _$ScenarioDtoFromJson(Map<String, dynamic> json) {
  return _ScenarioDto.fromJson(json);
}

/// @nodoc
mixin _$ScenarioDto {
  @JsonKey(name: 'Key')
  String get key => throw _privateConstructorUsedError;
  @JsonKey(name: 'Title')
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'Description')
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'Level')
  String get level => throw _privateConstructorUsedError;
  @JsonKey(name: 'CharacterName')
  String get characterName => throw _privateConstructorUsedError;
  @JsonKey(name: 'CharacterRole')
  String get characterRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'Emoji')
  String get emoji => throw _privateConstructorUsedError;

  /// Serializes this ScenarioDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScenarioDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScenarioDtoCopyWith<ScenarioDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScenarioDtoCopyWith<$Res> {
  factory $ScenarioDtoCopyWith(
    ScenarioDto value,
    $Res Function(ScenarioDto) then,
  ) = _$ScenarioDtoCopyWithImpl<$Res, ScenarioDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'Key') String key,
    @JsonKey(name: 'Title') String title,
    @JsonKey(name: 'Description') String description,
    @JsonKey(name: 'Level') String level,
    @JsonKey(name: 'CharacterName') String characterName,
    @JsonKey(name: 'CharacterRole') String characterRole,
    @JsonKey(name: 'Emoji') String emoji,
  });
}

/// @nodoc
class _$ScenarioDtoCopyWithImpl<$Res, $Val extends ScenarioDto>
    implements $ScenarioDtoCopyWith<$Res> {
  _$ScenarioDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScenarioDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? title = null,
    Object? description = null,
    Object? level = null,
    Object? characterName = null,
    Object? characterRole = null,
    Object? emoji = null,
  }) {
    return _then(
      _value.copyWith(
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as String,
            characterName: null == characterName
                ? _value.characterName
                : characterName // ignore: cast_nullable_to_non_nullable
                      as String,
            characterRole: null == characterRole
                ? _value.characterRole
                : characterRole // ignore: cast_nullable_to_non_nullable
                      as String,
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScenarioDtoImplCopyWith<$Res>
    implements $ScenarioDtoCopyWith<$Res> {
  factory _$$ScenarioDtoImplCopyWith(
    _$ScenarioDtoImpl value,
    $Res Function(_$ScenarioDtoImpl) then,
  ) = __$$ScenarioDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Key') String key,
    @JsonKey(name: 'Title') String title,
    @JsonKey(name: 'Description') String description,
    @JsonKey(name: 'Level') String level,
    @JsonKey(name: 'CharacterName') String characterName,
    @JsonKey(name: 'CharacterRole') String characterRole,
    @JsonKey(name: 'Emoji') String emoji,
  });
}

/// @nodoc
class __$$ScenarioDtoImplCopyWithImpl<$Res>
    extends _$ScenarioDtoCopyWithImpl<$Res, _$ScenarioDtoImpl>
    implements _$$ScenarioDtoImplCopyWith<$Res> {
  __$$ScenarioDtoImplCopyWithImpl(
    _$ScenarioDtoImpl _value,
    $Res Function(_$ScenarioDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScenarioDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? title = null,
    Object? description = null,
    Object? level = null,
    Object? characterName = null,
    Object? characterRole = null,
    Object? emoji = null,
  }) {
    return _then(
      _$ScenarioDtoImpl(
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as String,
        characterName: null == characterName
            ? _value.characterName
            : characterName // ignore: cast_nullable_to_non_nullable
                  as String,
        characterRole: null == characterRole
            ? _value.characterRole
            : characterRole // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScenarioDtoImpl implements _ScenarioDto {
  const _$ScenarioDtoImpl({
    @JsonKey(name: 'Key') required this.key,
    @JsonKey(name: 'Title') required this.title,
    @JsonKey(name: 'Description') required this.description,
    @JsonKey(name: 'Level') required this.level,
    @JsonKey(name: 'CharacterName') required this.characterName,
    @JsonKey(name: 'CharacterRole') required this.characterRole,
    @JsonKey(name: 'Emoji') required this.emoji,
  });

  factory _$ScenarioDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScenarioDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Key')
  final String key;
  @override
  @JsonKey(name: 'Title')
  final String title;
  @override
  @JsonKey(name: 'Description')
  final String description;
  @override
  @JsonKey(name: 'Level')
  final String level;
  @override
  @JsonKey(name: 'CharacterName')
  final String characterName;
  @override
  @JsonKey(name: 'CharacterRole')
  final String characterRole;
  @override
  @JsonKey(name: 'Emoji')
  final String emoji;

  @override
  String toString() {
    return 'ScenarioDto(key: $key, title: $title, description: $description, level: $level, characterName: $characterName, characterRole: $characterRole, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScenarioDtoImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.characterName, characterName) ||
                other.characterName == characterName) &&
            (identical(other.characterRole, characterRole) ||
                other.characterRole == characterRole) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    key,
    title,
    description,
    level,
    characterName,
    characterRole,
    emoji,
  );

  /// Create a copy of ScenarioDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScenarioDtoImplCopyWith<_$ScenarioDtoImpl> get copyWith =>
      __$$ScenarioDtoImplCopyWithImpl<_$ScenarioDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScenarioDtoImplToJson(this);
  }
}

abstract class _ScenarioDto implements ScenarioDto {
  const factory _ScenarioDto({
    @JsonKey(name: 'Key') required final String key,
    @JsonKey(name: 'Title') required final String title,
    @JsonKey(name: 'Description') required final String description,
    @JsonKey(name: 'Level') required final String level,
    @JsonKey(name: 'CharacterName') required final String characterName,
    @JsonKey(name: 'CharacterRole') required final String characterRole,
    @JsonKey(name: 'Emoji') required final String emoji,
  }) = _$ScenarioDtoImpl;

  factory _ScenarioDto.fromJson(Map<String, dynamic> json) =
      _$ScenarioDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Key')
  String get key;
  @override
  @JsonKey(name: 'Title')
  String get title;
  @override
  @JsonKey(name: 'Description')
  String get description;
  @override
  @JsonKey(name: 'Level')
  String get level;
  @override
  @JsonKey(name: 'CharacterName')
  String get characterName;
  @override
  @JsonKey(name: 'CharacterRole')
  String get characterRole;
  @override
  @JsonKey(name: 'Emoji')
  String get emoji;

  /// Create a copy of ScenarioDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScenarioDtoImplCopyWith<_$ScenarioDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StartRolePlayResponse _$StartRolePlayResponseFromJson(
  Map<String, dynamic> json,
) {
  return _StartRolePlayResponse.fromJson(json);
}

/// @nodoc
mixin _$StartRolePlayResponse {
  @JsonKey(name: 'SessionId')
  String get sessionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'AssistantMessage')
  String get assistantMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'CharacterName')
  String get characterName => throw _privateConstructorUsedError;
  @JsonKey(name: 'CharacterRole')
  String get characterRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'ScenarioTitle')
  String get scenarioTitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'Emoji')
  String get emoji => throw _privateConstructorUsedError;

  /// Serializes this StartRolePlayResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StartRolePlayResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StartRolePlayResponseCopyWith<StartRolePlayResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StartRolePlayResponseCopyWith<$Res> {
  factory $StartRolePlayResponseCopyWith(
    StartRolePlayResponse value,
    $Res Function(StartRolePlayResponse) then,
  ) = _$StartRolePlayResponseCopyWithImpl<$Res, StartRolePlayResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'SessionId') String sessionId,
    @JsonKey(name: 'AssistantMessage') String assistantMessage,
    @JsonKey(name: 'CharacterName') String characterName,
    @JsonKey(name: 'CharacterRole') String characterRole,
    @JsonKey(name: 'ScenarioTitle') String scenarioTitle,
    @JsonKey(name: 'Emoji') String emoji,
  });
}

/// @nodoc
class _$StartRolePlayResponseCopyWithImpl<
  $Res,
  $Val extends StartRolePlayResponse
>
    implements $StartRolePlayResponseCopyWith<$Res> {
  _$StartRolePlayResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StartRolePlayResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? assistantMessage = null,
    Object? characterName = null,
    Object? characterRole = null,
    Object? scenarioTitle = null,
    Object? emoji = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            assistantMessage: null == assistantMessage
                ? _value.assistantMessage
                : assistantMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            characterName: null == characterName
                ? _value.characterName
                : characterName // ignore: cast_nullable_to_non_nullable
                      as String,
            characterRole: null == characterRole
                ? _value.characterRole
                : characterRole // ignore: cast_nullable_to_non_nullable
                      as String,
            scenarioTitle: null == scenarioTitle
                ? _value.scenarioTitle
                : scenarioTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StartRolePlayResponseImplCopyWith<$Res>
    implements $StartRolePlayResponseCopyWith<$Res> {
  factory _$$StartRolePlayResponseImplCopyWith(
    _$StartRolePlayResponseImpl value,
    $Res Function(_$StartRolePlayResponseImpl) then,
  ) = __$$StartRolePlayResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'SessionId') String sessionId,
    @JsonKey(name: 'AssistantMessage') String assistantMessage,
    @JsonKey(name: 'CharacterName') String characterName,
    @JsonKey(name: 'CharacterRole') String characterRole,
    @JsonKey(name: 'ScenarioTitle') String scenarioTitle,
    @JsonKey(name: 'Emoji') String emoji,
  });
}

/// @nodoc
class __$$StartRolePlayResponseImplCopyWithImpl<$Res>
    extends
        _$StartRolePlayResponseCopyWithImpl<$Res, _$StartRolePlayResponseImpl>
    implements _$$StartRolePlayResponseImplCopyWith<$Res> {
  __$$StartRolePlayResponseImplCopyWithImpl(
    _$StartRolePlayResponseImpl _value,
    $Res Function(_$StartRolePlayResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StartRolePlayResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? assistantMessage = null,
    Object? characterName = null,
    Object? characterRole = null,
    Object? scenarioTitle = null,
    Object? emoji = null,
  }) {
    return _then(
      _$StartRolePlayResponseImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        assistantMessage: null == assistantMessage
            ? _value.assistantMessage
            : assistantMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        characterName: null == characterName
            ? _value.characterName
            : characterName // ignore: cast_nullable_to_non_nullable
                  as String,
        characterRole: null == characterRole
            ? _value.characterRole
            : characterRole // ignore: cast_nullable_to_non_nullable
                  as String,
        scenarioTitle: null == scenarioTitle
            ? _value.scenarioTitle
            : scenarioTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StartRolePlayResponseImpl implements _StartRolePlayResponse {
  const _$StartRolePlayResponseImpl({
    @JsonKey(name: 'SessionId') required this.sessionId,
    @JsonKey(name: 'AssistantMessage') required this.assistantMessage,
    @JsonKey(name: 'CharacterName') required this.characterName,
    @JsonKey(name: 'CharacterRole') required this.characterRole,
    @JsonKey(name: 'ScenarioTitle') required this.scenarioTitle,
    @JsonKey(name: 'Emoji') required this.emoji,
  });

  factory _$StartRolePlayResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StartRolePlayResponseImplFromJson(json);

  @override
  @JsonKey(name: 'SessionId')
  final String sessionId;
  @override
  @JsonKey(name: 'AssistantMessage')
  final String assistantMessage;
  @override
  @JsonKey(name: 'CharacterName')
  final String characterName;
  @override
  @JsonKey(name: 'CharacterRole')
  final String characterRole;
  @override
  @JsonKey(name: 'ScenarioTitle')
  final String scenarioTitle;
  @override
  @JsonKey(name: 'Emoji')
  final String emoji;

  @override
  String toString() {
    return 'StartRolePlayResponse(sessionId: $sessionId, assistantMessage: $assistantMessage, characterName: $characterName, characterRole: $characterRole, scenarioTitle: $scenarioTitle, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StartRolePlayResponseImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.assistantMessage, assistantMessage) ||
                other.assistantMessage == assistantMessage) &&
            (identical(other.characterName, characterName) ||
                other.characterName == characterName) &&
            (identical(other.characterRole, characterRole) ||
                other.characterRole == characterRole) &&
            (identical(other.scenarioTitle, scenarioTitle) ||
                other.scenarioTitle == scenarioTitle) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    assistantMessage,
    characterName,
    characterRole,
    scenarioTitle,
    emoji,
  );

  /// Create a copy of StartRolePlayResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StartRolePlayResponseImplCopyWith<_$StartRolePlayResponseImpl>
  get copyWith =>
      __$$StartRolePlayResponseImplCopyWithImpl<_$StartRolePlayResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StartRolePlayResponseImplToJson(this);
  }
}

abstract class _StartRolePlayResponse implements StartRolePlayResponse {
  const factory _StartRolePlayResponse({
    @JsonKey(name: 'SessionId') required final String sessionId,
    @JsonKey(name: 'AssistantMessage') required final String assistantMessage,
    @JsonKey(name: 'CharacterName') required final String characterName,
    @JsonKey(name: 'CharacterRole') required final String characterRole,
    @JsonKey(name: 'ScenarioTitle') required final String scenarioTitle,
    @JsonKey(name: 'Emoji') required final String emoji,
  }) = _$StartRolePlayResponseImpl;

  factory _StartRolePlayResponse.fromJson(Map<String, dynamic> json) =
      _$StartRolePlayResponseImpl.fromJson;

  @override
  @JsonKey(name: 'SessionId')
  String get sessionId;
  @override
  @JsonKey(name: 'AssistantMessage')
  String get assistantMessage;
  @override
  @JsonKey(name: 'CharacterName')
  String get characterName;
  @override
  @JsonKey(name: 'CharacterRole')
  String get characterRole;
  @override
  @JsonKey(name: 'ScenarioTitle')
  String get scenarioTitle;
  @override
  @JsonKey(name: 'Emoji')
  String get emoji;

  /// Create a copy of StartRolePlayResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StartRolePlayResponseImplCopyWith<_$StartRolePlayResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SendTurnResponse _$SendTurnResponseFromJson(Map<String, dynamic> json) {
  return _SendTurnResponse.fromJson(json);
}

/// @nodoc
mixin _$SendTurnResponse {
  @JsonKey(name: 'AssistantMessage')
  String get assistantMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'GrammarNote')
  String? get grammarNote => throw _privateConstructorUsedError;
  @JsonKey(name: 'TurnCount')
  int get turnCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'MaxTurnsReached')
  bool get maxTurnsReached => throw _privateConstructorUsedError;

  /// Serializes this SendTurnResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SendTurnResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SendTurnResponseCopyWith<SendTurnResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendTurnResponseCopyWith<$Res> {
  factory $SendTurnResponseCopyWith(
    SendTurnResponse value,
    $Res Function(SendTurnResponse) then,
  ) = _$SendTurnResponseCopyWithImpl<$Res, SendTurnResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'AssistantMessage') String assistantMessage,
    @JsonKey(name: 'GrammarNote') String? grammarNote,
    @JsonKey(name: 'TurnCount') int turnCount,
    @JsonKey(name: 'MaxTurnsReached') bool maxTurnsReached,
  });
}

/// @nodoc
class _$SendTurnResponseCopyWithImpl<$Res, $Val extends SendTurnResponse>
    implements $SendTurnResponseCopyWith<$Res> {
  _$SendTurnResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SendTurnResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assistantMessage = null,
    Object? grammarNote = freezed,
    Object? turnCount = null,
    Object? maxTurnsReached = null,
  }) {
    return _then(
      _value.copyWith(
            assistantMessage: null == assistantMessage
                ? _value.assistantMessage
                : assistantMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            grammarNote: freezed == grammarNote
                ? _value.grammarNote
                : grammarNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            turnCount: null == turnCount
                ? _value.turnCount
                : turnCount // ignore: cast_nullable_to_non_nullable
                      as int,
            maxTurnsReached: null == maxTurnsReached
                ? _value.maxTurnsReached
                : maxTurnsReached // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SendTurnResponseImplCopyWith<$Res>
    implements $SendTurnResponseCopyWith<$Res> {
  factory _$$SendTurnResponseImplCopyWith(
    _$SendTurnResponseImpl value,
    $Res Function(_$SendTurnResponseImpl) then,
  ) = __$$SendTurnResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'AssistantMessage') String assistantMessage,
    @JsonKey(name: 'GrammarNote') String? grammarNote,
    @JsonKey(name: 'TurnCount') int turnCount,
    @JsonKey(name: 'MaxTurnsReached') bool maxTurnsReached,
  });
}

/// @nodoc
class __$$SendTurnResponseImplCopyWithImpl<$Res>
    extends _$SendTurnResponseCopyWithImpl<$Res, _$SendTurnResponseImpl>
    implements _$$SendTurnResponseImplCopyWith<$Res> {
  __$$SendTurnResponseImplCopyWithImpl(
    _$SendTurnResponseImpl _value,
    $Res Function(_$SendTurnResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SendTurnResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assistantMessage = null,
    Object? grammarNote = freezed,
    Object? turnCount = null,
    Object? maxTurnsReached = null,
  }) {
    return _then(
      _$SendTurnResponseImpl(
        assistantMessage: null == assistantMessage
            ? _value.assistantMessage
            : assistantMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        grammarNote: freezed == grammarNote
            ? _value.grammarNote
            : grammarNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        turnCount: null == turnCount
            ? _value.turnCount
            : turnCount // ignore: cast_nullable_to_non_nullable
                  as int,
        maxTurnsReached: null == maxTurnsReached
            ? _value.maxTurnsReached
            : maxTurnsReached // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SendTurnResponseImpl implements _SendTurnResponse {
  const _$SendTurnResponseImpl({
    @JsonKey(name: 'AssistantMessage') required this.assistantMessage,
    @JsonKey(name: 'GrammarNote') this.grammarNote,
    @JsonKey(name: 'TurnCount') required this.turnCount,
    @JsonKey(name: 'MaxTurnsReached') this.maxTurnsReached = false,
  });

  factory _$SendTurnResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SendTurnResponseImplFromJson(json);

  @override
  @JsonKey(name: 'AssistantMessage')
  final String assistantMessage;
  @override
  @JsonKey(name: 'GrammarNote')
  final String? grammarNote;
  @override
  @JsonKey(name: 'TurnCount')
  final int turnCount;
  @override
  @JsonKey(name: 'MaxTurnsReached')
  final bool maxTurnsReached;

  @override
  String toString() {
    return 'SendTurnResponse(assistantMessage: $assistantMessage, grammarNote: $grammarNote, turnCount: $turnCount, maxTurnsReached: $maxTurnsReached)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendTurnResponseImpl &&
            (identical(other.assistantMessage, assistantMessage) ||
                other.assistantMessage == assistantMessage) &&
            (identical(other.grammarNote, grammarNote) ||
                other.grammarNote == grammarNote) &&
            (identical(other.turnCount, turnCount) ||
                other.turnCount == turnCount) &&
            (identical(other.maxTurnsReached, maxTurnsReached) ||
                other.maxTurnsReached == maxTurnsReached));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    assistantMessage,
    grammarNote,
    turnCount,
    maxTurnsReached,
  );

  /// Create a copy of SendTurnResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendTurnResponseImplCopyWith<_$SendTurnResponseImpl> get copyWith =>
      __$$SendTurnResponseImplCopyWithImpl<_$SendTurnResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SendTurnResponseImplToJson(this);
  }
}

abstract class _SendTurnResponse implements SendTurnResponse {
  const factory _SendTurnResponse({
    @JsonKey(name: 'AssistantMessage') required final String assistantMessage,
    @JsonKey(name: 'GrammarNote') final String? grammarNote,
    @JsonKey(name: 'TurnCount') required final int turnCount,
    @JsonKey(name: 'MaxTurnsReached') final bool maxTurnsReached,
  }) = _$SendTurnResponseImpl;

  factory _SendTurnResponse.fromJson(Map<String, dynamic> json) =
      _$SendTurnResponseImpl.fromJson;

  @override
  @JsonKey(name: 'AssistantMessage')
  String get assistantMessage;
  @override
  @JsonKey(name: 'GrammarNote')
  String? get grammarNote;
  @override
  @JsonKey(name: 'TurnCount')
  int get turnCount;
  @override
  @JsonKey(name: 'MaxTurnsReached')
  bool get maxTurnsReached;

  /// Create a copy of SendTurnResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendTurnResponseImplCopyWith<_$SendTurnResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EndSessionResponse _$EndSessionResponseFromJson(Map<String, dynamic> json) {
  return _EndSessionResponse.fromJson(json);
}

/// @nodoc
mixin _$EndSessionResponse {
  @JsonKey(name: 'Score')
  int get score => throw _privateConstructorUsedError;
  @JsonKey(name: 'Feedback')
  String get feedback => throw _privateConstructorUsedError;
  @JsonKey(name: 'TurnCount')
  int get turnCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'CoinsEarned')
  int get coinsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'StarsEarned')
  int get starsEarned => throw _privateConstructorUsedError;

  /// Serializes this EndSessionResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EndSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EndSessionResponseCopyWith<EndSessionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EndSessionResponseCopyWith<$Res> {
  factory $EndSessionResponseCopyWith(
    EndSessionResponse value,
    $Res Function(EndSessionResponse) then,
  ) = _$EndSessionResponseCopyWithImpl<$Res, EndSessionResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'Score') int score,
    @JsonKey(name: 'Feedback') String feedback,
    @JsonKey(name: 'TurnCount') int turnCount,
    @JsonKey(name: 'CoinsEarned') int coinsEarned,
    @JsonKey(name: 'StarsEarned') int starsEarned,
  });
}

/// @nodoc
class _$EndSessionResponseCopyWithImpl<$Res, $Val extends EndSessionResponse>
    implements $EndSessionResponseCopyWith<$Res> {
  _$EndSessionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EndSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? feedback = null,
    Object? turnCount = null,
    Object? coinsEarned = null,
    Object? starsEarned = null,
  }) {
    return _then(
      _value.copyWith(
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            feedback: null == feedback
                ? _value.feedback
                : feedback // ignore: cast_nullable_to_non_nullable
                      as String,
            turnCount: null == turnCount
                ? _value.turnCount
                : turnCount // ignore: cast_nullable_to_non_nullable
                      as int,
            coinsEarned: null == coinsEarned
                ? _value.coinsEarned
                : coinsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
            starsEarned: null == starsEarned
                ? _value.starsEarned
                : starsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EndSessionResponseImplCopyWith<$Res>
    implements $EndSessionResponseCopyWith<$Res> {
  factory _$$EndSessionResponseImplCopyWith(
    _$EndSessionResponseImpl value,
    $Res Function(_$EndSessionResponseImpl) then,
  ) = __$$EndSessionResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Score') int score,
    @JsonKey(name: 'Feedback') String feedback,
    @JsonKey(name: 'TurnCount') int turnCount,
    @JsonKey(name: 'CoinsEarned') int coinsEarned,
    @JsonKey(name: 'StarsEarned') int starsEarned,
  });
}

/// @nodoc
class __$$EndSessionResponseImplCopyWithImpl<$Res>
    extends _$EndSessionResponseCopyWithImpl<$Res, _$EndSessionResponseImpl>
    implements _$$EndSessionResponseImplCopyWith<$Res> {
  __$$EndSessionResponseImplCopyWithImpl(
    _$EndSessionResponseImpl _value,
    $Res Function(_$EndSessionResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EndSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? feedback = null,
    Object? turnCount = null,
    Object? coinsEarned = null,
    Object? starsEarned = null,
  }) {
    return _then(
      _$EndSessionResponseImpl(
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        feedback: null == feedback
            ? _value.feedback
            : feedback // ignore: cast_nullable_to_non_nullable
                  as String,
        turnCount: null == turnCount
            ? _value.turnCount
            : turnCount // ignore: cast_nullable_to_non_nullable
                  as int,
        coinsEarned: null == coinsEarned
            ? _value.coinsEarned
            : coinsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
        starsEarned: null == starsEarned
            ? _value.starsEarned
            : starsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EndSessionResponseImpl implements _EndSessionResponse {
  const _$EndSessionResponseImpl({
    @JsonKey(name: 'Score') required this.score,
    @JsonKey(name: 'Feedback') required this.feedback,
    @JsonKey(name: 'TurnCount') required this.turnCount,
    @JsonKey(name: 'CoinsEarned') this.coinsEarned = 0,
    @JsonKey(name: 'StarsEarned') this.starsEarned = 0,
  });

  factory _$EndSessionResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$EndSessionResponseImplFromJson(json);

  @override
  @JsonKey(name: 'Score')
  final int score;
  @override
  @JsonKey(name: 'Feedback')
  final String feedback;
  @override
  @JsonKey(name: 'TurnCount')
  final int turnCount;
  @override
  @JsonKey(name: 'CoinsEarned')
  final int coinsEarned;
  @override
  @JsonKey(name: 'StarsEarned')
  final int starsEarned;

  @override
  String toString() {
    return 'EndSessionResponse(score: $score, feedback: $feedback, turnCount: $turnCount, coinsEarned: $coinsEarned, starsEarned: $starsEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EndSessionResponseImpl &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback) &&
            (identical(other.turnCount, turnCount) ||
                other.turnCount == turnCount) &&
            (identical(other.coinsEarned, coinsEarned) ||
                other.coinsEarned == coinsEarned) &&
            (identical(other.starsEarned, starsEarned) ||
                other.starsEarned == starsEarned));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    score,
    feedback,
    turnCount,
    coinsEarned,
    starsEarned,
  );

  /// Create a copy of EndSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EndSessionResponseImplCopyWith<_$EndSessionResponseImpl> get copyWith =>
      __$$EndSessionResponseImplCopyWithImpl<_$EndSessionResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EndSessionResponseImplToJson(this);
  }
}

abstract class _EndSessionResponse implements EndSessionResponse {
  const factory _EndSessionResponse({
    @JsonKey(name: 'Score') required final int score,
    @JsonKey(name: 'Feedback') required final String feedback,
    @JsonKey(name: 'TurnCount') required final int turnCount,
    @JsonKey(name: 'CoinsEarned') final int coinsEarned,
    @JsonKey(name: 'StarsEarned') final int starsEarned,
  }) = _$EndSessionResponseImpl;

  factory _EndSessionResponse.fromJson(Map<String, dynamic> json) =
      _$EndSessionResponseImpl.fromJson;

  @override
  @JsonKey(name: 'Score')
  int get score;
  @override
  @JsonKey(name: 'Feedback')
  String get feedback;
  @override
  @JsonKey(name: 'TurnCount')
  int get turnCount;
  @override
  @JsonKey(name: 'CoinsEarned')
  int get coinsEarned;
  @override
  @JsonKey(name: 'StarsEarned')
  int get starsEarned;

  /// Create a copy of EndSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EndSessionResponseImplCopyWith<_$EndSessionResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get role => throw _privateConstructorUsedError; // 'user' | 'assistant'
  String get content => throw _privateConstructorUsedError;
  String? get grammarNote => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String role,
    String content,
    String? grammarNote,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
    Object? grammarNote = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            grammarNote: freezed == grammarNote
                ? _value.grammarNote
                : grammarNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String role,
    String content,
    String? grammarNote,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
    Object? grammarNote = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ChatMessageImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        grammarNote: freezed == grammarNote
            ? _value.grammarNote
            : grammarNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.role,
    required this.content,
    this.grammarNote,
    required this.createdAt,
  });

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String role;
  // 'user' | 'assistant'
  @override
  final String content;
  @override
  final String? grammarNote;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ChatMessage(role: $role, content: $content, grammarNote: $grammarNote, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.grammarNote, grammarNote) ||
                other.grammarNote == grammarNote) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, role, content, grammarNote, createdAt);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String role,
    required final String content,
    final String? grammarNote,
    required final DateTime createdAt,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get role; // 'user' | 'assistant'
  @override
  String get content;
  @override
  String? get grammarNote;
  @override
  DateTime get createdAt;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
