import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/theme_switcher.dart';
import '../../auth/providers/auth_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/providers/child_profile_provider.dart';
import '../../child_profile/models/child_profile_dto.dart';
import '../../progress/providers/progress_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedChild = ref.watch(selectedChildProvider);
    final childProfileState = ref.watch(childProfileProvider);
    
    // Wait for profiles to load
    final isLoadingProfiles = childProfileState.maybeWhen(
      initial: () => true,
      loading: () => true,
      orElse: () => false,
    );
    
    if (isLoadingProfiles) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Get current child from the provider list (has fresh data from backend)
    ChildProfileDto? currentChild = selectedChild;
    childProfileState.maybeWhen(
      loaded: (profiles) {
        if (selectedChild != null) {
          currentChild = profiles.firstWhere(
            (p) => p.id == selectedChild.id,
            orElse: () => selectedChild,
          );
        }
      },
      orElse: () {},
    );
    
    // Count total profiles
    final totalProfiles = childProfileState.maybeWhen(
      loaded: (profiles) => profiles.length,
      orElse: () => 0,
    );

    // If no child is selected after profiles loaded, redirect to selection
    if (currentChild == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.child_care, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Lütfen bir profil seçin'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/child-profile-selection'),
                child: const Text('Profil Seç'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hoş Geldin, ${currentChild!.name}!'),
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
                            currentChild!.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentChild!.age} yaşında • ${currentChild!.gradeLevel}',
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
                                '${currentChild!.totalStars}',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(width: 20),
                              Icon(Icons.monetization_on, size: 20, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                '${currentChild!.totalCoins}',
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

            // Progress Stats Card
            _ProgressStatsCard(childId: currentChild!.id),
            const SizedBox(height: 24),

            // Avatar Section
            Text(
              'Avatar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Avatar Profile Card
            _SubjectCard(
              icon: Icons.person,
              title: 'Avatar Profilim',
              subtitle: 'Avatarını özelleştir ve eşyaları yönet',
              color: Colors.purple,
              enabled: true,
              onTap: () {
                context.push('/avatar/profile');
              },
            ),
            const SizedBox(height: 12),

            // Leaderboard Card
            _SubjectCard(
              icon: Icons.emoji_events,
              title: '🏆 Sıralama',
              subtitle: 'Diğer çocuklarla karşılaştır',
              color: Colors.amber,
              enabled: true,
              onTap: () {
                context.push('/leaderboard');
              },
            ),
            const SizedBox(height: 12),

            // Live Match Card
            _SubjectCard(
              icon: Icons.sports_esports,
              title: '⚔️ Canlı Yarış',
              subtitle: 'Diğer çocuklarla canlı matematik yarışı',
              color: Colors.red,
              enabled: true,
              onTap: () {
                context.go('/match/request');
              },
            ),
            const SizedBox(height: 12),

            // Match History Card
            _SubjectCard(
              icon: Icons.history,
              title: '📋 Maç Geçmişi',
              subtitle: 'Geçmiş yarışlarını ve istatistiklerini gör',
              color: Colors.purple,
              enabled: currentChild != null,
              onTap: () {
                final childId = currentChild?.id;
                if (childId != null) {
                  context.push('/match/history?childId=$childId');
                }
              },
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

class _ProgressStatsCard extends ConsumerWidget {
  final String childId;

  const _ProgressStatsCard({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressAsync = ref.watch(childProgressProvider(childId));

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: progressAsync.when(
          data: (progress) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'İlerleme İstatistikleri',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.analytics,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Total Score
                    Expanded(
                      child: _StatBox(
                        icon: Icons.emoji_events,
                        iconColor: Colors.amber,
                        label: 'Toplam Puan',
                        value: progress.totalScore.toString(),
                        backgroundColor: Colors.amber.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Total Stars
                    Expanded(
                      child: _StatBox(
                        icon: Icons.star,
                        iconColor: Colors.orange,
                        label: 'Toplam Yıldız',
                        value: progress.totalStars.toString(),
                        backgroundColor: Colors.orange.withOpacity(0.1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Completed Levels
                    Expanded(
                      child: _StatBox(
                        icon: Icons.check_circle,
                        iconColor: Colors.green,
                        label: 'Tamamlanan',
                        value: progress.completedLevelsCount.toString(),
                        backgroundColor: Colors.green.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Henüz ilerleme kaydı yok. Quiz çözerek başla!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color backgroundColor;

  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
