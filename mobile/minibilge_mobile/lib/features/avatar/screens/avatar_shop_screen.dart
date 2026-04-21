import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild != null) {
      ref.read(avatarProvider.notifier).loadAvailableItems(selectedChild.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedChild = ref.watch(selectedChildProvider);
    final avatarState = ref.watch(avatarProvider);

    if (selectedChild == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mağaza')),
        body: const Center(child: Text('Lütfen bir çocuk profili seçin')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Mağazası'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CompactPointBalanceWidget(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('Tümü'),
                  selected: _selectedFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...ItemType.values.map((type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type.displayName),
                    selected: _selectedFilter == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? type : null;
                      });
                    },
                  ),
                )),
              ],
            ),
          ),
          
          // Shop Items
          Expanded(
            child: avatarState.when(
              initial: () => const Center(child: Text('Mağaza yüklenmedi')),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(message, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
              loaded: (availableItems, ownedItems, equippedItems) {
                // Filter items
                var items = availableItems;
                if (_selectedFilter != null) {
                  items = items.where((item) => item.type == _selectedFilter).toList();
                }

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bu kategoride ürün bulunamadı',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
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
    );
  }

  Future<void> _showPurchaseDialog(AvatarItem item) async {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Satın Alma Onayı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.name} ürünü satın almak istiyor musunuz?'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '${item.pointCost} Puan',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Mevcut: ${selectedChild.totalCoins} Puan',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: selectedChild.totalCoins >= item.pointCost
                ? () => Navigator.pop(context, true)
                : null,
            child: const Text('Satın Al'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(avatarProvider.notifier).purchaseItem(
            childProfileId: selectedChild.id,
            itemId: item.id,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.name} satın alındı!'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh child profile to update points
          await ref.read(childProfileProvider.notifier).loadProfiles();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Satın alma başarısız oldu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showPreviewDialog(AvatarItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Item preview
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _extractEmoji(item.name),
                    style: const TextStyle(fontSize: 120),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Chip(label: Text(item.itemTypeName)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '${item.pointCost} Puan',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kapat'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showPurchaseDialog(item);
                    },
                    child: const Text('Satın Al'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractEmoji(String text) {
    // Extract the first emoji from the item name
    final emojiRegex = RegExp(r'[\p{Emoji}]', unicode: true);
    final match = emojiRegex.firstMatch(text);
    return match?.group(0) ?? '🎁';
  }
}

class _ShopItemCard extends StatelessWidget {
  final AvatarItem item;
  final VoidCallback onPurchase;
  final VoidCallback onPreview;

  const _ShopItemCard({
    required this.item,
    required this.onPurchase,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPreview,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Item Image Area
            Expanded(
              child: Container(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        _extractEmoji(item.name),
                        style: const TextStyle(fontSize: 72),
                      ),
                    ),
                    if (item.isOwned)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.check, size: 16, color: Colors.white),
                        ),
                      ),
                    if (item.isEquipped)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Takılı',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Item Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.itemTypeName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.stars, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${item.pointCost}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (!item.isOwned)
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: onPurchase,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('Al', style: TextStyle(fontSize: 12)),
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
    // Extract the first emoji from the item name
    final emojiRegex = RegExp(r'[\p{Emoji}]', unicode: true);
    final match = emojiRegex.firstMatch(text);
    return match?.group(0) ?? '🎁';
  }
}
