class ActivitySummary {
  final int podcastsCompleted;
  final int challengesTotal;
  final int challengesWon;
  final int challengesLost;
  final int assignmentsCompleted;

  const ActivitySummary({
    required this.podcastsCompleted,
    required this.challengesTotal,
    required this.challengesWon,
    required this.challengesLost,
    required this.assignmentsCompleted,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) => ActivitySummary(
        podcastsCompleted: json['PodcastsCompleted'] as int? ?? 0,
        challengesTotal: json['ChallengesTotal'] as int? ?? 0,
        challengesWon: json['ChallengesWon'] as int? ?? 0,
        challengesLost: json['ChallengesLost'] as int? ?? 0,
        assignmentsCompleted: json['AssignmentsCompleted'] as int? ?? 0,
      );
}
