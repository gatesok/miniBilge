// Entertainment Quiz modelleri — Backend EntertainmentDtos'u yansıtır

class EntertainmentTopicModel {
  final String key;
  final String label;
  final String emoji;

  const EntertainmentTopicModel({
    required this.key,
    required this.label,
    required this.emoji,
  });

  factory EntertainmentTopicModel.fromJson(Map<String, dynamic> j) =>
      EntertainmentTopicModel(
        key:   j['Key']   as String? ?? '',
        label: j['Label'] as String? ?? '',
        emoji: j['Emoji'] as String? ?? '🎮',
      );
}

class EntertainmentQuestionModel {
  final int     id;
  final String  questionText;
  final String  optionA;
  final String  optionB;
  final String  optionC;
  final String  optionD;
  final String  correctAnswer; // "A"|"B"|"C"|"D"
  final String? explanation;

  const EntertainmentQuestionModel({
    required this.id,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.explanation,
  });

  factory EntertainmentQuestionModel.fromJson(Map<String, dynamic> j) =>
      EntertainmentQuestionModel(
        id:            j['Id']            as int?    ?? 0,
        questionText:  j['QuestionText']  as String? ?? '',
        optionA:       j['OptionA']       as String? ?? '',
        optionB:       j['OptionB']       as String? ?? '',
        optionC:       j['OptionC']       as String? ?? '',
        optionD:       j['OptionD']       as String? ?? '',
        correctAnswer: j['CorrectAnswer'] as String? ?? 'A',
        explanation:   j['Explanation']   as String?,
      );

  List<String> get options => [optionA, optionB, optionC, optionD];
  int get correctIndex => correctAnswer.codeUnitAt(0) - 'A'.codeUnitAt(0);
}

// ── Gerçek mi Uydurma mı? modeli ─────────────────────────────────────────────

class FactOrFictionQuestionModel {
  final int    id;
  final String statement;
  final bool   isReal;
  final String explanation;

  const FactOrFictionQuestionModel({
    required this.id,
    required this.statement,
    required this.isReal,
    required this.explanation,
  });

  factory FactOrFictionQuestionModel.fromJson(Map<String, dynamic> j) =>
      FactOrFictionQuestionModel(
        id:          j['Id']          as int?    ?? 0,
        statement:   j['Statement']   as String? ?? '',
        isReal:      j['IsReal']      as bool?   ?? false,
        explanation: j['Explanation'] as String? ?? '',
      );
}

// ── Kim Bu? modelleri ───────────────────────────────────────────────────────────

class KimBuSubjectModel {
  final int          id;
  final String       subject;
  final List<String> hints;         // 5 ipucu, muğlaktan açığa
  final List<String> options;       // 4 şık
  final String       correctAnswer;

  const KimBuSubjectModel({
    required this.id,
    required this.subject,
    required this.hints,
    required this.options,
    required this.correctAnswer,
  });

  factory KimBuSubjectModel.fromJson(Map<String, dynamic> j) =>
      KimBuSubjectModel(
        id:            j['Id']            as int?    ?? 0,
        subject:       j['Subject']       as String? ?? '',
        hints:         (j['Hints']   as List? ?? []).cast<String>(),
        options:       (j['Options'] as List? ?? []).cast<String>(),
        correctAnswer: j['CorrectAnswer'] as String? ?? '',
      );
}

class KimBuRoundModel {
  final List<KimBuSubjectModel> subjects;

  const KimBuRoundModel({required this.subjects});

  factory KimBuRoundModel.fromJson(Map<String, dynamic> j) => KimBuRoundModel(
        subjects: (j['Subjects'] as List? ?? [])
            .map((e) => KimBuSubjectModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Ne Ortak? modeli ──────────────────────────────────────────────────────────

class NeOrtakQuestionModel {
  final int          id;
  final List<String> clues;        // 4 ipucu
  final String       connection;   // gizli bağlantı
  final List<String> options;      // 4 şık
  final String       correctAnswer;
  final String       explanation;

  const NeOrtakQuestionModel({
    required this.id,
    required this.clues,
    required this.connection,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory NeOrtakQuestionModel.fromJson(Map<String, dynamic> j) =>
      NeOrtakQuestionModel(
        id:            j['Id']             as int?    ?? 0,
        clues:         (j['Clues']   as List? ?? []).cast<String>(),
        connection:    j['Connection']   as String? ?? '',
        options:       (j['Options'] as List? ?? []).cast<String>(),
        correctAnswer: j['CorrectAnswer'] as String? ?? '',
        explanation:   j['Explanation']  as String? ?? '',
      );
}
