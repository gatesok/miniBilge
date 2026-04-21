import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../providers/avatar_provider.dart';
import '../widgets/point_balance_widget.dart';
import '../models/avatar_item.dart';
import '../models/item_type.dart';

class AvatarInventoryScreen extends ConsumerStatefulWidget {
  const AvatarInventoryScreen({super.key});

  @override
  ConsumerState<AvatarInventoryScreen> createState() => _AvatarInventoryScreenState();
}

class _AvatarInventoryScreenState extends ConsumerState<AvatarInventoryScreen> {
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
      ref.read(avatarProvider.notifier).loadOwnedItems(selectedChild.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedChild = ref.watch(selectedChildProvider);
    final avatarState = ref.watch(avatarProvider);

    if (selectedChild == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Envanter')),
        body: const Center(child: Text('Lütfen bir çocuk profili seçin')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Envanter'),
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
          
          // Inventory Items
          Expanded(
            child: avatarState.when(
              initial: () => const Center(child: Text('Envanter yüklenmedi')),
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
                var items = ownedItems;
                if (_selectedFilter != null) {
                  items = items.where((item) => item.type == _selectedFilter).toList();
                }

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == null
                              ? 'Henüz hiç eşyanız yok'
                              : 'Bu kategoride eşya bulunamadı',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mağazadan eşya satın alabilirsiniz',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} takıldı!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload to update equipped state
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ekipman takılamadı'),
            backgroundColor: Colors.red,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} çıkarıldı'),
            backgroundColor: Colors.orange,
          ),
        );
        // Reload to update equipped state
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ekipman çıkarılamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _InventoryItemCard extends StatelessWidget {
  final AvatarItem item;
  final VoidCallback onEquip;
  final VoidCallback onUnequip;

  const _InventoryItemCard({
    required this.item,
    required this.onEquip,
    required this.onUnequip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
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
                    child: Icon(
                      _getItemTypeIcon(item.type),
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (item.isEquipped)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
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
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: item.isEquipped
                      ? OutlinedButton(
                          onPressed: onUnequip,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text('Çıkar', style: TextStyle(fontSize: 12)),
                        )
                      : ElevatedButton(
                          onPressed: onEquip,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text('Tak', style: TextStyle(fontSize: 12)),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getItemTypeIcon(ItemType type) {
    switch (type) {
      case ItemType.hat:
        return Icons.attribution;
      case ItemType.glasses:
        return Icons.visibility;
      case ItemType.outfit:
        return Icons.checkroom;
      case ItemType.accessory:
        return Icons.star;
      case ItemType.background:
        return Icons.landscape;
    }
  }
}
