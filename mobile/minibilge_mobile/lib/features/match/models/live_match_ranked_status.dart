/// Maç öncesi sıralama-uygunluk durumu (GET /match/ranking-status).
class LiveMatchRankedStatus {
  const LiveMatchRankedStatus({
    required this.rankedRemainingToday,
    required this.dailyRankedLimit,
    required this.nextGameRanked,
    this.vsOpponentEligible,
  });

  final int rankedRemainingToday;
  final int dailyRankedLimit;
  final bool nextGameRanked;

  /// Rakip biliniyorsa (davet) o rakiple sıralama uygunluğu; kuyrukta null.
  final bool? vsOpponentEligible;

  factory LiveMatchRankedStatus.fromJson(Map<String, dynamic> json) {
    return LiveMatchRankedStatus(
      rankedRemainingToday: (json['RankedRemainingToday'] as num?)?.toInt() ?? 0,
      dailyRankedLimit: (json['DailyRankedLimit'] as num?)?.toInt() ?? 5,
      nextGameRanked: json['NextGameRanked'] as bool? ?? false,
      vsOpponentEligible: json['VsOpponentEligible'] as bool?,
    );
  }
}
