/// Challenge (Async Meydan Okuma) modelleri
/// Backend ChallengeDto'yu yansıtır — kod üretimi olmadan sade Dart sınıfları.

enum ChallengeStatus {
  pending,            // 0
  challengeeAccepted, // 1
  challengerDone,     // 2
  completed,          // 3
  expired,            // 4
  declined,           // 5
}

extension ChallengeStatusX on ChallengeStatus {
  static ChallengeStatus fromInt(int v) => ChallengeStatus.values[v.clamp(0, 5)];

  bool get isActive =>
      this == ChallengeStatus.pending ||
      this == ChallengeStatus.challengeeAccepted ||
      this == ChallengeStatus.challengerDone;

  bool get isFinished =>
      this == ChallengeStatus.completed ||
      this == ChallengeStatus.expired ||
      this == ChallengeStatus.declined;
}
extension ChallengeDtoX on ChallengeDto {
  /// Hatırlatma gönderilebilir mi? (null veya 24 saatten eski ise evet — günde 1 hak)
  bool get canSendReminder {
    if (lastReminderSentAt == null) return true;
    return DateTime.now().toUtc().difference(lastReminderSentAt!.toUtc()) >
        const Duration(hours: 24);
  }
}
class ChallengeDto {
  final String id;
  final String challengerId;
  final String challengerName;
  final String? challengerAvatarUrl;
  final String challengeeId;
  final String challengeeName;
  final String? challengeeAvatarUrl;
  final String levelId;
  final String levelName;
  final String subjectName;
  final ChallengeStatus status;
  final int? challengerScore;
  final int? challengeeScore;
  final int totalQuestions;
  final DateTime expiresAt;
  final DateTime createdAt;
  /// "Kazandın 🏆" / "Kaybettin 😔" / "Berabere 🤝" — null ise henüz tamamlanmamış
  final String? resultMessage;
  /// Son hatırlatma zamanı — 4 saat cooldown için
  final DateTime? lastReminderSentAt;

  const ChallengeDto({
    required this.id,
    required this.challengerId,
    required this.challengerName,
    this.challengerAvatarUrl,
    required this.challengeeId,
    required this.challengeeName,
    this.challengeeAvatarUrl,
    required this.levelId,
    required this.levelName,
    required this.subjectName,
    required this.status,
    this.challengerScore,
    this.challengeeScore,
    required this.totalQuestions,
    required this.expiresAt,
    required this.createdAt,
    this.resultMessage,
    this.lastReminderSentAt,
  });

  factory ChallengeDto.fromJson(Map<String, dynamic> json) => ChallengeDto(
        id:                  json['Id']?.toString()                 ?? '',
        challengerId:        json['ChallengerId']?.toString()       ?? '',
        challengerName:      json['ChallengerName']?.toString()     ?? '',
        challengerAvatarUrl: json['ChallengerAvatarUrl'] as String?,
        challengeeId:        json['ChallengeeId']?.toString()       ?? '',
        challengeeName:      json['ChallengeeName']?.toString()     ?? '',
        challengeeAvatarUrl: json['ChallengeeAvatarUrl'] as String?,
        levelId:             json['LevelId']?.toString()            ?? '',
        levelName:           json['LevelName']?.toString()          ?? '',
        subjectName:         json['SubjectName']?.toString()        ?? '',
        status:     ChallengeStatusX.fromInt((json['Status'] as num?)?.toInt() ?? 0),
        challengerScore: (json['ChallengerScore'] as num?)?.toInt(),
        challengeeScore: (json['ChallengeeScore'] as num?)?.toInt(),
        totalQuestions:  (json['TotalQuestions']  as num?)?.toInt() ?? 10,
        expiresAt: DateTime.parse(json['ExpiresAt'] as String),
        createdAt: DateTime.parse(json['CreatedAt'] as String),
        resultMessage: json['ResultMessage'] as String?,
        lastReminderSentAt: json['LastReminderSentAt'] == null
            ? null
            : DateTime.parse(json['LastReminderSentAt'] as String),
      );
}
