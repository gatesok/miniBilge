import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/activity_summary.dart';
import '../providers/activity_provider.dart';

class ActivitySummaryWidget extends ConsumerWidget {
  final String childId;

  const ActivitySummaryWidget({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(activitySummaryProvider(childId));

    return asyncValue.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white)),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.white70),
              const SizedBox(height: 12),
              Text('Etkinlik verisi yüklenemedi',
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => ref.invalidate(activitySummaryProvider(childId)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A3FCC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Tekrar Dene',
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (summary) => _ActivityContent(summary: summary),
    );
  }
}

class _ActivityContent extends StatelessWidget {
  final ActivitySummary summary;

  const _ActivityContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    final winRate = summary.challengesTotal > 0
        ? (summary.challengesWon / summary.challengesTotal * 100).round()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Podcast ───────────────────────────────────────────────────────
          _SectionTitle(title: '🎧 Podcast'),
          const SizedBox(height: 8),
          _StatCard(
            icon: '🎧',
            label: 'Tamamlanan Podcast Quiz',
            value: summary.podcastsCompleted.toString(),
            subtitle: 'toplam quiz tamamlandı',
            color: const Color(0xFF26C6DA),
          ),
          const SizedBox(height: 20),

          // ── Meydan Okuma ─────────────────────────────────────────────────
          _SectionTitle(title: '⚔️ Meydan Okuma'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SmallStatCard(
                  icon: '🎮',
                  label: 'Toplam',
                  value: summary.challengesTotal.toString(),
                  color: const Color(0xFF7B6FCD),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallStatCard(
                  icon: '🏆',
                  label: 'Kazanılan',
                  value: summary.challengesWon.toString(),
                  color: const Color(0xFF66BB6A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallStatCard(
                  icon: '😔',
                  label: 'Kaybedilen',
                  value: summary.challengesLost.toString(),
                  color: const Color(0xFFEF5350),
                ),
              ),
            ],
          ),
          if (summary.challengesTotal > 0) ...[
            const SizedBox(height: 12),
            _WinRateCard(winRate: winRate, won: summary.challengesWon, total: summary.challengesTotal),
          ],
          const SizedBox(height: 20),

          // ── Ödevler ──────────────────────────────────────────────────────
          _SectionTitle(title: '📚 Ödevler'),
          const SizedBox(height: 8),
          _StatCard(
            icon: '📚',
            label: 'Tamamlanan Ödev',
            value: summary.assignmentsCompleted.toString(),
            subtitle: 'toplam ödev tamamlandı',
            color: const Color(0xFFFF8A65),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w800),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.40), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.nunito(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.luckiestGuy(
                        color: Colors.white,
                        fontSize: 32,
                        shadows: const [
                          Shadow(
                              blurRadius: 0,
                              color: Color(0xFF3D35CC),
                              offset: Offset(1, 1))
                        ])),
                Text(subtitle,
                    style: GoogleFonts.nunito(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _SmallStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withOpacity(0.40), width: 1.5),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.luckiestGuy(
                  color: Colors.white,
                  fontSize: 24,
                  shadows: const [
                    Shadow(
                        blurRadius: 0,
                        color: Color(0xFF3D35CC),
                        offset: Offset(1, 1))
                  ])),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _WinRateCard extends StatelessWidget {
  final int winRate;
  final int won;
  final int total;

  const _WinRateCard({
    required this.winRate,
    required this.won,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withOpacity(0.40), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🏅 Kazanma Oranı',
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: winRate >= 50
                      ? const Color(0xFF66BB6A).withOpacity(0.30)
                      : const Color(0xFFEF5350).withOpacity(0.30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$winRate%',
                    style: GoogleFonts.luckiestGuy(
                        color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: winRate / 100,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.18),
              valueColor: AlwaysStoppedAnimation<Color>(winRate >= 50
                  ? const Color(0xFF66BB6A)
                  : const Color(0xFFEF5350)),
            ),
          ),
        ],
      ),
    );
  }
}
