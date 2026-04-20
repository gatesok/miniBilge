import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme_provider.dart';
import '../models/child_profile_dto.dart';
import 'child_profile_provider.dart';

const String _selectedChildIdKey = 'selected_child_id';

class SelectedChildNotifier extends StateNotifier<ChildProfileDto?> {
  final SharedPreferences _prefs;
  final Ref _ref;

  SelectedChildNotifier(this._prefs, this._ref) : super(null) {
    _loadLastSelected();
  }

  /// Load last selected child from SharedPreferences
  Future<void> _loadLastSelected() async {
    final childId = _prefs.getString(_selectedChildIdKey);
    
    if (childId != null) {
      // Try to find this child in the loaded profiles
      final profileState = _ref.read(childProfileProvider);
      profileState.maybeWhen(
        loaded: (profiles) {
          final child = profiles.firstWhere(
            (p) => p.id == childId,
            orElse: () => profiles.isNotEmpty ? profiles.first : throw Exception('No profiles'),
          );
          state = child;
        },
        orElse: () {},
      );
    }
  }

  /// Select a child profile
  Future<void> selectChild(ChildProfileDto child) async {
    state = child;
    await _prefs.setString(_selectedChildIdKey, child.id);
  }

  /// Auto-select child (used for single child or first-time)
  Future<void> autoSelectChild(List<ChildProfileDto> profiles) async {
    if (profiles.isEmpty) {
      state = null;
      return;
    }

    // If only one child, auto-select
    if (profiles.length == 1) {
      await selectChild(profiles.first);
      return;
    }

    // Check if we have a saved selection
    final savedId = _prefs.getString(_selectedChildIdKey);
    if (savedId != null) {
      final savedChild = profiles.firstWhere(
        (p) => p.id == savedId,
        orElse: () => profiles.first,
      );
      state = savedChild;
    }
  }

  /// Clear selected child
  Future<void> clearSelection() async {
    state = null;
    await _prefs.remove(_selectedChildIdKey);
  }

  /// Check if a child is currently selected
  bool get hasSelection => state != null;
}

final selectedChildProvider = StateNotifierProvider<SelectedChildNotifier, ChildProfileDto?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SelectedChildNotifier(prefs, ref);
});
