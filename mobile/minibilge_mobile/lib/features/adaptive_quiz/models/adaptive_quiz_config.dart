/// Adaptif quiz için kullanıcı seçimini temsil eder.
class AdaptiveQuizConfig {
  final String subjectName;  // "Matematik" | "İngilizce"
  final String levelDisplay; // "3. Sınıf" | "B2"
  final String topicName;    // Backend'e gönderilecek konu
  final int    gradeLevel;   // Matematik için sınıf (1-4), İngilizce için 1
  final int    difficulty;   // 1-3

  const AdaptiveQuizConfig({
    required this.subjectName,
    required this.levelDisplay,
    required this.topicName,
    required this.gradeLevel,
    required this.difficulty,
  });
}
