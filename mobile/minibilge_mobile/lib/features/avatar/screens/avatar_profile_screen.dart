import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../providers/avatar_provider.dart';
import '../widgets/point_balance_widget.dart';
import '../models/item_type.dart';
import '../models/equipped_item.dart';

class AvatarProfileScreen extends ConsumerStatefulWidget {
  const AvatarProfileScreen({super.key});

  @override
  ConsumerState<AvatarProfileScreen> createState() => _AvatarProfileScreenState();
}

class _AvatarProfileScreenState extends ConsumerState<AvatarProfileScreen> {
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
      ref.read(avatarProvider.notifier).loadAvatarData(selectedChild.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedChild = ref.watch(selectedChildProvider);
    final avatarState = ref.watch(avatarProvider);

    if (selectedChild == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Avatar')),
        body: const Center(child: Text('Lütfen bir çocuk profili seçin')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Profilim'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CompactPointBalanceWidget(),
          ),
        ],
      ),
      body: avatarState.when(
        initial: () => const Center(child: Text('Veri yüklenmedi')),
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
        loaded: (availableItems, ownedItems, equippedItems) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Display Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar Preview Area
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.5),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background layer
                            ..._buildEquippedItemLayer(equippedItems, ItemType.background),
                            
                            // Base avatar
                            Icon(
                              Icons.person,
                              size: 120,
                              color: theme.colorScheme.primary,
                            ),
                            
                            // Outfit layer
                            ..._buildEquippedItemLayer(equippedItems, ItemType.outfit),
                            
                            // Accessory layer
                            ..._buildEquippedItemLayer(equippedItems, ItemType.accessory),
                            
                            // Hat layer
                            ..._buildEquippedItemLayer(equippedItems, ItemType.hat),
                            
                            // Glasses layer
                            ..._buildEquippedItemLayer(equippedItems, ItemType.glasses),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        selectedChild.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${equippedItems.length} ekipman takılı',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/avatar/shop'),
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Mağaza'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/avatar/inventory'),
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Envanter'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Equipped Items Section
              Text(
                'Takılı Ekipmanlar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (equippedItems.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.checkroom_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz ekipman takmadınız',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...equippedItems.map((item) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        _getItemTypeIcon(item.type),
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: Text(item.itemTypeName),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        final success = await ref
                            .read(avatarProvider.notifier)
                            .unequipItem(
                              childProfileId: selectedChild.id,
                              itemId: item.itemId,
                            );
                        
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item.name} çıkarıldı')),
                          );
                        }
                      },
                    ),
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEquippedItemLayer(List<EquippedItem> equippedItems, ItemType type) {
    final item = equippedItems.where((e) => e.type == type).firstOrNull;
    if (item == null) return [];
    
    // Placeholder for actual item rendering
    // In real implementation, this would load and display the item's image
    return [
      Positioned(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              _getItemTypeIcon(type),
              size: 40,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    ];
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
