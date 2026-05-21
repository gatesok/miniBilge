import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../providers/avatar_provider.dart';
import '../widgets/point_balance_widget.dart';
import '../models/avatar_item.dart';
import '../models/item_type.dart';

class AvatarInventoryScreen extends ConsumerStatefulWidget {
  const AvatarInventoryScreen({super.key});

  @override
  ConsumerState<AvatarInventoryScreen> createState() =>
      _AvatarInventoryScreenState();
}

class _AvatarInventoryScreenState
    extends ConsumerState<AvatarInventoryScreen> {
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
      ref.read(avatarProvider.notifier).loadOwnedItems(selectedChild.id);
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5),
                        ),
                        child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Envanter',
                          style: GoogleFonts.luckiestGuy(
                            fontSize: 24,
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
                            color: Colors.white.withOpacity(0.45),
                            width: 1.5),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FilterPill(
                      label: '✓ Tümü',
                      selected: _selectedFilter == null,
                      onTap: () =>
                          setState(() => _selectedFilter = null),
                    ),
                    const SizedBox(width: 8),
                    ...ItemType.values.map((type) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterPill(
                            label: type.displayName,
                            selected: _selectedFilter == type,
                            onTap: () => setState(() =>
                                _selectedFilter = _selectedFilter == type
                                    ? null
                                    : type),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Inventory items
              Expanded(
                child: avatarState.when(
                  initial: () => Center(
                      child: Text('Envanter yüklenmedi',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.w700))),
                  loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white)),
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
                          GestureDetector(
                            onTap: _loadData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF4A3FCC),
                                  borderRadius:
                                      BorderRadius.circular(24)),
                              child: Text('Tekrar Dene',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  loaded: (availableItems, ownedItems, equippedItems) {
                    var items = _selectedFilter != null
                        ? ownedItems
                            .where((i) => i.type == _selectedFilter)
                            .toList()
                        : ownedItems;

                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📦',
                                style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == null
                                  ? 'Henüz hiç eşyanız yok'
                                  : 'Bu kategoride eşya bulunamadı',
                              style: GoogleFonts.nunito(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Mağazadan eşya satın alabilirsiniz',
                              style: GoogleFonts.nunito(
                                  color: Colors.white.withOpacity(0.65),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
                            ),
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
                        return _InventoryItemCard(
                          item: item,
                          onEquip: () => _handleEquip(item),
                          onUnequip: () => _handleUnequip(item),
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

  Future<void> _handleEquip(AvatarItem item) async {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null) return;

    final success = await ref.read(avatarProvider.notifier).equipItem(
          childProfileId: selectedChild.id,
          itemId: item.id,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${item.name} takıldı!'),
            backgroundColor: Colors.green));
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ekipman takılamadı'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _handleUnequip(AvatarItem item) async {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null) return;

    final success = await ref.read(avatarProvider.notifier).unequipItem(
          childProfileId: selectedChild.id,
          itemId: item.id,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${item.name} çıkarıldı'),
            backgroundColor: Colors.orange));
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ekipman çıkarılamadı'),
            backgroundColor: Colors.red));
      }
    }
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill(
      {required this.label,
      required this.selected,
      required this.onTap});

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

class _InventoryItemCard extends StatelessWidget {
  final AvatarItem item;
  final VoidCallback onEquip;
  final VoidCallback onUnequip;

  const _InventoryItemCard(
      {required this.item,
      required this.onEquip,
      required this.onUnequip});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.isEquipped
              ? Colors.greenAccent.withOpacity(0.7)
              : Colors.white.withOpacity(0.45),
          width: item.isEquipped ? 2 : 1.5,
        ),
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
                  if (item.isEquipped)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green,
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
                GestureDetector(
                  onTap: item.isEquipped ? onUnequip : onEquip,
                  child: Container(
                    width: double.infinity,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: item.isEquipped
                          ? const LinearGradient(colors: [
                              Color(0xFFE67E22),
                              Color(0xFFE84393)
                            ])
                          : const LinearGradient(colors: [
                              Color(0xFF27AE60),
                              Color(0xFF2ECC71)
                            ]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        item.isEquipped ? 'Çıkar' : 'Tak',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _extractEmoji(String text) {
    final emojiRegex = RegExp(r'[\p{Emoji}]', unicode: true);
    final match = emojiRegex.firstMatch(text);
    return match?.group(0) ?? '🎁';
  }
}
