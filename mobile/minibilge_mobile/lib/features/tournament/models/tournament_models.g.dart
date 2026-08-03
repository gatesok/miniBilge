// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TournamentWeekImpl _$$TournamentWeekImplFromJson(
  Map<String, dynamic> json,
) => _$TournamentWeekImpl(
  categoryKey: json['CategoryKey'] as String,
  categoryLabel: json['CategoryLabel'] as String,
  categoryEmoji: json['CategoryEmoji'] as String,
  weekStart: json['WeekStart'] as String,
  entries:
      (json['Entries'] as List<dynamic>?)
          ?.map(
            (e) =>
                TournamentLeaderboardEntry.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <TournamentLeaderboardEntry>[],
  me: json['Me'] == null
      ? null
      : TournamentLeaderboardEntry.fromJson(json['Me'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$TournamentWeekImplToJson(
  _$TournamentWeekImpl instance,
) => <String, dynamic>{
  'CategoryKey': instance.categoryKey,
  'CategoryLabel': instance.categoryLabel,
  'CategoryEmoji': instance.categoryEmoji,
  'WeekStart': instance.weekStart,
  'Entries': instance.entries,
  'Me': instance.me,
};

_$TournamentLeaderboardEntryImpl _$$TournamentLeaderboardEntryImplFromJson(
  Map<String, dynamic> json,
) => _$TournamentLeaderboardEntryImpl(
  childProfileId: json['ChildProfileId'] as String,
  childName: json['ChildName'] as String,
  avatarImageUrl: json['AvatarImageUrl'] as String?,
  points: (json['Points'] as num).toInt(),
  wins: (json['Wins'] as num).toInt(),
  gamesPlayed: (json['GamesPlayed'] as num).toInt(),
  rank: (json['Rank'] as num).toInt(),
);

Map<String, dynamic> _$$TournamentLeaderboardEntryImplToJson(
  _$TournamentLeaderboardEntryImpl instance,
) => <String, dynamic>{
  'ChildProfileId': instance.childProfileId,
  'ChildName': instance.childName,
  'AvatarImageUrl': instance.avatarImageUrl,
  'Points': instance.points,
  'Wins': instance.wins,
  'GamesPlayed': instance.gamesPlayed,
  'Rank': instance.rank,
};

_$TournamentCategoryImpl _$$TournamentCategoryImplFromJson(
  Map<String, dynamic> json,
) => _$TournamentCategoryImpl(
  key: json['Key'] as String,
  label: json['Label'] as String,
  emoji: json['Emoji'] as String,
);

Map<String, dynamic> _$$TournamentCategoryImplToJson(
  _$TournamentCategoryImpl instance,
) => <String, dynamic>{
  'Key': instance.key,
  'Label': instance.label,
  'Emoji': instance.emoji,
};
