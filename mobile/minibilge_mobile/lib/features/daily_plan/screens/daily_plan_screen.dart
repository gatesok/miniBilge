import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../education/providers/subject_provider.dart';
import '../models/daily_plan_models.dart';
import '../providers/daily_plan_provider.dart';
import '../widgets/daily_plan_progress_bar.dart';

/// Bugünkü Planım detay ekranı (M02): plan maddelerini listeler, aktiviteye
/// yönlendirir (M03), tamamlanınca ödül ekranına götürür (M05).
class DailyPlanScreen extends ConsumerWidget {
  const DailyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(selectedChildProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Bugünkü Planım',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: child == null
          ? const _EmptyState(message: 'Önce bir profil seçmelisin.')
          : _DailyPlanBody(childId: child.id),
    );
  }
}

class _DailyPlanBody extends ConsumerWidget {
  final String childId;

  const _DailyPlanBody({required this.childId});

  Future<void> _startActivity(
    BuildContext context,
    WidgetRef ref,
    DailyPlanItemDto item,
  ) async {
    switch (item.activityType) {
      case 'math':
        final subjects = ref.read(subjectListProvider).valueOrNull;
        final math = subjects?.firstWhere(
          (s) => s.name.toLowerCase() == 'matematik',
          orElse: () => subjects.first,
        );
        if (math != null) {
          context.push('/education/topics/${math.id}', extra: math.name);
        }
        break;
      case 'english_vocab':
        final subjects = ref.read(subjectListProvider).valueOrNull;
        final english = subjects?.firstWhere(
          (s) =>
              s.name.toLowerCase().replaceAll('i̇', 'i').contains('ingilizce'),
          orElse: () => subjects.first,
        );
        if (english != null) {
          context.push(
            '/education/english-level/${english.id}',
            extra: english.name,
          );
        }
        break;
      case 'flashcard':
        context.push('/cards');
        break;
      case 'entertainment':
        context.push('/entertainment');
        break;
    }
  }

  Future<void> _completeItem(
    BuildContext context,
    WidgetRef ref,
    DailyPlanItemDto item,
  ) async {
    final justCompleted =
        await ref.read(dailyPlanProvider(childId).notifier).completeItem(item.id);
    if (!context.mounted) return;
    if (justCompleted) {
      final plan = ref.read(dailyPlanProvider(childId)).plan;
      if (plan != null) {
        context.push('/daily-plan/reward', extra: plan);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyPlanProvider(childId));

    if (state.isLoading && state.plan == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.plan == null) {
      return _EmptyState(
        message: state.error ?? 'Günlük plan bulunamadı.',
        onRetry: () => ref.read(dailyPlanProvider(childId).notifier).load(),
      );
    }

    final plan = state.plan!;
    return RefreshIndicator(
      onRefresh: () => ref.read(dailyPlanProvider(childId).notifier).load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PlanHeaderCard(plan: plan),
          const SizedBox(height: 16),
          ...plan.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PlanItemCard(
                item: item,
                isCompleting: state.completingItemId == item.id,
                onStart: () => _startActivity(context, ref, item),
                onComplete: () => _completeItem(context, ref, item),
              ),
            ),
          ),
          if (plan.isCompleted) ...[
            const SizedBox(height: 8),
            _CompletedBanner(plan: plan),
          ],
          const SizedBox(height: 8),
          const _ReminderToggle(),
        ],
      ),
    );
  }
}

class _PlanHeaderCard extends StatelessWidget {
  final DailyPlanDto plan;

  const _PlanHeaderCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3D35CC)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Günün Görevleri',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${plan.completedItems} / ${plan.totalItems} tamamlandı',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          DailyPlanProgressBar(
            progress: plan.progress,
            height: 12,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.star, size: 20),
              const SizedBox(width: 4),
              Text(
                '${plan.rewardStars} yıldız',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.bolt_rounded,
                  color: AppColors.diamond, size: 20),
              const SizedBox(width: 4),
              Text(
                '${plan.rewardPoints} puan',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanItemCard extends StatelessWidget {
  final DailyPlanItemDto item;
  final bool isCompleting;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  const _PlanItemCard({
    required this.item,
    required this.isCompleting,
    required this.onStart,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final done = item.isCompleted;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: done ? AppColors.success.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.dividerLight,
        ),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _activityColor(item.activityType).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _activityIcon(item.activityType),
              color: _activityColor(item.activityType),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  done ? 'Tamamlandı' : 'Hedef: ${item.targetCount}',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: done
                        ? AppColors.success
                        : AppColors.textSecondaryLight,
                  ),
                ),
                if (!done && (item.note?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 14,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.note!,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _trailing(),
        ],
      ),
    );
  }

  Widget _trailing() {
    if (item.isCompleted) {
      return const Icon(
        Icons.check_circle_rounded,
        color: AppColors.success,
        size: 30,
      );
    }
    if (isCompleting) {
      return const SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 32,
          child: TextButton(
            onPressed: onStart,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              foregroundColor: AppColors.primaryLight,
            ),
            child: Text(
              'Başla',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        SizedBox(
          height: 26,
          child: TextButton(
            onPressed: onComplete,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              foregroundColor: AppColors.success,
            ),
            child: Text(
              'Tamamladım',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static IconData _activityIcon(String type) {
    switch (type) {
      case 'math':
        return Icons.calculate_rounded;
      case 'english_vocab':
        return Icons.translate_rounded;
      case 'flashcard':
        return Icons.style_rounded;
      case 'entertainment':
        return Icons.videogame_asset_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  static Color _activityColor(String type) {
    switch (type) {
      case 'math':
        return const Color(0xFF29B6F6);
      case 'english_vocab':
        return const Color(0xFF26A69A);
      case 'flashcard':
        return const Color(0xFF7B61FF);
      case 'entertainment':
        return const Color(0xFF2ECC71);
      default:
        return AppColors.primaryLight;
    }
  }
}

class _CompletedBanner extends StatelessWidget {
  final DailyPlanDto plan;

  const _CompletedBanner({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: AppColors.coin, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bugünkü planını tamamladın! Yarın yeni görevlerle görüşmek üzere.',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderToggle extends ConsumerWidget {
  const _ReminderToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(dailyPlanReminderProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: SwitchListTile(
        value: enabled,
        activeThumbColor: AppColors.primaryLight,
        onChanged: (v) =>
            ref.read(dailyPlanReminderProvider.notifier).toggle(v),
        title: Text(
          'Günlük hatırlatma',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          'Her gün planını hatırlatan bildirim gönder',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryLight,
          ),
        ),
        secondary: const Icon(
          Icons.notifications_active_rounded,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _EmptyState({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_note_rounded,
                size: 64, color: AppColors.textDisabledLight),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
