import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../models/tournament_models.dart';
import '../services/tournament_service.dart';

/// Turnuva kategorileri (eğlence konuları).
final tournamentCategoriesProvider =
    FutureProvider<List<TournamentCategory>>((ref) async {
  return ref.watch(tournamentServiceProvider).getCategories();
});

/// Ekranda seçili turnuva kategorisi (varsayılan: genel_kultur).
final selectedTournamentCategoryProvider =
    StateProvider<String>((ref) => 'genel_kultur');

/// Seçili kategorinin bu haftaki sıralaması (aktif çocuk profili "me" için).
final tournamentWeeklyProvider =
    FutureProvider.family<TournamentWeek, String>((ref, category) async {
  final childId = ref.watch(selectedChildProvider)?.id;
  return ref.watch(tournamentServiceProvider).getWeekly(
        category: category,
        topN: 50,
        childProfileId: childId,
      );
});
