import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/podcast_models.dart';
import '../providers/podcast_provider.dart';
import '../services/podcast_progress_store.dart';
import '../../child_profile/providers/selected_child_provider.dart';

class PodcastListScreen extends ConsumerWidget {
  final String subjectId;
  final int englishLevel;  // 1=A1 … 6=C2
  final String levelCode;  // "A1", "B2" vb.

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
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Text('🎧 Podcast',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.luckiestGuy(
                                fontSize: 26,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(blurRadius: 0, color: Color(0xFF001A12), offset: Offset(2, 2)),
                                ],
                              )),
                          Text(levelCode,
                              style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white60)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: episodesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                  error: (e, _) => Center(
                    child: Text('Yüklenemedi 😔\n$e',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14)),
                  ),
                  data: (episodes) {
                    // Progress yükle (build sonrası, fire-and-forget)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final profileId =
                          ref.read(selectedChildProvider)?.id ?? 'default';
                      PodcastProgressStore.loadAll(
                          episodes.map((e) => e.id).toList(),
                          profileId: profileId);
                    });
                    if (episodes.isEmpty) {
                      return Center(
                        child: Text(
                          'Bu seviye için henüz podcast yok.\nYakında eklenecek! 🎙️',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                              color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: episodes.length,
                      itemBuilder: (ctx, i) => _EpisodeCard(
                        episode: episodes[i],
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

class _EpisodeCard extends StatelessWidget {
  final PodcastEpisodeSummary episode;
  final VoidCallback onTap;

  const _EpisodeCard({required this.episode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, double>>(
      valueListenable: PodcastProgressStore.progressNotifier,
      builder: (context, progressMap, _) {
        final progress = progressMap[episode.id] ?? 0.0;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.2),
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
                        color: const Color(0xFF26A69A).withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.headphones_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(episode.title,
                              style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(episode.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                  fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          // Konuşmacı chip'leri
                          Wrap(
                            spacing: 6,
                            children: episode.speakerNames
                                .map((name) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text('👤 $name',
                                          style: GoogleFonts.nunito(
                                              fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                        const SizedBox(height: 8),
                        Text('${episode.lineCount} satır',
                            style: GoogleFonts.nunito(fontSize: 11, color: Colors.white54)),
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
                            backgroundColor: Colors.white.withOpacity(0.12),
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
