import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge_dto.dart';
import '../models/card_dto.dart';
import '../services/collection_service.dart';

final badgeCollectionProvider =
    FutureProvider.family<BadgeCollectionDto, String>((ref, childId) async {
  return ref.read(collectionServiceProvider).getBadgeCollection(childId);
});

final cardCollectionProvider =
    FutureProvider.family<CardCollectionDto, String>((ref, childId) async {
  return ref.read(collectionServiceProvider).getCardCollection(childId);
});
