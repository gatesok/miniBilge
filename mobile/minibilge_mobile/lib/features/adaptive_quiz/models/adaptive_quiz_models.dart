// Adaptive Quiz modelleri — Backend AdaptiveQuizDtos'u yansıtır

class WeakTopicModel {
  final String subjectName;
  final String topicName;
  final double avgSuccessPercent;
  final int    attemptCount;
  final int    suggestedDifficulty;

  const WeakTopicModel({
    required this.subjectName,
    required this.topicName,
    required this.avgSuccessPercent,
    required this.attemptCount,
    required this.suggestedDifficulty,
  });

  factory WeakTopicModel.fromJson(Map<String, dynamic> j) => WeakTopicModel(
        subjectName:          j['SubjectName']  as String? ?? '',
        topicName:            j['TopicName']    as String? ?? '',
        avgSuccessPercent:   (j['AvgSuccessPercent'] as num?)?.toDouble() ?? 0,
        attemptCount:        (j['AttemptCount'] as num?)?.toInt() ?? 0,
        suggestedDifficulty: (j['SuggestedDifficulty'] as num?)?.toInt() ?? 2,
      );
}

class AdaptiveQuestionModel {
  final String id;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer; // "A"|"B"|"C"|"D"
  final String? explanation;
  final String subjectName;
  final String topicName;
  final int    difficulty;

  const AdaptiveQuestionModel({
    required this.id,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.explanation,
    required this.subjectName,
    required this.topicName,
    required this.difficulty,
  });

  factory AdaptiveQuestionModel.fromJson(Map<String, dynamic> j) =>
      AdaptiveQuestionModel(
        id:            j['Id']            as String? ?? '',
        questionText:  j['QuestionText']  as String? ?? '',
        optionA:       j['OptionA']       as String? ?? '',
        optionB:       j['OptionB']       as String? ?? '',
        optionC:       j['OptionC']       as String? ?? '',
        optionD:       j['OptionD']       as String? ?? '',
        correctAnswer: j['CorrectAnswer'] as String? ?? 'A',
        explanation:   j['Explanation']   as String?,
        subjectName:   j['SubjectName']   as String? ?? '',
        topicName:     j['TopicName']     as String? ?? '',
        difficulty:   (j['Difficulty']    as num?)?.toInt() ?? 2,
      );

  /// Şıkları liste olarak döner [A, B, C, D]
  List<String> get options => [optionA, optionB, optionC, optionD];

  /// Doğru cevabın index'i (0-3)
  int get correctIndex => correctAnswer.codeUnitAt(0) - 'A'.codeUnitAt(0);
}
