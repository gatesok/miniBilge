import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/podcast_models.dart';
import '../providers/podcast_provider.dart';
import '../../flashcard/providers/flashcard_provider.dart';

class PodcastPlayerScreen extends ConsumerStatefulWidget {
  final String episodeId;
  final String? episodeTitle;

  const PodcastPlayerScreen({
    super.key,
    required this.episodeId,
    this.episodeTitle,
  });

  @override
  ConsumerState<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends ConsumerState<PodcastPlayerScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showFlashcardBanner = false;

  @override
  void initState() {
    super.initState();
    // Episode yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(podcastPlayerProvider.notifier).loadEpisode(widget.episodeId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Aktif satırı görünür hale getir
  void _scrollToCurrentLine(int index) {
    final itemHeight = 96.0;
    final offset = (index * itemHeight) - 120;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(podcastPlayerProvider);
    final notifier = ref.read(podcastPlayerProvider.notifier);

    // Episode tamamlanınca banner tetikle
    ref.listen<PodcastPlayerState>(podcastPlayerProvider, (prev, next) {
      if (prev?.currentLineIndex != next.currentLineIndex) {
        _scrollToCurrentLine(next.currentLineIndex);
      }
      if (!(prev?.isCompleted ?? false) && next.isCompleted) {
        setState(() => _showFlashcardBanner = true);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, state),

            // Diyalog listesi
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)))
                  : state.error != null
                      ? _buildError(state.error!)
                      : state.episode != null
                          ? _buildDialogList(state, notifier)
                          : const SizedBox.shrink(),
            ),

            // Flashcard tamamlanma bannerı
            if (_showFlashcardBanner)
              _FlashcardCompletionBanner(
                episodeId: widget.episodeId,
                onDismiss: () => setState(() => _showFlashcardBanner = false),
              ),

            // Player kontrolleri
            if (state.episode != null) _buildControls(state, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PodcastPlayerState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2D3E),
        border: Border(bottom: BorderSide(color: Color(0xFF26A69A), width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await ref.read(podcastPlayerProvider.notifier).pause();
              if (context.mounted) context.pop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.episode?.title ?? widget.episodeTitle ?? 'Podcast',
                  style: GoogleFonts.nunito(
                      fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (state.episode != null)
                  Text(
                    _levelLabel(state.episode!.englishLevel),
                    style: GoogleFonts.nunito(fontSize: 12, color: const Color(0xFF26A69A)),
                  ),
              ],
            ),
          ),
          // Çeviri toggle
          GestureDetector(
            onTap: () => ref.read(podcastPlayerProvider.notifier).toggleTranslation(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: state.showTranslation
                    ? const Color(0xFF26A69A)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF26A69A), width: 1),
              ),
              child: Text(
                'TR',
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: state.showTranslation ? Colors.white : const Color(0xFF26A69A)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogList(PodcastPlayerState state, PodcastPlayerNotifier notifier) {
    final lines = state.episode!.lines;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: lines.length,
      itemBuilder: (ctx, i) {
        final line = lines[i];
        final isActive = i == state.currentLineIndex;
        return _DialogLineTile(
          line: line,
          isActive: isActive,
          showTranslation: state.showTranslation,
          wordStart: isActive ? state.wordStart : -1,
          wordEnd: isActive ? state.wordEnd : -1,
          onTap: () async {
            await notifier.seekTo(i);
            await notifier.play();
          },
        );
      },
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Text(
        'Yüklenemedi 😔\n$error',
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(color: Colors.white54, fontSize: 14),
      ),
    );
  }

  Widget _buildControls(PodcastPlayerState state, PodcastPlayerNotifier notifier) {
    final episode = state.episode!;
    final progress = episode.lines.isEmpty
        ? 0.0
        : (state.currentLineIndex + 1) / episode.lines.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2D3E),
        border: Border(top: BorderSide(color: Color(0xFF26A69A), width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Row(
            children: [
              Text('${state.currentLineIndex + 1}',
                  style: GoogleFonts.nunito(color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF26A69A)),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${episode.lines.length}',
                  style: GoogleFonts.nunito(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),

          // Oynatma kontrolleri
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Önceki satır
              _ControlButton(
                icon: Icons.skip_previous_rounded,
                size: 34,
                onTap: () => notifier.previousLine(),
              ),
              const SizedBox(width: 24),
              // Oynat/Duraklat
              GestureDetector(
                onTap: () {
                  if (state.isPlaying) {
                    notifier.pause();
                  } else {
                    notifier.play();
                  }
                },
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF26A69A), Color(0xFF00695C)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF26A69A).withOpacity(0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Icon(
                    state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Sonraki satır
              _ControlButton(
                icon: Icons.skip_next_rounded,
                size: 34,
                onTap: () => notifier.nextLine(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Hız seçici
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [0.8, 1.0, 1.2].map((rate) {
              final selected = state.playbackRate == rate;
              return GestureDetector(
                onTap: () => notifier.setPlaybackRate(rate),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF26A69A) : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected ? const Color(0xFF26A69A) : Colors.white24, width: 1),
                  ),
                  child: Text(
                    '${rate}x',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : Colors.white54),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _levelLabel(int level) {
    const labels = {1: 'A1', 2: 'A2', 3: 'B1', 4: 'B2', 5: 'C1', 6: 'C2'};
    return labels[level] ?? 'İngilizce';
  }
}

// ─── Diyalog satırı widget'ı ────────────────────────────────────────────────

class _DialogLineTile extends StatelessWidget {
  final PodcastLine line;
  final bool isActive;
  final bool showTranslation;
  final int wordStart; // -1 = highlight yok
  final int wordEnd;
  final VoidCallback onTap;

  const _DialogLineTile({
    required this.line,
    required this.isActive,
    required this.showTranslation,
    required this.wordStart,
    required this.wordEnd,
    required this.onTap,
  });

  /// Karaoke RichText: aktif kelimeyi highlight et.
  Widget _buildKaraokeText(String text, Color highlightColor, TextStyle baseStyle) {
    final start = wordStart;
    final end = wordEnd;

    // Highlight geçerli değilse düz text döndür
    if (start < 0 || end <= start || end > text.length) {
      return Text(text, style: baseStyle);
    }

    return RichText(
      text: TextSpan(
        children: [
          if (start > 0)
            TextSpan(text: text.substring(0, start), style: baseStyle),
          TextSpan(
            text: text.substring(start, end),
            style: baseStyle.copyWith(
              color: highlightColor,
              fontWeight: FontWeight.w900,
              backgroundColor: highlightColor.withOpacity(0.22),
            ),
          ),
          if (end < text.length)
            TextSpan(text: text.substring(end), style: baseStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFemale = line.speakerGender == 1;
    final speakerColor = isFemale ? const Color(0xFF26A69A) : const Color(0xFF29B6F6);
    final speakerEmoji = isFemale ? '👩' : '👨';

    final baseTextStyle = GoogleFonts.nunito(
      fontSize: isActive ? 14.5 : 13.5,
      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
      color: isActive ? Colors.white : Colors.white70,
      height: 1.5,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? speakerColor.withOpacity(0.18)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? speakerColor : Colors.white.withOpacity(0.08),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Column(
              children: [
                Text(speakerEmoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  line.speakerName,
                  style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: speakerColor),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İngilizce metin — aktif satırda karaoke highlight
                  isActive
                      ? _buildKaraokeText(line.text, speakerColor, baseTextStyle)
                      : Text(line.text, style: baseTextStyle),
                  // Türkçe çeviri (toggle ile)
                  if (showTranslation && line.translationTr != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Text(
                        line.translationTr!,
                        style: GoogleFonts.nunito(
                          fontSize: 12.5,
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Aktif gösterge
            if (isActive)
              Container(
                margin: const EdgeInsets.only(left: 6, top: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: speakerColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: speakerColor, blurRadius: 6)],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Küçük kontrol butonu ───────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size + 16,
        height: size + 16,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: size),
      ),
    );
  }
}

// ─── Flashcard tamamlanma banner'ı ──────────────────────────────────────────

class _FlashcardCompletionBanner extends ConsumerWidget {
  final String episodeId;
  final VoidCallback onDismiss;

  const _FlashcardCompletionBanner({
    required this.episodeId,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckAsync = ref.watch(flashcardDeckByEpisodeProvider(episodeId));

    // Deck yoksa (bu episode için kart oluşturulmamış) banner'ı gösterme
    return deckAsync.when(
      data: (deck) {
        if (deck == null) return const SizedBox.shrink();
        return _buildBanner(context, deck);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(BuildContext context, dynamic deck) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Text('📚', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bölüm tamamlandı!',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    'Şimdi kelime kartlarını çalış',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push(
                '/flashcard/study/${deck.id}',
                extra: deck.title,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Başla',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A148C),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close_rounded, color: Colors.white54, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
