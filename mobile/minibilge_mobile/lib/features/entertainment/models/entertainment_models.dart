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
  final String  questionText;
  final String  optionA;
  final String  optionB;
  final String  optionC;
  final String  optionD;
  final String  correctAnswer; // "A"|"B"|"C"|"D"
  final String? explanation;

  const EntertainmentQuestionModel({
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
