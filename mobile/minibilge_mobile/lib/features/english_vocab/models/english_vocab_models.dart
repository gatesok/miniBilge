// İngilizce Kelime Oyunu modelleri — Backend EnglishVocabDtos'u yansıtır.

class VocabQuestionModel {
  final int     id;
  final String  englishWord;
  final String  optionA;
  final String  optionB;
  final String  optionC;
  final String  optionD;
  final String  correctAnswer; // "A"|"B"|"C"|"D"
  final String? exampleSentence;

  const VocabQuestionModel({
    required this.id,
    required this.englishWord,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.exampleSentence,
  });

  factory VocabQuestionModel.fromJson(Map<String, dynamic> j) =>
      VocabQuestionModel(
        id:              j['Id']              as int?    ?? 0,
        englishWord:     j['EnglishWord']     as String? ?? '',
        optionA:         j['OptionA']         as String? ?? '',
        optionB:         j['OptionB']         as String? ?? '',
        optionC:         j['OptionC']         as String? ?? '',
        optionD:         j['OptionD']         as String? ?? '',
        correctAnswer:   j['CorrectAnswer']   as String? ?? 'A',
        exampleSentence: j['ExampleSentence'] as String?,
      );

  List<String> get options => [optionA, optionB, optionC, optionD];
  int get correctIndex => correctAnswer.codeUnitAt(0) - 'A'.codeUnitAt(0);
}
