// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PodcastLine _$PodcastLineFromJson(Map<String, dynamic> json) {
  return _PodcastLine.fromJson(json);
}

/// @nodoc
mixin _$PodcastLine {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'SpeakerName')
  String get speakerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'SpeakerGender')
  int get speakerGender => throw _privateConstructorUsedError;
  @JsonKey(name: 'Text')
  String get text => throw _privateConstructorUsedError;
  @JsonKey(name: 'TranslationTr')
  String? get translationTr => throw _privateConstructorUsedError;
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder => throw _privateConstructorUsedError;

  /// Serializes this PodcastLine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PodcastLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastLineCopyWith<PodcastLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastLineCopyWith<$Res> {
  factory $PodcastLineCopyWith(
    PodcastLine value,
    $Res Function(PodcastLine) then,
  ) = _$PodcastLineCopyWithImpl<$Res, PodcastLine>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'SpeakerName') String speakerName,
    @JsonKey(name: 'SpeakerGender') int speakerGender,
    @JsonKey(name: 'Text') String text,
    @JsonKey(name: 'TranslationTr') String? translationTr,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
  });
}

/// @nodoc
class _$PodcastLineCopyWithImpl<$Res, $Val extends PodcastLine>
    implements $PodcastLineCopyWith<$Res> {
  _$PodcastLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? speakerName = null,
    Object? speakerGender = null,
    Object? text = null,
    Object? translationTr = freezed,
    Object? displayOrder = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            speakerName: null == speakerName
                ? _value.speakerName
                : speakerName // ignore: cast_nullable_to_non_nullable
                      as String,
            speakerGender: null == speakerGender
                ? _value.speakerGender
                : speakerGender // ignore: cast_nullable_to_non_nullable
                      as int,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            translationTr: freezed == translationTr
                ? _value.translationTr
                : translationTr // ignore: cast_nullable_to_non_nullable
                      as String?,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PodcastLineImplCopyWith<$Res>
    implements $PodcastLineCopyWith<$Res> {
  factory _$$PodcastLineImplCopyWith(
    _$PodcastLineImpl value,
    $Res Function(_$PodcastLineImpl) then,
  ) = __$$PodcastLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'SpeakerName') String speakerName,
    @JsonKey(name: 'SpeakerGender') int speakerGender,
    @JsonKey(name: 'Text') String text,
    @JsonKey(name: 'TranslationTr') String? translationTr,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
  });
}

/// @nodoc
class __$$PodcastLineImplCopyWithImpl<$Res>
    extends _$PodcastLineCopyWithImpl<$Res, _$PodcastLineImpl>
    implements _$$PodcastLineImplCopyWith<$Res> {
  __$$PodcastLineImplCopyWithImpl(
    _$PodcastLineImpl _value,
    $Res Function(_$PodcastLineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PodcastLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? speakerName = null,
    Object? speakerGender = null,
    Object? text = null,
    Object? translationTr = freezed,
    Object? displayOrder = null,
  }) {
    return _then(
      _$PodcastLineImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        speakerName: null == speakerName
            ? _value.speakerName
            : speakerName // ignore: cast_nullable_to_non_nullable
                  as String,
        speakerGender: null == speakerGender
            ? _value.speakerGender
            : speakerGender // ignore: cast_nullable_to_non_nullable
                  as int,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        translationTr: freezed == translationTr
            ? _value.translationTr
            : translationTr // ignore: cast_nullable_to_non_nullable
                  as String?,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastLineImpl implements _PodcastLine {
  const _$PodcastLineImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'SpeakerName') required this.speakerName,
    @JsonKey(name: 'SpeakerGender') required this.speakerGender,
    @JsonKey(name: 'Text') required this.text,
    @JsonKey(name: 'TranslationTr') this.translationTr,
    @JsonKey(name: 'DisplayOrder') required this.displayOrder,
  });

  factory _$PodcastLineImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastLineImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'SpeakerName')
  final String speakerName;
  @override
  @JsonKey(name: 'SpeakerGender')
  final int speakerGender;
  @override
  @JsonKey(name: 'Text')
  final String text;
  @override
  @JsonKey(name: 'TranslationTr')
  final String? translationTr;
  @override
  @JsonKey(name: 'DisplayOrder')
  final int displayOrder;

  @override
  String toString() {
    return 'PodcastLine(id: $id, speakerName: $speakerName, speakerGender: $speakerGender, text: $text, translationTr: $translationTr, displayOrder: $displayOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastLineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.speakerName, speakerName) ||
                other.speakerName == speakerName) &&
            (identical(other.speakerGender, speakerGender) ||
                other.speakerGender == speakerGender) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.translationTr, translationTr) ||
                other.translationTr == translationTr) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    speakerName,
    speakerGender,
    text,
    translationTr,
    displayOrder,
  );

  /// Create a copy of PodcastLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastLineImplCopyWith<_$PodcastLineImpl> get copyWith =>
      __$$PodcastLineImplCopyWithImpl<_$PodcastLineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastLineImplToJson(this);
  }
}

abstract class _PodcastLine implements PodcastLine {
  const factory _PodcastLine({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'SpeakerName') required final String speakerName,
    @JsonKey(name: 'SpeakerGender') required final int speakerGender,
    @JsonKey(name: 'Text') required final String text,
    @JsonKey(name: 'TranslationTr') final String? translationTr,
    @JsonKey(name: 'DisplayOrder') required final int displayOrder,
  }) = _$PodcastLineImpl;

  factory _PodcastLine.fromJson(Map<String, dynamic> json) =
      _$PodcastLineImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'SpeakerName')
  String get speakerName;
  @override
  @JsonKey(name: 'SpeakerGender')
  int get speakerGender;
  @override
  @JsonKey(name: 'Text')
  String get text;
  @override
  @JsonKey(name: 'TranslationTr')
  String? get translationTr;
  @override
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder;

  /// Create a copy of PodcastLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastLineImplCopyWith<_$PodcastLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PodcastEpisodeSummary _$PodcastEpisodeSummaryFromJson(
  Map<String, dynamic> json,
) {
  return _PodcastEpisodeSummary.fromJson(json);
}

/// @nodoc
mixin _$PodcastEpisodeSummary {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Title')
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'Description')
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'EnglishLevel')
  int get englishLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'LineCount')
  int get lineCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'SpeakerNames')
  List<String> get speakerNames => throw _privateConstructorUsedError;

  /// Serializes this PodcastEpisodeSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PodcastEpisodeSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastEpisodeSummaryCopyWith<PodcastEpisodeSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastEpisodeSummaryCopyWith<$Res> {
  factory $PodcastEpisodeSummaryCopyWith(
    PodcastEpisodeSummary value,
    $Res Function(PodcastEpisodeSummary) then,
  ) = _$PodcastEpisodeSummaryCopyWithImpl<$Res, PodcastEpisodeSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Title') String title,
    @JsonKey(name: 'Description') String description,
    @JsonKey(name: 'EnglishLevel') int englishLevel,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
    @JsonKey(name: 'LineCount') int lineCount,
    @JsonKey(name: 'SpeakerNames') List<String> speakerNames,
  });
}

/// @nodoc
class _$PodcastEpisodeSummaryCopyWithImpl<
  $Res,
  $Val extends PodcastEpisodeSummary
>
    implements $PodcastEpisodeSummaryCopyWith<$Res> {
  _$PodcastEpisodeSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastEpisodeSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? englishLevel = null,
    Object? displayOrder = null,
    Object? lineCount = null,
    Object? speakerNames = null,
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
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            englishLevel: null == englishLevel
                ? _value.englishLevel
                : englishLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            lineCount: null == lineCount
                ? _value.lineCount
                : lineCount // ignore: cast_nullable_to_non_nullable
                      as int,
            speakerNames: null == speakerNames
                ? _value.speakerNames
                : speakerNames // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PodcastEpisodeSummaryImplCopyWith<$Res>
    implements $PodcastEpisodeSummaryCopyWith<$Res> {
  factory _$$PodcastEpisodeSummaryImplCopyWith(
    _$PodcastEpisodeSummaryImpl value,
    $Res Function(_$PodcastEpisodeSummaryImpl) then,
  ) = __$$PodcastEpisodeSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Title') String title,
    @JsonKey(name: 'Description') String description,
    @JsonKey(name: 'EnglishLevel') int englishLevel,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
    @JsonKey(name: 'LineCount') int lineCount,
    @JsonKey(name: 'SpeakerNames') List<String> speakerNames,
  });
}

/// @nodoc
class __$$PodcastEpisodeSummaryImplCopyWithImpl<$Res>
    extends
        _$PodcastEpisodeSummaryCopyWithImpl<$Res, _$PodcastEpisodeSummaryImpl>
    implements _$$PodcastEpisodeSummaryImplCopyWith<$Res> {
  __$$PodcastEpisodeSummaryImplCopyWithImpl(
    _$PodcastEpisodeSummaryImpl _value,
    $Res Function(_$PodcastEpisodeSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PodcastEpisodeSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? englishLevel = null,
    Object? displayOrder = null,
    Object? lineCount = null,
    Object? speakerNames = null,
  }) {
    return _then(
      _$PodcastEpisodeSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        englishLevel: null == englishLevel
            ? _value.englishLevel
            : englishLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        lineCount: null == lineCount
            ? _value.lineCount
            : lineCount // ignore: cast_nullable_to_non_nullable
                  as int,
        speakerNames: null == speakerNames
            ? _value._speakerNames
            : speakerNames // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastEpisodeSummaryImpl implements _PodcastEpisodeSummary {
  const _$PodcastEpisodeSummaryImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'Title') required this.title,
    @JsonKey(name: 'Description') required this.description,
    @JsonKey(name: 'EnglishLevel') required this.englishLevel,
    @JsonKey(name: 'DisplayOrder') required this.displayOrder,
    @JsonKey(name: 'LineCount') required this.lineCount,
    @JsonKey(name: 'SpeakerNames') required final List<String> speakerNames,
  }) : _speakerNames = speakerNames;

  factory _$PodcastEpisodeSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastEpisodeSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'Title')
  final String title;
  @override
  @JsonKey(name: 'Description')
  final String description;
  @override
  @JsonKey(name: 'EnglishLevel')
  final int englishLevel;
  @override
  @JsonKey(name: 'DisplayOrder')
  final int displayOrder;
  @override
  @JsonKey(name: 'LineCount')
  final int lineCount;
  final List<String> _speakerNames;
  @override
  @JsonKey(name: 'SpeakerNames')
  List<String> get speakerNames {
    if (_speakerNames is EqualUnmodifiableListView) return _speakerNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_speakerNames);
  }

  @override
  String toString() {
    return 'PodcastEpisodeSummary(id: $id, title: $title, description: $description, englishLevel: $englishLevel, displayOrder: $displayOrder, lineCount: $lineCount, speakerNames: $speakerNames)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastEpisodeSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.englishLevel, englishLevel) ||
                other.englishLevel == englishLevel) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.lineCount, lineCount) ||
                other.lineCount == lineCount) &&
            const DeepCollectionEquality().equals(
              other._speakerNames,
              _speakerNames,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    englishLevel,
    displayOrder,
    lineCount,
    const DeepCollectionEquality().hash(_speakerNames),
  );

  /// Create a copy of PodcastEpisodeSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastEpisodeSummaryImplCopyWith<_$PodcastEpisodeSummaryImpl>
  get copyWith =>
      __$$PodcastEpisodeSummaryImplCopyWithImpl<_$PodcastEpisodeSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastEpisodeSummaryImplToJson(this);
  }
}

abstract class _PodcastEpisodeSummary implements PodcastEpisodeSummary {
  const factory _PodcastEpisodeSummary({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'Title') required final String title,
    @JsonKey(name: 'Description') required final String description,
    @JsonKey(name: 'EnglishLevel') required final int englishLevel,
    @JsonKey(name: 'DisplayOrder') required final int displayOrder,
    @JsonKey(name: 'LineCount') required final int lineCount,
    @JsonKey(name: 'SpeakerNames') required final List<String> speakerNames,
  }) = _$PodcastEpisodeSummaryImpl;

  factory _PodcastEpisodeSummary.fromJson(Map<String, dynamic> json) =
      _$PodcastEpisodeSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'Title')
  String get title;
  @override
  @JsonKey(name: 'Description')
  String get description;
  @override
  @JsonKey(name: 'EnglishLevel')
  int get englishLevel;
  @override
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder;
  @override
  @JsonKey(name: 'LineCount')
  int get lineCount;
  @override
  @JsonKey(name: 'SpeakerNames')
  List<String> get speakerNames;

  /// Create a copy of PodcastEpisodeSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastEpisodeSummaryImplCopyWith<_$PodcastEpisodeSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PodcastEpisode _$PodcastEpisodeFromJson(Map<String, dynamic> json) {
  return _PodcastEpisode.fromJson(json);
}

/// @nodoc
mixin _$PodcastEpisode {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Title')
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'Description')
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'EnglishLevel')
  int get englishLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'Lines')
  List<PodcastLine> get lines => throw _privateConstructorUsedError;

  /// Serializes this PodcastEpisode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PodcastEpisode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastEpisodeCopyWith<PodcastEpisode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastEpisodeCopyWith<$Res> {
  factory $PodcastEpisodeCopyWith(
    PodcastEpisode value,
    $Res Function(PodcastEpisode) then,
  ) = _$PodcastEpisodeCopyWithImpl<$Res, PodcastEpisode>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Title') String title,
    @JsonKey(name: 'Description') String description,
    @JsonKey(name: 'EnglishLevel') int englishLevel,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
    @JsonKey(name: 'Lines') List<PodcastLine> lines,
  });
}

/// @nodoc
class _$PodcastEpisodeCopyWithImpl<$Res, $Val extends PodcastEpisode>
    implements $PodcastEpisodeCopyWith<$Res> {
  _$PodcastEpisodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastEpisode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? englishLevel = null,
    Object? displayOrder = null,
    Object? lines = null,
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
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            englishLevel: null == englishLevel
                ? _value.englishLevel
                : englishLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            lines: null == lines
                ? _value.lines
                : lines // ignore: cast_nullable_to_non_nullable
                      as List<PodcastLine>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PodcastEpisodeImplCopyWith<$Res>
    implements $PodcastEpisodeCopyWith<$Res> {
  factory _$$PodcastEpisodeImplCopyWith(
    _$PodcastEpisodeImpl value,
    $Res Function(_$PodcastEpisodeImpl) then,
  ) = __$$PodcastEpisodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Title') String title,
    @JsonKey(name: 'Description') String description,
    @JsonKey(name: 'EnglishLevel') int englishLevel,
    @JsonKey(name: 'DisplayOrder') int displayOrder,
    @JsonKey(name: 'Lines') List<PodcastLine> lines,
  });
}

/// @nodoc
class __$$PodcastEpisodeImplCopyWithImpl<$Res>
    extends _$PodcastEpisodeCopyWithImpl<$Res, _$PodcastEpisodeImpl>
    implements _$$PodcastEpisodeImplCopyWith<$Res> {
  __$$PodcastEpisodeImplCopyWithImpl(
    _$PodcastEpisodeImpl _value,
    $Res Function(_$PodcastEpisodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PodcastEpisode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? englishLevel = null,
    Object? displayOrder = null,
    Object? lines = null,
  }) {
    return _then(
      _$PodcastEpisodeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        englishLevel: null == englishLevel
            ? _value.englishLevel
            : englishLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        lines: null == lines
            ? _value._lines
            : lines // ignore: cast_nullable_to_non_nullable
                  as List<PodcastLine>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastEpisodeImpl implements _PodcastEpisode {
  const _$PodcastEpisodeImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'Title') required this.title,
    @JsonKey(name: 'Description') required this.description,
    @JsonKey(name: 'EnglishLevel') required this.englishLevel,
    @JsonKey(name: 'DisplayOrder') required this.displayOrder,
    @JsonKey(name: 'Lines') required final List<PodcastLine> lines,
  }) : _lines = lines;

  factory _$PodcastEpisodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastEpisodeImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'Title')
  final String title;
  @override
  @JsonKey(name: 'Description')
  final String description;
  @override
  @JsonKey(name: 'EnglishLevel')
  final int englishLevel;
  @override
  @JsonKey(name: 'DisplayOrder')
  final int displayOrder;
  final List<PodcastLine> _lines;
  @override
  @JsonKey(name: 'Lines')
  List<PodcastLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  String toString() {
    return 'PodcastEpisode(id: $id, title: $title, description: $description, englishLevel: $englishLevel, displayOrder: $displayOrder, lines: $lines)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastEpisodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.englishLevel, englishLevel) ||
                other.englishLevel == englishLevel) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            const DeepCollectionEquality().equals(other._lines, _lines));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    englishLevel,
    displayOrder,
    const DeepCollectionEquality().hash(_lines),
  );

  /// Create a copy of PodcastEpisode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastEpisodeImplCopyWith<_$PodcastEpisodeImpl> get copyWith =>
      __$$PodcastEpisodeImplCopyWithImpl<_$PodcastEpisodeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastEpisodeImplToJson(this);
  }
}

abstract class _PodcastEpisode implements PodcastEpisode {
  const factory _PodcastEpisode({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'Title') required final String title,
    @JsonKey(name: 'Description') required final String description,
    @JsonKey(name: 'EnglishLevel') required final int englishLevel,
    @JsonKey(name: 'DisplayOrder') required final int displayOrder,
    @JsonKey(name: 'Lines') required final List<PodcastLine> lines,
  }) = _$PodcastEpisodeImpl;

  factory _PodcastEpisode.fromJson(Map<String, dynamic> json) =
      _$PodcastEpisodeImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'Title')
  String get title;
  @override
  @JsonKey(name: 'Description')
  String get description;
  @override
  @JsonKey(name: 'EnglishLevel')
  int get englishLevel;
  @override
  @JsonKey(name: 'DisplayOrder')
  int get displayOrder;
  @override
  @JsonKey(name: 'Lines')
  List<PodcastLine> get lines;

  /// Create a copy of PodcastEpisode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastEpisodeImplCopyWith<_$PodcastEpisodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
