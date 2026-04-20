import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/theme_switcher.dart';
import '../../auth/providers/auth_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/providers/child_profile_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedChild = ref.watch(selectedChildProvider);
    final childProfileState = ref.watch(childProfileProvider);
    
    // Count total profiles
    final totalProfiles = childProfileState.maybeWhen(
      loaded: (profiles) => profiles.length,
      orElse: () => 0,
    );

    // If no child is selected, redirect to selection
    if (selectedChild == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/child-profile-selection');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hoş Geldin, ${selectedChild.name}!'),
        actions: [
          const ThemeSwitcher(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              await ref.read(selectedChildProvider.notifier).clearSelection();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.child_care,
                        size: 40,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedChild.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${selectedChild.age} yaşında • ${selectedChild.gradeLevel}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.stars, size: 20, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                '${selectedChild.totalStars}',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(width: 20),
                              Icon(Icons.monetization_on, size: 20, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                '${selectedChild.totalCoins}',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Subjects Section
            Text(
              'Dersler',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Math Module
            _SubjectCard(
              icon: Icons.calculate,
              title: 'Matematik',
              subtitle: 'Toplama, Çıkarma, Problemler',
              color: Colors.blue,
              enabled: true,
              onTap: () {
                context.push('/education/subjects');
              },
            ),
            const SizedBox(height: 12),

            // English Module (Coming Soon)
            _SubjectCard(
              icon: Icons.language,
              title: 'İngilizce',
              subtitle: 'Yakında',
              color: Colors.green,
              enabled: false,
              onTap: null,
            ),
            const SizedBox(height: 32),

            // Change Profile or Add Profile Button
            if (totalProfiles == 1)
              OutlinedButton.icon(
                onPressed: () {
                  context.push('/child-profile/add');
                },
                icon: const Icon(Icons.add),
                label: const Text('Yeni Profil Ekle'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () {
                  context.go('/child-profile-selection');
                },
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Profil Değiştir'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool enabled;
  final VoidCallback? onTap;

  const _SubjectCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: enabled ? 2 : 1,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(enabled ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: enabled ? color : color.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: enabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: enabled
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
