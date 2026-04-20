import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';

/// Theme switcher widget - can be used in AppBar or Settings
class ThemeSwitcher extends ConsumerWidget {
  final bool showLabel;
  
  const ThemeSwitcher({
    super.key,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    
    if (showLabel) {
      return ListTile(
        leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
        title: const Text('Tema'),
        subtitle: Text(_getThemeModeLabel(themeMode)),
        trailing: Switch(
          value: isDark,
          onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
        ),
      );
    }
    
    return IconButton(
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      tooltip: isDark ? 'Light Mode' : 'Dark Mode',
      onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
    );
  }
  
  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Açık Tema';
      case ThemeMode.dark:
        return 'Koyu Tema';
      case ThemeMode.system:
        return 'Sistem Teması';
    }
  }
}
