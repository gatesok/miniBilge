// Kelime Oyunu Seviyeleri modelleri — Backend WordleLevelDtos'u yansıtır
import 'wordle_models.dart';

class JokerRevealModel {
  final int    position;
  final String letter;
  const JokerRevealModel({required this.position, required this.letter});
  factory JokerRevealModel.fromJson(Map<String, dynamic> j) =>
      JokerRevealModel(
        position: j['Position'] as int? ?? 0,
        letter:   j['Letter']   as String? ?? '',
      );
}

class JokerResponseModel {
  final int    position;
  final String letter;
  final int    jokerTicketsLeft;
  const JokerResponseModel({
    required this.position,
    required this.letter,
    required this.jokerTicketsLeft,
  });
  factory JokerResponseModel.fromJson(Map<String, dynamic> j) =>
      JokerResponseModel(
        position:         j['Position']         as int? ?? 0,
        letter:           j['Letter']           as String? ?? '',
        jokerTicketsLeft: j['JokerTicketsLeft']  as int? ?? 0,
      );
}

class WordleLevelStateModel {
  final int    currentLevel;
  final int    highestLevel;
  final int    wordLength;
  final int    maxAttempts;
  final int    attemptsUsed;
  final String? hint;
  final bool   solved;
  final bool   finished;
  final bool   skipped;
  final int    skipTickets;
  final int    jokerTickets;
  final int    starsEarned;
  final List<WordleGuessModel>  guesses;
  final List<JokerRevealModel>  jokerReveals;

  const WordleLevelStateModel({
    required this.currentLevel,
    required this.highestLevel,
    required this.wordLength,
    required this.maxAttempts,
    required this.attemptsUsed,
    this.hint,
    required this.solved,
    required this.finished,
    required this.skipped,
    required this.skipTickets,
    required this.jokerTickets,
    required this.starsEarned,
    required this.guesses,
    required this.jokerReveals,
  });

  int get attemptsLeft => maxAttempts - attemptsUsed;

  factory WordleLevelStateModel.fromJson(Map<String, dynamic> j) =>
      WordleLevelStateModel(
        currentLevel: j['CurrentLevel'] as int? ?? 1,
        highestLevel: j['HighestLevel'] as int? ?? 1,
        wordLength:   j['WordLength']   as int? ?? 5,
        maxAttempts:  j['MaxAttempts']  as int? ?? 6,
        attemptsUsed: j['AttemptsUsed'] as int? ?? 0,
        hint:         j['Hint']         as String?,
        solved:       j['Solved']       as bool? ?? false,
        finished:     j['Finished']     as bool? ?? false,
        skipped:      j['Skipped']      as bool? ?? false,
        skipTickets:  j['SkipTickets']  as int? ?? 0,
        jokerTickets: j['JokerTickets'] as int? ?? 3,
        starsEarned:  j['StarsEarned']  as int? ?? 0,
        guesses: (j['Guesses'] as List? ?? [])
            .map((e) => WordleGuessModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        jokerReveals: (j['JokerReveals'] as List? ?? [])
            .map((e) => JokerRevealModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class WordleLevelSubmitResponse {
  final List<String> pattern;
  final bool   solved;
  final bool   finished;
  final int    attemptsLeft;
  final int    starsEarned;
  final String? answer;
  final String? shareText;
  final bool   levelUp;
  final bool   milestone;  // Her 10 seviyede kart drop

  const WordleLevelSubmitResponse({
    required this.pattern,
    required this.solved,
    required this.finished,
    required this.attemptsLeft,
    required this.starsEarned,
    this.answer,
    this.shareText,
    required this.levelUp,
    required this.milestone,
  });

  factory WordleLevelSubmitResponse.fromJson(Map<String, dynamic> j) =>
      WordleLevelSubmitResponse(
        pattern:     (j['Pattern']     as List? ?? []).cast<String>(),
        solved:       j['Solved']      as bool? ?? false,
        finished:     j['Finished']    as bool? ?? false,
        attemptsLeft: j['AttemptsLeft'] as int? ?? 0,
        starsEarned:  j['StarsEarned'] as int? ?? 0,
        answer:       j['Answer']      as String?,
        shareText:    j['ShareText']   as String?,
        levelUp:      j['LevelUp']     as bool? ?? false,
        milestone:    j['Milestone']   as bool? ?? false,
      );
}

class WordleLevelStatsModel {
  final int    currentLevel;
  final int    highestLevel;
  final int    totalSolved;
  final int    currentStreak;
  final int    bestStreak;
  final int    skipTickets;
  final double averageAttempts;

  const WordleLevelStatsModel({
    required this.currentLevel,
    required this.highestLevel,
    required this.totalSolved,
    required this.currentStreak,
    required this.bestStreak,
    required this.skipTickets,
    required this.averageAttempts,
  });

  factory WordleLevelStatsModel.fromJson(Map<String, dynamic> j) =>
      WordleLevelStatsModel(
        currentLevel:    j['CurrentLevel']   as int? ?? 1,
        highestLevel:    j['HighestLevel']   as int? ?? 1,
        totalSolved:     j['TotalSolved']    as int? ?? 0,
        currentStreak:   j['CurrentStreak']  as int? ?? 0,
        bestStreak:      j['BestStreak']     as int? ?? 0,
        skipTickets:     j['SkipTickets']    as int? ?? 0,
        averageAttempts: (j['AverageAttempts'] as num?)?.toDouble() ?? 0.0,
      );
}
