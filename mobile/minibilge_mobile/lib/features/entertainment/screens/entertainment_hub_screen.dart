import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/entertainment_provider.dart';

// ── Genişletilebilir oyun modu konfigürasyonu ─────────────────────────────────

class _GameModeConfig {
  final String emoji;
  final String title;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final String route;

  const _GameModeConfig({
    required this.emoji,
    required this.title,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.route,
  });
}

const _gameModes = <_GameModeConfig>[
  _GameModeConfig(
    emoji: '🎯',
    title: 'Eğlence Quiz',
    description:
        'Spor, müzik, sinema ve daha fazlası. Konu seç, yarış başlasın!',
    primaryColor: Color(0xFF11998E),
    secondaryColor: Color(0xFF38EF7D),
    route: '/entertainment/select',
  ),
  _GameModeConfig(
    emoji: '🧠',
    title: 'Gerçek mi Uydurma mı?',
    description:
        'İnanılmaz bilgiler mi, yoksa akıllıca kurgulanmış yalanlar mı? Sen karar ver!',
    primaryColor: Color(0xFF6A11CB),
    secondaryColor: Color(0xFF2575FC),
    route: '/entertainment/fact-fiction',
  ),
  _GameModeConfig(
    emoji: '🕵️',
    title: 'Kim Bu?',
    description:
        '5 ipucu, 1 sır. İpuçları açıldıkça tahmin et — ne kadar erken bilirsen o kadar yüksek puan!',
    primaryColor: Color(0xFF1A3A5C),
    secondaryColor: Color(0xFF1A6CA8),
    route: '/entertainment/kim-bu',
  ),
  _GameModeConfig(
    emoji: '🔗',
    title: 'Ne Ortak?',
    description:
        '4 görünüşte alakasız ipucu, 1 gizli bağlantı. Hepsinin ortak noktasını bul!',
    primaryColor: Color(0xFF1B4332),
    secondaryColor: Color(0xFF2D6A4F),
    route: '/entertainment/ne-ortak',
  ),
  _GameModeConfig(
    emoji: '🏆',
    title: 'Haftalık Turnuva',
    description:
        'Eğlence quizlerinden topladığın puanlarla bu haftanın kategori sıralamasında yerini al!',
    primaryColor: Color(0xFFB8860B),
    secondaryColor: Color(0xFFFFD700),
    route: '/tournament',
  ),
  // İleride yeni modlar buraya eklenir
];

// ── Hub Ekranı ────────────────────────────────────────────────────────────────

class EntertainmentHubScreen extends ConsumerWidget {
  const EntertainmentHubScreen({super.key});

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D4F4F), Color(0xFF0A3D3D), Color(0xFF062E2E)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remainingAsync = ref.watch(entertainmentRemainingProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/dashboard');
                        }
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🎭 Eğlence',
                            style: GoogleFonts.luckiestGuy(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            'Bir mod seç ve oynamaya başla',
                            style: GoogleFonts.nunito(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Ortak hak badge'i
                    remainingAsync.when(
                      data: (r) => _AttemptsBadge(remaining: r),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Oyun Modu Kartları ───────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: _gameModes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) =>
                      _GameModeCard(config: _gameModes[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hak Badge ────────────────────────────────────────────────────────────────

class _AttemptsBadge extends StatelessWidget {
  final int remaining;
  const _AttemptsBadge({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final color = remaining > 0
        ? const Color(0xFF43A047)
        : const Color(0xFFE53935);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.8), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFFFD55A), size: 19),
          const SizedBox(width: 5),
          Text(
            '$remaining',
            style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 19),
          ),
          const SizedBox(width: 4),
          Text(
            'quiz',
            style: GoogleFonts.nunito(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Oyun Modu Kartı ───────────────────────────────────────────────────────────

class _GameModeCard extends StatelessWidget {
  final _GameModeConfig config;
  const _GameModeCard({required this.config});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(config.route),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              config.primaryColor.withValues(alpha: 0.85),
              config.secondaryColor.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: config.primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            // Emoji ikon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(config.emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),
            // Metin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.title,
                    style: GoogleFonts.luckiestGuy(
                      color: Colors.white,
                      fontSize: 17,
                      shadows: const [
                        Shadow(
                          blurRadius: 0,
                          color: Colors.black26,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    config.description,
                    style: GoogleFonts.nunito(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white54,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
