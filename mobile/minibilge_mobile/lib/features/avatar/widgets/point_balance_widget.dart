import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../child_profile/providers/selected_child_provider.dart';

/// Widget that displays the current point balance for the selected child
class PointBalanceWidget extends ConsumerWidget {
  final bool showLabel;
  final TextStyle? pointsStyle;
  final TextStyle? labelStyle;

  const PointBalanceWidget({
    super.key,
    this.showLabel = true,
    this.pointsStyle,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChild = ref.watch(selectedChildProvider);

    if (selectedChild == null) {
      return const SizedBox.shrink();
    }

    final points = selectedChild.totalCoins;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.amber[900] : Colors.amber[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.amber[700]! : Colors.amber[300]!,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            color: isDarkMode ? Colors.amber[300] : Colors.amber[700],
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            points.toString(),
            style: pointsStyle ??
                TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.amber[100] : Colors.amber[900],
                ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              'Puan',
              style: labelStyle ??
                  TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.amber[200] : Colors.amber[800],
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact version for app bars
class CompactPointBalanceWidget extends ConsumerWidget {
  const CompactPointBalanceWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChild = ref.watch(selectedChildProvider);

    if (selectedChild == null) {
      return const SizedBox.shrink();
    }

    final points = selectedChild.totalCoins;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.amber[900] : Colors.amber[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            color: isDarkMode ? Colors.amber[300] : Colors.amber[700],
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            points.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.amber[100] : Colors.amber[900],
            ),
          ),
        ],
      ),
    );
  }
}
