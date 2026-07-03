/// Adaptif quiz için kullanıcı seçimini temsil eder.
class AdaptiveQuizConfig {
  final String  subjectName;
  final String  levelDisplay;
  final String  topicName;
  final int     gradeLevel;
  final int     difficulty;
  final String? englishLevel; // "B1", "B2" vb.

  const AdaptiveQuizConfig({
    required this.subjectName,
    required this.levelDisplay,
    required this.topicName,
    required this.gradeLevel,
    required this.difficulty,
    this.englishLevel,
  });
}
