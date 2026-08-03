import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../child_profile/providers/selected_child_provider.dart';
import '../models/daily_plan_models.dart';
import '../providers/daily_plan_provider.dart';
import 'daily_plan_progress_bar.dart';

/// Dashboard'da "Bugünkü Planım" kartı ve ilerleme göstergesi (M01).
class DailyPlanBanner extends ConsumerWidget {
  const DailyPlanBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(selectedChildProvider);
    if (child == null) return const SizedBox.shrink();

    final state = ref.watch(dailyPlanProvider(child.id));
    final plan = state.plan;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/daily-plan'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9A3D), Color(0xFFFF6B6B)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: _content(plan, state.isLoading)),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(DailyPlanDto? plan, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Bugünkü Planım',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            if (plan != null && plan.isCompleted) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
            ],
          ],
        ),
        const SizedBox(height: 6),
        if (plan == null)
          Text(
            isLoading ? 'Yükleniyor...' : 'Bugünün görevlerini keşfet',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          )
        else ...[
          DailyPlanProgressBar(
            progress: plan.progress,
            height: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 6),
          Text(
            plan.isCompleted
                ? 'Tüm görevleri tamamladın!'
                : '${plan.completedItems}/${plan.totalItems} görev tamamlandı',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ],
    );
  }
}
