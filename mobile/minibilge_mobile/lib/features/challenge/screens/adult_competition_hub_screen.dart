import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../education/providers/subject_provider.dart';

class AdultCompetitionHubScreen extends ConsumerWidget {
  const AdultCompetitionHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectListProvider).valueOrNull;
    final english = subjects?.where((subject) {
      final name = subject.name.toLowerCase().replaceAll('i̇', 'i');
      return name.contains('ingilizce');
    }).firstOrNull;

    final modes = <_AdultMode>[
      _AdultMode('🌍', 'Genel Kültür Düellosu', 'Bilgini farklı kategorilerde sınayacağın hızlı quiz.',
          const [Color(0xFF4568DC), Color(0xFFB06AB3)],
          () => context.push('/entertainment/select')),
      _AdultMode('🎉', 'Eğlence Quiz Karşılaşması', 'Spor, müzik, sinema ve daha fazlası.',
          const [Color(0xFF11998E), Color(0xFF38EF7D)],
          () => context.push('/entertainment/select')),
      _AdultMode('🇬🇧', 'İngilizce Quiz', 'Seviyeni seç, İngilizce sorularla puanını yükselt.',
          const [Color(0xFF00B4DB), Color(0xFF0083B0)], () {
        if (english == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İngilizce içeriği şu anda yüklenemedi.')),
          );
          return;
        }
        context.push('/education/english-level/${english.id}', extra: english.name);
      }),
      _AdultMode('⏱️', 'Süreli Wordle Yarışı', 'Kelimeyi en kısa sürede bul ve puanını karşılaştır.',
          const [Color(0xFF1B4332), Color(0xFF40916C)],
          () => context.push('/wordle-levels')),
      _AdultMode('📅', 'Günlük Challenge', 'Günün oyunlarında topladığın puanı karşılaştır.',
          const [Color(0xFFF7971E), Color(0xFFFFD200)],
          () => context.push('/entertainment')),
      _AdultMode('⚡', 'Doğru / Yanlış Hızlı Yarış', 'Seri karar ver, doğru cevaplarla öne geç.',
          const [Color(0xFF6A11CB), Color(0xFF2575FC)],
          () => context.push('/entertainment/fact-fiction')),
      _AdultMode('🗂️', 'Kategori Bazlı Bilgi Yarışması', 'Favori kategorini seç ve quiz başlasın.',
          const [Color(0xFFEF629F), Color(0xFFEECDA3)],
          () => context.push('/entertainment/select')),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF251B4D), Color(0xFF3E2465), Color(0xFF18122B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('YETİŞKİN MEYDAN OKUMALARI',
                              style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 21)),
                          Text('Bir oyun seç, puanını yetişkin sıralamasında yükselt',
                              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  itemCount: modes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => _AdultModeCard(mode: modes[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdultMode {
  const _AdultMode(this.emoji, this.title, this.description, this.colors, this.onTap);
  final String emoji;
  final String title;
  final String description;
  final List<Color> colors;
  final VoidCallback onTap;
}

class _AdultModeCard extends StatelessWidget {
  const _AdultModeCard({required this.mode});
  final _AdultMode mode;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: mode.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: mode.colors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: mode.colors.first.withOpacity(.35), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(16)),
              alignment: Alignment.center,
              child: Text(mode.emoji, style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mode.title, style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                  const SizedBox(height: 3),
                  Text(mode.description, style: GoogleFonts.nunito(color: Colors.white.withOpacity(.88), fontSize: 12.5)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
