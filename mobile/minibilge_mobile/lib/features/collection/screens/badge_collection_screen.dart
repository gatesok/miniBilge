import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../models/badge_dto.dart';
import '../providers/collection_provider.dart';

class BadgeCollectionScreen extends ConsumerWidget {
  const BadgeCollectionScreen({super.key});

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(selectedChildProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: child == null ? _empty() : _Body(childId: child.id),
        ),
      ),
    );
  }

  Widget _empty() => Center(
    child: Text(
      'Profil seçilmedi',
      style: GoogleFonts.nunito(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _Body extends ConsumerStatefulWidget {
  final String childId;
  const _Body({required this.childId});

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(badgeCollectionProvider(widget.childId));

    return Column(
      children: [
        _Header(onBack: () => Navigator.of(context).pop()),
        Expanded(
          child: async.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (e, _) => Center(
              child: Text(
                'Hata: $e',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            data: (collection) => _Content(
              collection: collection,
              selectedCategory: _selectedCategory,
              onCategoryChanged: (c) => setState(() => _selectedCategory = c),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.28),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
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
          Text(
            'Rozetlerim 🏅',
            style: GoogleFonts.luckiestGuy(
              fontSize: 22,
              color: Colors.white,
              shadows: const [
                Shadow(
                  blurRadius: 0,
                  color: Color(0xFF3D35CC),
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final BadgeCollectionDto collection;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  static const _categories = [
    ('all', 'Tümü'),
    ('learning', 'Öğrenme'),
    ('speed', 'Hız'),
    ('streak', 'Seri'),
    ('challenge', 'Meydan Okuma'),
    ('live_match', 'Canlı Yarış'),
    ('fun', 'Eğlence'),
    ('special', 'Özel'),
  ];

  const _Content({
    required this.collection,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  static bool _matchesCategory(BadgeDto b, String cat) {
    if (cat == 'all') return true;
    // "Canlı Yarış" hem eski match hem yeni live_match rozetlerini kapsar.
    if (cat == 'live_match') {
      return b.category == 'live_match' || b.category == 'match';
    }
    return b.category == cat;
  }

  @override
  Widget build(BuildContext context) {
    // Profil için uygun olmayan rozetleri gizle.
    final applicable =
        collection.badges.where((b) => b.isApplicableToProfile).toList();
    final filtered = applicable
        .where((b) => _matchesCategory(b, selectedCategory))
        .toList();

    return Column(
      children: [
        // Progress header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _ProgressCard(
            earned: collection.earnedCount,
            total: collection.totalBadges,
          ),
        ),
        // Filtrelerin tümü doğrudan görünür. Uzun başlıklar küçük ekranlarda
        // yeni satıra geçer; yatayda kesilmez veya kaydırma gerektirmez.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _categories.map((category) {
              final (key, label) = category;
              final isSelected = key == selectedCategory;
              return GestureDetector(
                onTap: () => onCategoryChanged(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.nunito(
                      color: isSelected
                          ? const Color(0xFF5C4ECC)
                          : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _BadgeTile(badge: filtered[i]),
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int earned;
  final int total;
  const _ProgressCard({required this.earned, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? earned / total : 0.0;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF5C4ECC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toplam Rozet',
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$earned / $total',
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 22,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE8E8F0),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF5C4ECC),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${(pct * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.luckiestGuy(
                fontSize: 28,
                color: const Color(0xFF5C4ECC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final BadgeDto badge;
  const _BadgeTile({required this.badge});

  Color _rarityColor() {
    switch (badge.rarity) {
      case 'silver':
        return const Color(0xFF78909C);
      case 'gold':
        return const Color(0xFFFFB300);
      case 'legendary':
        return const Color(0xFF7B61FF);
      default:
        return const Color(0xFF8D6E63); // bronze
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor();
    final isEarned = badge.isEarned;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: isEarned ? Colors.white : Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(16),
          border: isEarned
              ? Border.all(color: color.withOpacity(0.4), width: 2)
              : null,
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge artwork / lock
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: isEarned ? 1 : 0.28,
                  child: ColorFiltered(
                    colorFilter: isEarned
                        ? const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.dst,
                          )
                        : const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/badges/${badge.key}.png',
                        width: isEarned ? 58 : 52,
                        height: isEarned ? 58 : 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Text(
                          badge.emoji,
                          style: TextStyle(fontSize: isEarned ? 36 : 30),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isEarned)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xCC5C4ECC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // Rozet adı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                badge.name,
                style: GoogleFonts.nunito(
                  color: isEarned ? const Color(0xFF1A1A2E) : Colors.white54,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Kilitli + ilerleme varsa sayısal ilerleme; yoksa nadirlik pill
            if (!isEarned && badge.progress != null)
              _MiniProgress(progress: badge.progress!)
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isEarned
                      ? color.withOpacity(0.12)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _rarityLabel(),
                  style: GoogleFonts.nunito(
                    color: isEarned ? color : Colors.white38,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _rarityLabel() {
    switch (badge.rarity) {
      case 'silver':
        return '🥈 Gümüş';
      case 'gold':
        return '🥇 Altın';
      case 'legendary':
        return '💎 Efsane';
      default:
        return '🥉 Bronz';
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BadgeDetailSheet(badge: badge),
    );
  }
}

/// Kilitli rozet ilerlemesini kısa metne çevirir: "3/5" ya da yüzde ise "%80".
String badgeProgressLabel(BadgeProgressDto p) =>
    p.unit == 'percent' ? '%${p.current}' : '${p.current}/${p.target}';

class _MiniProgress extends StatelessWidget {
  final BadgeProgressDto progress;
  const _MiniProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.ratio,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.22),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD54F)),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            badgeProgressLabel(progress),
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeDetailSheet extends StatelessWidget {
  final BadgeDto badge;
  const _BadgeDetailSheet({required this.badge});

  @override
  Widget build(BuildContext context) {
    final isEarned = badge.isEarned;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Opacity(
            opacity: isEarned ? 1 : 0.38,
            child: ClipOval(
              child: Image.asset(
                'assets/badges/${badge.key}.png',
                width: 132,
                height: 132,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Text(badge.emoji, style: const TextStyle(fontSize: 60)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge.name,
            style: GoogleFonts.luckiestGuy(
              fontSize: 22,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: const Color(0xFF616161),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (isEarned && badge.earnedAt != null)
            Text(
              '✅ Kazanıldı: ${badge.earnedAt!.day}.${badge.earnedAt!.month}.${badge.earnedAt!.year}',
              style: GoogleFonts.nunito(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            )
          else if (badge.progress != null) ...[
            _DetailProgress(progress: badge.progress!),
          ] else
            Text(
              'Henüz kazanılmadı',
              style: GoogleFonts.nunito(
                color: const Color(0xFF9E9E9E),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DetailProgress extends StatelessWidget {
  final BadgeProgressDto progress;
  const _DetailProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'İlerleme',
              style: GoogleFonts.nunito(
                color: const Color(0xFF616161),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Text(
              badgeProgressLabel(progress),
              style: GoogleFonts.nunito(
                color: const Color(0xFF5C4ECC),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.ratio,
            minHeight: 8,
            backgroundColor: const Color(0xFFE8E8F0),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF5C4ECC)),
          ),
        ),
      ],
    );
  }
}
