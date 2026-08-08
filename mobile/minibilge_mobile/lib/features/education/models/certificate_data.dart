class CertificateData {
  final String levelId;
  final String studentName;
  final String subjectCode;
  final String subjectName;
  final String topicName;
  final int correctCount;
  final int wrongCount;
  final int totalQuestions;
  final int scorePercentage;
  final DateTime completedAt;

  const CertificateData({
    required this.levelId,
    required this.studentName,
    required this.subjectCode,
    required this.subjectName,
    required this.topicName,
    required this.correctCount,
    required this.wrongCount,
    required this.totalQuestions,
    required this.scorePercentage,
    required this.completedAt,
  });

  bool get isEnglish => subjectCode.toLowerCase() == 'english';

  factory CertificateData.fromJson(Map<String, dynamic> json) {
    return CertificateData(
      levelId: json['levelId']?.toString() ?? '',
      studentName: json['studentName']?.toString() ?? 'Öğrenci',
      subjectCode: json['subjectCode']?.toString() ?? 'mathematics',
      subjectName: json['subjectName']?.toString() ?? 'Matematik',
      topicName: json['topicName']?.toString() ?? 'Quiz',
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      scorePercentage: (json['scorePercentage'] as num?)?.round() ?? 0,
      completedAt:
          DateTime.tryParse(json['completedAt']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}
