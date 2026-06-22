// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PodcastLineImpl _$$PodcastLineImplFromJson(Map<String, dynamic> json) =>
    _$PodcastLineImpl(
      id: json['Id'] as String,
      speakerName: json['SpeakerName'] as String,
      speakerGender: (json['SpeakerGender'] as num).toInt(),
      text: json['Text'] as String,
      translationTr: json['TranslationTr'] as String?,
      displayOrder: (json['DisplayOrder'] as num).toInt(),
      audioUrl: json['AudioUrl'] as String?,
      voiceKey: json['VoiceKey'] as String?,
    );

Map<String, dynamic> _$$PodcastLineImplToJson(_$PodcastLineImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'SpeakerName': instance.speakerName,
      'SpeakerGender': instance.speakerGender,
      'Text': instance.text,
      'TranslationTr': instance.translationTr,
      'DisplayOrder': instance.displayOrder,
      'AudioUrl': instance.audioUrl,
      'VoiceKey': instance.voiceKey,
    };

_$PodcastEpisodeSummaryImpl _$$PodcastEpisodeSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$PodcastEpisodeSummaryImpl(
  id: json['Id'] as String,
  title: json['Title'] as String,
  description: json['Description'] as String,
  englishLevel: (json['EnglishLevel'] as num).toInt(),
  displayOrder: (json['DisplayOrder'] as num).toInt(),
  lineCount: (json['LineCount'] as num).toInt(),
  estimatedDurationSeconds:
      (json['EstimatedDurationSeconds'] as num?)?.toInt() ?? 0,
  speakerNames: (json['SpeakerNames'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$PodcastEpisodeSummaryImplToJson(
  _$PodcastEpisodeSummaryImpl instance,
) => <String, dynamic>{
  'Id': instance.id,
  'Title': instance.title,
  'Description': instance.description,
  'EnglishLevel': instance.englishLevel,
  'DisplayOrder': instance.displayOrder,
  'LineCount': instance.lineCount,
  'EstimatedDurationSeconds': instance.estimatedDurationSeconds,
  'SpeakerNames': instance.speakerNames,
};

_$PodcastEpisodeImpl _$$PodcastEpisodeImplFromJson(Map<String, dynamic> json) =>
    _$PodcastEpisodeImpl(
      id: json['Id'] as String,
      title: json['Title'] as String,
      description: json['Description'] as String,
      englishLevel: (json['EnglishLevel'] as num).toInt(),
      displayOrder: (json['DisplayOrder'] as num).toInt(),
      lines: (json['Lines'] as List<dynamic>)
          .map((e) => PodcastLine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PodcastEpisodeImplToJson(
  _$PodcastEpisodeImpl instance,
) => <String, dynamic>{
  'Id': instance.id,
  'Title': instance.title,
  'Description': instance.description,
  'EnglishLevel': instance.englishLevel,
  'DisplayOrder': instance.displayOrder,
  'Lines': instance.lines,
};
