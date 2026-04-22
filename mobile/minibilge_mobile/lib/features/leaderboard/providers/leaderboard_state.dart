import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/leaderboard_entry.dart';

part 'leaderboard_state.freezed.dart';

@freezed
class LeaderboardState with _$LeaderboardState {
  const factory LeaderboardState.initial() = _Initial;
  const factory LeaderboardState.loading() = _Loading;
  const factory LeaderboardState.loaded({
    @Default([]) List<LeaderboardEntry> entries,
    LeaderboardEntry? myEntry,
  }) = _Loaded;
  const factory LeaderboardState.error(String message) = _Error;
}
