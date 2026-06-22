import 'package:freezed_annotation/freezed_annotation.dart';

part 'podcast_models.freezed.dart';
part 'podcast_models.g.dart';

/// 0: Male, 1: Female
enum SpeakerGender {
  male(0),
  female(1);

  const SpeakerGender(this.value);
  final int value;

  static SpeakerGender fromValue(int v) =>
      v == 1 ? SpeakerGender.female : SpeakerGender.male;
}

@freezed
class PodcastLine with _$PodcastLine {
  const factory PodcastLine({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'SpeakerName') required String speakerName,
    @JsonKey(name: 'SpeakerGender') required int speakerGender,
    @JsonKey(name: 'Text') required String text,
    @JsonKey(name: 'TranslationTr') String? translationTr,
    @JsonKey(name: 'DisplayOrder') required int displayOrder,
  }) = _PodcastLine;

  factory PodcastLine.fromJson(Map<String, dynamic> json) =>
      _$PodcastLineFromJson(json);
}

extension PodcastLineX on PodcastLine {
  SpeakerGender get gender => SpeakerGender.fromValue(speakerGender);
}

@freezed
class PodcastEpisodeSummary with _$PodcastEpisodeSummary {
  const factory PodcastEpisodeSummary({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'Title') required String title,
    @JsonKey(name: 'Description') required String description,
    @JsonKey(name: 'EnglishLevel') required int englishLevel,
    @JsonKey(name: 'DisplayOrder') required int displayOrder,
    @JsonKey(name: 'LineCount') required int lineCount,
    @JsonKey(name: 'SpeakerNames') required List<String> speakerNames,
  }) = _PodcastEpisodeSummary;

  factory PodcastEpisodeSummary.fromJson(Map<String, dynamic> json) =>
      _$PodcastEpisodeSummaryFromJson(json);
}

@freezed
class PodcastEpisode with _$PodcastEpisode {
  const factory PodcastEpisode({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'Title') required String title,
    @JsonKey(name: 'Description') required String description,
    @JsonKey(name: 'EnglishLevel') required int englishLevel,
    @JsonKey(name: 'DisplayOrder') required int displayOrder,
    @JsonKey(name: 'Lines') required List<PodcastLine> lines,
  }) = _PodcastEpisode;

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) =>
      _$PodcastEpisodeFromJson(json);
}
