import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/tournament_models.dart';
import '../providers/tournament_provider.dart';

/// P7-M05: Yetişkin haftalık eğlence turnuvası ekranı (V1 — yalnızca sıralama).
class TournamentScreen extends ConsumerWidget {
  const TournamentScreen({super.key});

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D4F4F), Color(0xFF0A3D3D), Color(0xFF062E2E)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(authProvider).maybeWhen(
          authenticated: (user) => user.isPremium,
          orElse: () => false,
        );

    if (!isPremium) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _gradient),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                Expanded(child: _premiumTeaser(context)),
              ],
            ),
          ),
        ),
      );
    }

    final categoriesAsync = ref.watch(tournamentCategoriesProvider);
    final selectedCategory = ref.watch(selectedTournamentCategoryProvider);
    final weeklyAsync = ref.watch(tournamentWeeklyProvider(selectedCategory));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              _categoryChips(ref, categoriesAsync, selectedCategory),
              const SizedBox(height: 8),
              Expanded(
                child: weeklyAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (_, __) => _message(
                    'Sıralama yüklenemedi. Daha sonra tekrar dene.',
                  ),
                  data: (week) => RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(tournamentWeeklyProvider(selectedCategory));
                    },
                    child: _leaderboard(context, week),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    '🏆 Haftalık Turnuva',
                    style: GoogleFonts.luckiestGuy(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    'Bu haftanın eğlence sıralaması',
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _premiumTeaser(BuildContext context) {
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
              'Haftalık Turnuva',
              style: GoogleFonts.luckiestGuy(
                color: Colors.white,
                fontSize: 24,
                shadows: const [
                  Shadow(
                    blurRadius: 0,
                    color: Color(0xFF062E2E),
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Eğlence quizlerinden topladığın puanlarla haftalık kategori sıralamasına katılmak Premium üyelere özeldir.',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.push('/premium'),
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

  Widget _categoryChips(
    WidgetRef ref,
    AsyncValue<List<TournamentCategory>> categoriesAsync,
    String selected,
  ) {    final categories = categoriesAsync.valueOrNull ?? const <TournamentCategory>[];
    if (categories.isEmpty) return const SizedBox(height: 8);

    const spacing = 8.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Her satırda tam 3 kategori (2 satır x 3).
          final chipWidth = (constraints.maxWidth - spacing * 2) / 3;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: categories.map((cat) {
              final isSelected = cat.key == selected;
              return GestureDetector(
                onTap: () => ref
                    .read(selectedTournamentCategoryProvider.notifier)
                    .state = cat.key,
                child: Container(
                  width: chipWidth,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    '${cat.emoji} ${cat.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      color: isSelected ? const Color(0xFF0A3D3D) : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _leaderboard(BuildContext context, TournamentWeek week) {
    if (week.entries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          _message(
            'Bu hafta ${week.categoryLabel} kategorisinde henüz kimse yarışmadı.\nEğlence quizi oyna, sıralamaya sen başla!',
          ),
        ],
      );
    }

    return Column(
      children: [
        if (week.me != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: _entryTile(week.me!, highlight: true),
          ),
          const Divider(color: Colors.white24, height: 20),
        ],
        Expanded(
          child: Builder(
            builder: (context) {
              // Sayfa yapısı + performans için en fazla ilk 10 gösterilir.
              final top = week.entries.take(10).toList();
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                itemCount: top.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _entryTile(top[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _entryTile(TournamentLeaderboardEntry e, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: highlight
            ? Border.all(color: Colors.amberAccent, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '${e.rank}',
              textAlign: TextAlign.center,
              style: GoogleFonts.luckiestGuy(
                color: _rankColor(e.rank),
                fontSize: 18,
              ),
            ),
          ),
          _avatar(e, 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight ? '${e.childName} (Sen)' : e.childName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${e.wins} galibiyet · ${e.gamesPlayed} oyun',
                  style: GoogleFonts.nunito(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${e.points}',
                style: GoogleFonts.luckiestGuy(
                  color: const Color(0xFF38EF7D),
                  fontSize: 18,
                ),
              ),
              Text(
                'puan',
                style: GoogleFonts.nunito(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar(TournamentLeaderboardEntry e, double size) {
    Widget fallback() => Container(
          color: const Color(0xFF11998E),
          alignment: Alignment.center,
          child: Text(
            e.childName.isNotEmpty ? e.childName.characters.first.toUpperCase() : '?',
            style: GoogleFonts.luckiestGuy(
              color: Colors.white,
              fontSize: size * 0.42,
            ),
          ),
        );

    final avatar = e.avatarImageUrl?.trim();
    Widget content = fallback();
    if (avatar != null && avatar.isNotEmpty) {
      if (avatar.startsWith('http')) {
        content = CachedNetworkImage(
          imageUrl: avatar,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => fallback(),
        );
      } else {
        final assetPath = avatar.startsWith('assets/')
            ? avatar
            : 'assets/avatar/characters/$avatar.png';
        content = Container(
          color: const Color(0xFFE8E5FF),
          padding: EdgeInsets.all(size * 0.07),
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            errorBuilder: (_, __, ___) => fallback(),
          ),
        );
      }
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(child: content),
    );
  }

  Color _rankColor(int rank) => switch (rank) {
        1 => const Color(0xFFFFD700),
        2 => const Color(0xFFC0C0C0),
        3 => const Color(0xFFCD7F32),
        _ => Colors.white,
      };

  Widget _message(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      );
}
