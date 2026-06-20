import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../models/card_dto.dart';
import '../providers/collection_provider.dart';

class CardCollectionScreen extends ConsumerWidget {
  const CardCollectionScreen({super.key});

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
          child: child == null
              ? Center(
                  child: Text('Profil seçilmedi',
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)))
              : _Body(childId: child.id),
        ),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  final String childId;
  const _Body({required this.childId});

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  String _selectedSeries = 'all';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(cardCollectionProvider(widget.childId));

    return Column(
      children: [
        _Header(onBack: () => Navigator.of(context).pop()),
        Expanded(
          child: async.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white)),
            error: (e, _) => Center(
                child: Text('Hata: $e',
                    style: GoogleFonts.nunito(
                        color: Colors.white, fontWeight: FontWeight.w700))),
            data: (col) => _Content(
              collection: col,
              selectedSeries: _selectedSeries,
              onSeriesChanged: (s) => setState(() => _selectedSeries = s),
              childId: widget.childId,
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
                    color: Colors.white.withOpacity(0.5), width: 1.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Kart Koleksiyonum 🃏',
            style: GoogleFonts.luckiestGuy(
              fontSize: 20,
              color: Colors.white,
              shadows: const [
                Shadow(
                    blurRadius: 0,
                    color: Color(0xFF3D35CC),
                    offset: Offset(2, 2))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  final CardCollectionDto collection;
  final String selectedSeries;
  final ValueChanged<String> onSeriesChanged;
  final String childId;

  static const _seriesFilters = [
    ('all', 'Tümü'),
    ('Hayvanlar', '🐾 Hayvanlar'),
    ('Kahramanlar', '⚔️ Kahramanlar'),
    ('Efsaneler', '💫 Efsaneler'),
  ];

  const _Content({
    required this.collection,
    required this.selectedSeries,
    required this.onSeriesChanged,
    required this.childId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = selectedSeries == 'all'
        ? collection.cards
        : collection.cards
            .where((c) => c.series == selectedSeries)
            .toList()
          ..sort((a, b) => a.cardNumber.compareTo(b.cardNumber));

    return Column(
      children: [
        // Progress header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _ProgressCard(
            owned: collection.ownedCount,
            total: collection.totalCards,
          ),
        ),
        // Series filter
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _seriesFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final (key, label) = _seriesFilters[i];
              final isSelected = key == selectedSeries;
              return GestureDetector(
                onTap: () => onSeriesChanged(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
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
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) =>
                _CardTile(card: filtered[i], childId: childId),
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int owned;
  final int total;
  const _ProgressCard({required this.owned, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? owned / total : 0.0;
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
                  Text('Toplam Kart',
                      style: GoogleFonts.nunito(
                          color: const Color(0xFF757575),
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('$owned / $total',
                      style: GoogleFonts.luckiestGuy(
                          fontSize: 22, color: const Color(0xFF1A1A2E))),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE8E8F0),
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF5C4ECC)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text('${(pct * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.luckiestGuy(
                    fontSize: 28, color: const Color(0xFF5C4ECC))),
          ],
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final CollectibleCardDto card;
  final String childId;
  const _CardTile({required this.card, required this.childId});

  Color _rarityColor() {
    switch (card.rarity) {
      case 'rare':
        return const Color(0xFF1565C0);
      case 'epic':
        return const Color(0xFF6A1B9A);
      case 'legendary':
        return const Color(0xFFFF8F00);
      default:
        return const Color(0xFF4CAF50); // common
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor();
    final isOwned = card.isOwned;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isOwned ? Colors.white : Colors.white.withOpacity(0.15),
          border: isOwned
              ? Border.all(color: color.withOpacity(0.5), width: 2)
              : null,
          boxShadow: isOwned
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]
              : null,
        ),
        child: Column(
          children: [
            // Card image area (top rounded)
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: isOwned
                    ? _CardImage(imageAsset: card.imageAsset)
                    : Container(
                        color: Colors.white.withOpacity(0.08),
                        child: const Center(
                            child: Text('🔒',
                                style: TextStyle(fontSize: 32))),
                      ),
              ),
            ),
            // Card info (bottom)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isOwned ? card.name : '???',
                      style: GoogleFonts.nunito(
                        color: isOwned
                            ? const Color(0xFF1A1A2E)
                            : Colors.white38,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: isOwned
                            ? color.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOwned ? _rarityLabel() : '—',
                        style: GoogleFonts.nunito(
                          color: isOwned ? color : Colors.white24,
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    if (isOwned && card.ownedCount > 1)
                      Text(
                        'x${card.ownedCount}',
                        style: GoogleFonts.luckiestGuy(
                            fontSize: 9, color: const Color(0xFF7B61FF)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rarityLabel() {
    switch (card.rarity) {
      case 'rare':
        return '💙 Nadir';
      case 'epic':
        return '💜 Epik';
      case 'legendary':
        return '🟡 Efsane';
      default:
        return '🟢 Yaygın';
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CardDetailSheet(card: card),
    );
  }
}

class _CardImage extends StatelessWidget {
  final String imageAsset;
  const _CardImage({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    try {
      return Image.asset(
        imageAsset,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _Placeholder(imageAsset: imageAsset),
      );
    } catch (_) {
      return _Placeholder(imageAsset: imageAsset);
    }
  }
}

class _Placeholder extends StatelessWidget {
  final String imageAsset;
  const _Placeholder({required this.imageAsset});

  String _seriesEmoji() {
    if (imageAsset.contains('animals')) return '🐾';
    if (imageAsset.contains('heroes')) return '⚔️';
    if (imageAsset.contains('legends')) return '💫';
    return '🃏';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0EEF8),
      child: Center(
          child: Text(_seriesEmoji(),
              style: const TextStyle(fontSize: 28))),
    );
  }
}

class _CardDetailSheet extends StatelessWidget {
  final CollectibleCardDto card;
  const _CardDetailSheet({required this.card});

  Color _rarityColor() {
    switch (card.rarity) {
      case 'rare':
        return const Color(0xFF1565C0);
      case 'epic':
        return const Color(0xFF6A1B9A);
      case 'legendary':
        return const Color(0xFFFF8F00);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwned = card.isOwned;
    final color = _rarityColor();

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
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          // Card image
          Container(
            width: 140,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: isOwned
                  ? _CardImage(imageAsset: card.imageAsset)
                  : Container(
                      color: const Color(0xFFF0EEF8),
                      child: const Center(
                          child: Text('🔒',
                              style: TextStyle(fontSize: 48)))),
            ),
          ),
          const SizedBox(height: 16),
          // Card number badge
          Text('#${card.cardNumber.toString().padLeft(3, '0')}',
              style: GoogleFonts.luckiestGuy(
                  fontSize: 12, color: const Color(0xFF9E9E9E))),
          const SizedBox(height: 4),
          Text(
            isOwned ? card.name : '???',
            style: GoogleFonts.luckiestGuy(
                fontSize: 22, color: const Color(0xFF1A1A2E)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (isOwned) ...[
            Text(card.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    color: const Color(0xFF616161),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${card.series} • ${_rarityLabel()}',
                style: GoogleFonts.nunito(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12),
              ),
            ),
            if (card.ownedCount > 1) ...[
              const SizedBox(height: 8),
              Text('${card.ownedCount} adet',
                  style: GoogleFonts.nunito(
                      color: const Color(0xFF7B61FF),
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ],
          ] else ...[
            Text('Bu kartı henüz kazanmadın',
                style: GoogleFonts.nunito(
                    color: const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(height: 4),
            Text('Quiz\'leri tamamla, kart topla! 🎮',
                style: GoogleFonts.nunito(
                    color: const Color(0xFF7B61FF),
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _rarityLabel() {
    switch (card.rarity) {
      case 'rare':
        return '💙 Nadir';
      case 'epic':
        return '💜 Epik';
      case 'legendary':
        return '🟡 Efsane';
      default:
        return '🟢 Yaygın';
    }
  }
}
