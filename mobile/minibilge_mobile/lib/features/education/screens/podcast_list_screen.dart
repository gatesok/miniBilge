import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/podcast_models.dart';
import '../providers/podcast_provider.dart';
import '../services/podcast_progress_store.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/podcast_offline_store.dart';

class PodcastListScreen extends ConsumerWidget {
  final String subjectId;
  final int englishLevel; // 1=A1 … 6=C2
  final String levelCode; // "A1", "B2" vb.

  const PodcastListScreen({
    super.key,
    required this.subjectId,
    required this.englishLevel,
    required this.levelCode,
  });

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.55, 1.0],
    colors: [Color(0xFF26A69A), Color(0xFF004D40), Color(0xFF00251A)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync = ref.watch(podcastListProvider(englishLevel));
    final isPremium = ref
        .watch(authProvider)
        .maybeWhen(
          authenticated: (user) => user.isPremium,
          orElse: () => false,
        );

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.headphones_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Podcast',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.luckiestGuy(
                                  fontSize: 26,
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 0,
                                      color: Color(0xFF001A12),
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            levelCode,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _PodcastAccessBanner(isPremium: isPremium),
              const SizedBox(height: 14),
              Expanded(
                child: episodesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Yüklenemedi\n$e',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  data: (episodes) {
                    // Progress yükle (build sonrası, fire-and-forget)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final profileId =
                          ref.read(selectedChildProvider)?.id ?? 'default';
                      PodcastProgressStore.loadAll(
                        episodes.map((e) => e.id).toList(),
                        profileId: profileId,
                      );
                    });
                    if (episodes.isEmpty) {
                      return Center(
                        child: Text(
                          'Bu seviye için henüz podcast yok.\nYakında eklenecek!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: episodes.length,
                      itemBuilder: (ctx, i) => _EpisodeCard(
                        episode: episodes[i],
                        isPremium: isPremium,
                        onTap: () => context.push(
                          '/education/podcast/${episodes[i].id}',
                          extra: episodes[i].title,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodcastAccessBanner extends StatelessWidget {
  const _PodcastAccessBanner({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPremium ? null : () => context.push('/premium'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isPremium
              ? const Color(0xFFFFB300).withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPremium
                ? const Color(0xFFFFD54F).withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.lock_clock_rounded,
              color: isPremium ? const Color(0xFFFFD54F) : Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isPremium
                    ? 'Premium: Bölümleri tam ve sınırsız dinleyebilir, indirebilirsin.'
                    : 'Ücretsiz önizleme: Her bölümün ilk 20 saniyesini dinleyebilirsin.',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (!isPremium)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeCard extends ConsumerStatefulWidget {
  final PodcastEpisodeSummary episode;
  final VoidCallback onTap;
  final bool isPremium;

  const _EpisodeCard({
    required this.episode,
    required this.onTap,
    required this.isPremium,
  });

  @override
  ConsumerState<_EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends ConsumerState<_EpisodeCard> {
  bool _downloaded = false;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    PodcastOfflineStore.isDownloaded(widget.episode.id).then((value) {
      if (mounted) setState(() => _downloaded = value);
    });
  }

  Future<void> _toggleDownload() async {
    if (!widget.isPremium) {
      context.push('/premium');
      return;
    }
    setState(() => _downloading = true);
    try {
      if (_downloaded) {
        await PodcastOfflineStore.removeEpisode(widget.episode.id);
      } else {
        await ref
            .read(podcastServiceProvider)
            .downloadEpisode(widget.episode.id);
      }
      if (mounted) setState(() => _downloaded = !_downloaded);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Podcast indirilemedi. Bağlantını kontrol et.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '—';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '$s sn';
    if (s == 0) return '$m dk';
    return '$m dk $s sn';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, double>>(
      valueListenable: PodcastProgressStore.progressNotifier,
      builder: (context, progressMap, _) {
        final episode = widget.episode;
        final progress = progressMap[episode.id] ?? 0.0;
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Mikrofon ikonu
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF26A69A).withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.headphones_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episode.title,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            episode.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Colors.white60,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Konuşmacı chip'leri
                          Wrap(
                            spacing: 6,
                            children: episode.speakerNames
                                .map(
                                  (name) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '👤 $name',
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isPremium
                                  ? const Color(
                                      0xFFFFB300,
                                    ).withValues(alpha: 0.25)
                                  : Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.isPremium
                                  ? '👑 Tam erişim'
                                  : '🔒 20 sn önizleme',
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _downloading ? null : _toggleDownload,
                          child: _downloading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _downloaded
                                      ? Icons.download_done_rounded
                                      : widget.isPremium
                                      ? Icons.download_rounded
                                      : Icons.lock_rounded,
                                  color: _downloaded
                                      ? const Color(0xFF66BB6A)
                                      : Colors.white70,
                                  size: 21,
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDuration(episode.estimatedDurationSeconds),
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // İlerleme çubuğu — dinleme başlayınca görünür
                if (progress > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.12,
                            ),
                            valueColor: AlwaysStoppedAnimation(
                              progress >= 1.0
                                  ? const Color(0xFF66BB6A)
                                  : const Color(0xFF26A69A),
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        progress >= 1.0 ? '✓' : '${(progress * 100).round()}%',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: progress >= 1.0
                              ? const Color(0xFF66BB6A)
                              : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
