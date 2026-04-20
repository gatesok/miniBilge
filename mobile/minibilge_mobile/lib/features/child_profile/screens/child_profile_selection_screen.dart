import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/theme_switcher.dart';
import '../models/child_profile_dto.dart';
import '../providers/child_profile_provider.dart';
import '../providers/selected_child_provider.dart';

class ChildProfileSelectionScreen extends ConsumerStatefulWidget {
  const ChildProfileSelectionScreen({super.key});

  @override
  ConsumerState<ChildProfileSelectionScreen> createState() => _ChildProfileSelectionScreenState();
}

class _ChildProfileSelectionScreenState extends ConsumerState<ChildProfileSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-select logic after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final childProfileState = ref.read(childProfileProvider);
      childProfileState.maybeWhen(
        loaded: (profiles) async {
          if (profiles.length == 1) {
            // Auto-select single child and navigate to dashboard
            await ref.read(selectedChildProvider.notifier).selectChild(profiles.first);
            if (mounted) {
              context.go('/dashboard');
            }
          }
        },
        orElse: () {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final childProfileState = ref.watch(childProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kim Oynayacak?'),
        actions: [
          const ThemeSwitcher(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/child-profiles');
            },
            tooltip: 'Profil Yönetimi',
          ),
        ],
      ),
      body: childProfileState.when(
        initial: () => const Center(
          child: CircularProgressIndicator(),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        loaded: (profiles) {
          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.child_care,
                    size: 100,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Henüz çocuk profili yok',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/child-profile/add');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('İlk Profili Oluştur'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return _ProfileSelectionCard(
                profile: profile,
                onSelect: () async {
                  await ref.read(selectedChildProvider.notifier).selectChild(profile);
                  if (context.mounted) {
                    context.go('/dashboard');
                  }
                },
              );
            },
          );
        },
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(childProfileProvider.notifier).loadProfiles();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/child-profile/add');
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Profil Ekle'),
      ),    );
  }
}

class _ProfileSelectionCard extends StatelessWidget {
  final ChildProfileDto profile;
  final VoidCallback onSelect;

  const _ProfileSelectionCard({
    required this.profile,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.child_care,
                  size: 50,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                profile.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Age & Grade
              Text(
                '${profile.age} yaşında • ${profile.gradeLevelEnum?.displayName ?? profile.gradeLevel}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatChip(
                    icon: Icons.stars,
                    label: '${profile.totalStars} Yıldız',
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 16),
                  _StatChip(
                    icon: Icons.monetization_on,
                    label: '${profile.totalCoins} Coin',
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Play Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSelect,
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text(
                    'Oyna',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
