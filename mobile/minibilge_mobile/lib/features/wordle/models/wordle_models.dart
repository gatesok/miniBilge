// Wordle modelleri — Backend WordleDtos'u yansıtır

class WordleTodayModel {
  final DateTime date;
  final int wordLength;
  final int maxAttempts;
  final int attemptsUsed;
  final bool solved;
  final bool finished;
  final List<WordleGuessModel> previousGuesses;

  const WordleTodayModel({
    required this.date,
    required this.wordLength,
    required this.maxAttempts,
    required this.attemptsUsed,
    required this.solved,
    required this.finished,
    required this.previousGuesses,
  });

  int get attemptsLeft => maxAttempts - attemptsUsed;

  factory WordleTodayModel.fromJson(Map<String, dynamic> j) => WordleTodayModel(
        date: DateTime.parse(j['Date'] as String),
        wordLength: j['WordLength']  as int? ?? 5,
        maxAttempts: j['MaxAttempts'] as int? ?? 6,
        attemptsUsed: j['AttemptsUsed'] as int? ?? 0,
        solved: j['Solved'] as bool? ?? false,
        finished: j['Finished'] as bool? ?? false,
        previousGuesses: (j['PreviousGuesses'] as List? ?? [])
            .map((e) => WordleGuessModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class WordleGuessModel {
  final String guess;

  /// "correct" | "present" | "absent" — her harf için
  final List<String> pattern;

  const WordleGuessModel({required this.guess, required this.pattern});

  factory WordleGuessModel.fromJson(Map<String, dynamic> j) => WordleGuessModel(
        guess: j['Guess'] as String? ?? '',
        pattern: (j['Pattern'] as List? ?? []).cast<String>(),
      );
}

class SubmitGuessResponse {
  final List<String> pattern;
  final bool solved;
  final bool finished;
  final int attemptsLeft;
  final String? answer;
  final String? shareText;

  const SubmitGuessResponse({
    required this.pattern,
    required this.solved,
    required this.finished,
    required this.attemptsLeft,
    this.answer,
    this.shareText,
  });

  factory SubmitGuessResponse.fromJson(Map<String, dynamic> j) =>
      SubmitGuessResponse(
        pattern: (j['Pattern'] as List? ?? []).cast<String>(),
        solved: j['Solved'] as bool? ?? false,
        finished: j['Finished'] as bool? ?? false,
        attemptsLeft: j['AttemptsLeft'] as int? ?? 0,
        answer: j['Answer'] as String?,
        shareText: j['ShareText'] as String?,
      );
}

class WordleStatsModel {
  final int totalPlayed;
  final int totalSolved;
  final int currentStreak;
  final int bestStreak;
  final double averageAttempts;
  final Map<int, int> guessDist;

  const WordleStatsModel({
    required this.totalPlayed,
    required this.totalSolved,
    required this.currentStreak,
    required this.bestStreak,
    required this.averageAttempts,
    required this.guessDist,
  });

  factory WordleStatsModel.fromJson(Map<String, dynamic> j) => WordleStatsModel(
        totalPlayed: j['TotalPlayed'] as int? ?? 0,
        totalSolved: j['TotalSolved'] as int? ?? 0,
        currentStreak: j['CurrentStreak'] as int? ?? 0,
        bestStreak: j['BestStreak'] as int? ?? 0,
        averageAttempts: (j['AverageAttempts'] as num?)?.toDouble() ?? 0.0,
        guessDist: (j['GuessDist'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(int.parse(k), v as int)),
      );
}
