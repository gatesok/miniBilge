import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../child_profile/providers/child_profile_provider.dart';
import '../providers/avatar_provider.dart';
import '../widgets/point_balance_widget.dart';
import '../models/avatar_item.dart';
import '../models/item_type.dart';

class AvatarShopScreen extends ConsumerStatefulWidget {
  const AvatarShopScreen({super.key});

  @override
  ConsumerState<AvatarShopScreen> createState() => _AvatarShopScreenState();
}

class _AvatarShopScreenState extends ConsumerState<AvatarShopScreen> {
  ItemType? _selectedFilter;

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8), Color(0xFFC4A8E2)],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild != null) {
      ref.read(avatarProvider.notifier).loadAvailableItems(selectedChild.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChild = ref.watch(selectedChildProvider);
    final avatarState = ref.watch(avatarProvider);

    if (selectedChild == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _gradient),
          child: SafeArea(
            child: Center(
              child: Text('Lütfen bir çocuk profili seçin',
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
                    Expanded(
                      child: Text('Avatar Mağazası',
                          style: GoogleFonts.luckiestGuy(
                            fontSize: 22,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                  blurRadius: 0,
                                  color: Color(0xFF3D35CC),
                                  offset: Offset(2, 2))
                            ],
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.45), width: 1.5),
                      ),
                      child: const CompactPointBalanceWidget(),
                    ),
                  ],
                ),
              ),
              // Filter chips
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FilterPill(
                      label: '✓ Tümü',
                      selected: _selectedFilter == null,
                      onTap: () => setState(() => _selectedFilter = null),
                    ),
                    const SizedBox(width: 8),
                    ...ItemType.values.map((type) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterPill(
                            label: type.displayName,
                            selected: _selectedFilter == type,
                            onTap: () => setState(() =>
                                _selectedFilter =
                                    _selectedFilter == type ? null : type),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Shop items
              Expanded(
                child: avatarState.when(
                  initial: () => Center(
                      child: Text('Mağaza yüklenmedi',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700))),
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  error: (message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.white),
                          const SizedBox(height: 16),
                          Text(message,
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          _SmallButton(
                              label: 'Tekrar Dene', onTap: _loadData),
                        ],
                      ),
                    ),
                  ),
                  loaded: (availableItems, ownedItems, equippedItems) {
                    var items = _selectedFilter != null
                        ? availableItems
                            .where((i) => i.type == _selectedFilter)
                            .toList()
                        : availableItems;

                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🛍️',
                                style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 16),
                            Text('Bu kategoride ürün bulunamadı',
                                style: GoogleFonts.nunito(
                                    color: Colors.white.withOpacity(0.85),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _ShopItemCard(
                          item: item,
                          onPurchase: () => _showPurchaseDialog(item),
                          onPreview: () => _showPreviewDialog(item),
                        );
                      },
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

  Future<void> _showPurchaseDialog(AvatarItem item) async {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: Colors.white.withOpacity(0.45), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🛒 Satın Alma',
                  style: GoogleFonts.luckiestGuy(
                      fontSize: 22,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                            blurRadius: 0,
                            color: Color(0xFF3D35CC),
                            offset: Offset(2, 2))
                      ])),
              const SizedBox(height: 16),
              Text('${item.name} almak istiyor musun?',
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.45), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text('${item.pointCost} Taş',
                        style: GoogleFonts.luckiestGuy(
                            fontSize: 20,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                  blurRadius: 0,
                                  color: Color(0xFF3D35CC),
                                  offset: Offset(1, 1))
                            ])),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Mevcut: ${selectedChild.totalCoins} Taş',
                  style: GoogleFonts.nunito(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.45)),
                        ),
                        child: Center(
                          child: Text('İptal',
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Opacity(
                      opacity: selectedChild.totalCoins >= item.pointCost
                          ? 1.0
                          : 0.4,
                      child: GestureDetector(
                        onTap: selectedChild.totalCoins >= item.pointCost
                            ? () => Navigator.pop(context, true)
                            : null,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF9B59B6),
                                  Color(0xFF7B61FF)
                                ]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text('Satın Al',
                                style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(avatarProvider.notifier).purchaseItem(
            childProfileId: selectedChild.id,
            itemId: item.id,
          );
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${item.name} satın alındı!'),
              backgroundColor: Colors.green));
          await ref.read(childProfileProvider.notifier).loadProfiles();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Satın alma başarısız oldu'),
              backgroundColor: Colors.red));
        }
      }
    }
  }

  void _showPreviewDialog(AvatarItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7EC8F0), Color(0xFFAA9FE8)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: Colors.white.withOpacity(0.45), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.45), width: 1.5),
                ),
                child: Center(
                  child: Text(_extractEmoji(item.name),
                      style: const TextStyle(fontSize: 100)),
                ),
              ),
              const SizedBox(height: 16),
              Text(item.name,
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(item.itemTypeName,
                    style: GoogleFonts.nunito(
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text('${item.pointCost} Taş',
                      style: GoogleFonts.luckiestGuy(
                          fontSize: 22,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                                blurRadius: 0,
                                color: Color(0xFF3D35CC),
                                offset: Offset(1, 1))
                          ])),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.45)),
                        ),
                        child: Center(
                          child: Text('Kapat',
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
                  if (!item.isOwned) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showPurchaseDialog(item);
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Color(0xFF9B59B6),
                              Color(0xFF7B61FF)
                            ]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text('Satın Al',
                                style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractEmoji(String text) {
    final emojiRegex = RegExp(r'[\p{Emoji}]', unicode: true);
    final match = emojiRegex.firstMatch(text);
    return match?.group(0) ?? '🎁';
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFFE88EC9), Color(0xFF9B59B6)])
              : null,
          color: selected ? null : Colors.white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Colors.white.withOpacity(0.45),
            width: 1.5,
          ),
        ),
        child: Text(label,
            style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w700,
                fontSize: 14)),
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final AvatarItem item;
  final VoidCallback onPurchase;
  final VoidCallback onPreview;

  const _ShopItemCard(
      {required this.item,
      required this.onPurchase,
      required this.onPreview});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPreview,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: Colors.white.withOpacity(0.45), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Emoji area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(23)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(_extractEmoji(item.name),
                          style: const TextStyle(fontSize: 64)),
                    ),
                    if (item.isOwned)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                              color: Colors.green, shape: BoxShape.circle),
                          child: const Icon(Icons.check,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    if (item.isEquipped)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B61FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Takılı',
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(item.itemTypeName,
                      style: GoogleFonts.nunito(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 11)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 3),
                      Text('${item.pointCost}',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                      const Spacer(),
                      if (!item.isOwned)
                        GestureDetector(
                          onTap: onPurchase,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF9B59B6),
                                Color(0xFF7B61FF)
                              ]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('Al',
                                style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractEmoji(String text) {
    final emojiRegex = RegExp(r'[\p{Emoji}]', unicode: true);
    final match = emojiRegex.firstMatch(text);
    return match?.group(0) ?? '🎁';
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SmallButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
            color: const Color(0xFF4A3FCC),
            borderRadius: BorderRadius.circular(24)),
        child: Text(label,
            style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
      ),
    );
  }
}
