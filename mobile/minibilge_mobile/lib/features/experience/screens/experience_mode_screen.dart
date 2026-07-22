import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../child_profile/providers/child_profile_provider.dart';
import '../models/experience_mode.dart';

class ExperienceModeScreen extends ConsumerStatefulWidget {
  const ExperienceModeScreen({super.key});

  @override
  ConsumerState<ExperienceModeScreen> createState() =>
      _ExperienceModeScreenState();
}

class _ExperienceModeScreenState extends ConsumerState<ExperienceModeScreen> {
  ExperienceMode? _selectedMode;
  bool _isSaving = false;

  Future<void> _continue() async {
    final mode = _selectedMode;
    if (mode == null || _isSaving) return;

    setState(() => _isSaving = true);
    final error = await ref
        .read(authProvider.notifier)
        .updateExperienceMode(mode);

    if (!mounted) return;
    if (error != null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red.shade700),
      );
      return;
    }

    await ref.read(childProfileProvider.notifier).loadProfiles();
    if (!mounted) return;

    final hasProfiles = ref
        .read(childProfileProvider)
        .maybeWhen(
          loaded: (profiles) => profiles.isNotEmpty,
          orElse: () => false,
        );
    context.go(hasProfiles ? '/child-profile-selection' : '/child-profiles');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.16),
              theme.colorScheme.secondary.withValues(alpha: 0.10),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'MiniBilge’yi nasıl\nkullanmak istersin?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sana uygun içerikleri öne çıkarmamız için bir deneyim seç.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _ModeCard(
                      emoji: '🧒',
                      title: 'Çocuk',
                      description:
                          'Matematik, İngilizce, güvenli oyunlar ve öğrenme yolculuğu',
                      color: const Color(0xFF4F8EF7),
                      selected: _selectedMode == ExperienceMode.child,
                      onTap: () =>
                          setState(() => _selectedMode = ExperienceMode.child),
                    ),
                    const SizedBox(height: 12),
                    _ModeCard(
                      emoji: '🎯',
                      title: 'Yetişkin',
                      description:
                          'Eğlence quizleri, Wordle ve günlük challenge’lar',
                      color: const Color(0xFF8B5CF6),
                      selected: _selectedMode == ExperienceMode.adult,
                      onTap: () =>
                          setState(() => _selectedMode = ExperienceMode.adult),
                    ),
                    const SizedBox(height: 12),
                    _ModeCard(
                      emoji: '👨‍👩‍👧',
                      title: 'Aile',
                      description:
                          'Çocuk profilleri, gelişim takibi ve ailece kullanım',
                      color: const Color(0xFF10A779),
                      selected: _selectedMode == ExperienceMode.family,
                      onTap: () =>
                          setState(() => _selectedMode = ExperienceMode.family),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _selectedMode == null || _isSaving
                          ? null
                          : _continue,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Devam Et',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bu seçimi daha sonra Ayarlar’dan değiştirebilirsin.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String description;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      selected: selected,
      button: true,
      label: '$title deneyimi',
      child: Material(
        color: selected
            ? color.withValues(alpha: 0.12)
            : theme.colorScheme.surface,
        elevation: selected ? 0 : 1,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? color : theme.colorScheme.outlineVariant,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? color : theme.colorScheme.outline,
                  size: 27,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
