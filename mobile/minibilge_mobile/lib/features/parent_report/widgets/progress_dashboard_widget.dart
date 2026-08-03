import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/progress_trend.dart';
import '../models/topic_performance.dart';
import '../models/entertainment_stats.dart';
import '../models/weak_topic.dart';
import '../providers/progress_dashboard_provider.dart';

/// P6-M03 / M04: Premium gelişim dashboard'u — 30/90 günlük trend +
/// güçlü/gelişmesi gereken konu performansı. Premium değilse teaser + ücretsiz
/// zayıf konu özeti gösterir (M05 gating).
class ProgressDashboardWidget extends ConsumerStatefulWidget {
  final String childId;
  final List<WeakTopic> weakTopics;

  const ProgressDashboardWidget({
    super.key,
    required this.childId,
    required this.weakTopics,
  });

  @override
  ConsumerState<ProgressDashboardWidget> createState() =>
      _ProgressDashboardWidgetState();
}

class _ProgressDashboardWidgetState
    extends ConsumerState<ProgressDashboardWidget> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(authProvider).maybeWhen(
          authenticated: (user) => user.isPremium,
          orElse: () => false,
        );

    if (!isPremium) {
      return _freeView();
    }

    final arg = (childId: widget.childId, days: _days);
    final trendAsync = ref.watch(progressTrendProvider(arg));
    final topicsAsync = ref.watch(topicPerformanceProvider(arg));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _rangeToggle(),
        const SizedBox(height: 14),
        trendAsync.when(
          loading: () => _loadingCard(),
          error: (_, _) => _errorCard(() {
            ref.invalidate(progressTrendProvider(arg));
          }),
          data: (trend) => _trendSection(trend),
        ),
        const SizedBox(height: 14),
        topicsAsync.when(
          loading: () => _loadingCard(),
          error: (_, _) => _errorCard(() {
            ref.invalidate(topicPerformanceProvider(arg));
          }),
          data: (topics) => _topicSection(topics),
        ),
        const SizedBox(height: 14),
        ref.watch(entertainmentStatsProvider(widget.childId)).when(
              loading: () => _loadingCard(),
              error: (_, _) => _errorCard(() {
                ref.invalidate(entertainmentStatsProvider(widget.childId));
              }),
              data: (stats) => _entertainmentSection(stats),
            ),
      ],
    );
  }

  // ── Free view (M05): teaser + ücretsiz zayıf konu özeti ──────
  Widget _freeView() {
    final free = widget.weakTopics.take(3).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _PremiumTeaser(onTap: () => context.push('/premium')),
        if (free.isNotEmpty) ...[
          const SizedBox(height: 16),
          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardTitle(Icons.trending_down_rounded, 'Zayıf Konular'),
                const SizedBox(height: 4),
                Text(
                  'Ücretsiz özet — detaylı analiz Premium ile.',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                for (final t in free) _freeWeakRow(t),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _freeWeakRow(WeakTopic t) {
    final pct = (t.successRate * 100).round();
    final color = _rateColor(t.successRate);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.topicName,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  t.subjectName,
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '%$pct',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Range toggle ─────────────────────────────────────────────
  Widget _rangeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Row(
        children: [
          _rangeButton(30, 'Son 30 Gün'),
          _rangeButton(90, 'Son 90 Gün'),
        ],
      ),
    );
  }

  Widget _rangeButton(int days, String label) {
    final selected = _days == days;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _days = days),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF7B61FF), Color(0xFFAA9FE8)])
                : null,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: selected ? Colors.white : Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ── Trend section ────────────────────────────────────────────
  Widget _trendSection(ProgressTrend trend) {
    final ratePct = (trend.correctAnswerRate * 100).round();
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.trending_up_rounded, 'Gelişim Özeti'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _metric('${trend.totalQuestionsAnswered}', 'Soru')),
              Expanded(child: _metric('%$ratePct', 'Doğruluk')),
              Expanded(child: _metric('${trend.activeDays}', 'Aktif gün')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _metric('${trend.levelsCompleted}', 'Bölüm')),
              Expanded(child: _metric('${trend.totalStarsEarned}', 'Yıldız')),
              Expanded(child: _metric('${trend.totalPointsEarned}', 'Puan')),
            ],
          ),
          if (trend.weeklyTrend.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'Haftalık Soru Sayısı',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            _weeklyBars(trend.weeklyTrend),
          ],
        ],
      ),
    );
  }

  Widget _weeklyBars(List<TrendPoint> points) {
    final maxVal = points
        .map((p) => p.totalQuestionsAnswered)
        .fold<int>(0, (a, b) => a > b ? a : b);
    return SizedBox(
      height: 140,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < points.length; i++)
              SizedBox(
                width: 46,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${points[i].totalQuestionsAnswered}',
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 22,
                      height: maxVal == 0
                          ? 4
                          : (points[i].totalQuestionsAnswered / maxVal * 80)
                              .clamp(4, 80),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFF7B61FF), Color(0xFFC4A8E2)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'H${i + 1}',
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Topic performance ────────────────────────────────────────
  Widget _topicSection(List<TopicPerformance> topics) {
    if (topics.isEmpty) {
      return _glassCard(
        child: Column(
          children: [
            const Icon(Icons.insights_rounded, size: 48, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              'Bu dönemde yeterli veri yok.',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Backend en zayıf konuyu başa koyar. Güçlü = başarısı yüksek olanlar.
    final weak = topics.where((t) => t.successRate < 0.7).take(5).toList();
    final strong = topics.where((t) => t.successRate >= 0.7).toList()
      ..sort((a, b) => b.successRate.compareTo(a.successRate));

    return Column(
      children: [
        if (weak.isNotEmpty)
          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardTitle(Icons.trending_down_rounded, 'Gelişmesi Gereken Konular'),
                const SizedBox(height: 6),
                for (final t in weak) _topicRow(t),
              ],
            ),
          ),
        if (strong.isNotEmpty) ...[
          const SizedBox(height: 14),
          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardTitle(Icons.emoji_events_rounded, 'Güçlü Konular'),
                const SizedBox(height: 6),
                for (final t in strong.take(5)) _topicRow(t),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _topicRow(TopicPerformance t) {
    final pct = (t.successRate * 100).round();
    final color = _rateColor(t.successRate);
    final avgTime = t.averageTimeSeconds;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.topicName,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      t.subjectName,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '%$pct',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: t.successRate.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _chipInfo(Icons.checklist_rounded,
                  '${t.correctAttempts}/${t.totalAttempts} doğru'),
              const SizedBox(width: 10),
              if (avgTime != null)
                _chipInfo(Icons.timer_outlined, '~${avgTime.round()} sn'),
              const SizedBox(width: 10),
              _chipInfo(Icons.event_repeat_rounded, '${t.distinctDaysPracticed} gün'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 3),
        Text(
          text,
          style: GoogleFonts.nunito(
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ── Shared UI ────────────────────────────────────────────────
  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.5),
      ),
      child: child,
    );
  }

  Widget _cardTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _metric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 22),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.nunito(
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _loadingCard() {
    return _glassCard(
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }

  Widget _errorCard(VoidCallback onRetry) {
    return _glassCard(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            'Veri yüklenemedi',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF4A3FCC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Tekrar Dene',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Entertainment (Eğlence Quizleri) ─────────────────────────
  Widget _entertainmentSection(EntertainmentStats stats) {
    if (stats.totalPlayed == 0) {
      return _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardTitle(Icons.videogame_asset_rounded, 'Eğlence Quizleri'),
            const SizedBox(height: 8),
            Text(
              'Henüz eğlence quizi oynanmadı.',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final avgRate = stats.averageSuccessRate.clamp(0, 100).round();
    final winPct = stats.totalPlayed > 0
        ? (stats.totalWon / stats.totalPlayed * 100).round()
        : 0;
    final top = stats.categories.take(5).toList();

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.videogame_asset_rounded, 'Eğlence Quizleri'),
          const SizedBox(height: 4),
          Text(
            'Tüm zamanların toplamı',
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _metric('${stats.totalPlayed}', 'Oynanan')),
              Expanded(child: _metric('%$winPct', 'Kazanma')),
              Expanded(child: _metric('%$avgRate', 'Başarı')),
            ],
          ),
          if (stats.perfectWins > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _metric('${stats.totalWon}', 'Galibiyet')),
                Expanded(child: _metric('${stats.perfectWins}', 'Kusursuz')),
                const Spacer(),
              ],
            ),
          ],
          if (top.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'Kategori Kırılımı',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            for (final c in top) _entertainmentCategoryRow(c),
          ],
        ],
      ),
    );
  }

  Widget _entertainmentCategoryRow(EntertainmentCategoryStat c) {
    final rate = (c.averageSuccessRate / 100).clamp(0.0, 1.0);
    final pct = c.averageSuccessRate.clamp(0, 100).round();
    final color = _rateColor(rate);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.categoryName,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '%$pct',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          _chipInfo(Icons.videogame_asset_rounded,
              '${c.won}/${c.played} galibiyet'),
        ],
      ),
    );
  }

  Color _rateColor(double rate) {
    if (rate >= 0.7) return const Color(0xFF10B981);
    if (rate >= 0.4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class _PremiumTeaser extends StatelessWidget {
  final VoidCallback onTap;

  const _PremiumTeaser({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium_rounded,
                size: 72, color: Color(0xFFFFB300)),
            const SizedBox(height: 16),
            Text(
              'Detaylı Gelişim Raporu',
              style: GoogleFonts.luckiestGuy(
                color: Colors.white,
                fontSize: 24,
                shadows: const [
                  Shadow(
                      blurRadius: 0,
                      color: Color(0xFF3D35CC),
                      offset: Offset(2, 2)),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '30/90 günlük trend, güçlü ve gelişmesi gereken konular Premium üyelere özeldir.',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B61FF), Color(0xFFAA9FE8)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  "Premium'a Geç",
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
