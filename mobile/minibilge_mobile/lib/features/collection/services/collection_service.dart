import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/badge_dto.dart';
import '../models/card_dto.dart';

class CollectionService {
  final Dio _dio;
  CollectionService(this._dio);

  Future<BadgeCollectionDto> getBadgeCollection(String childId) async {
    final response = await _dio.get('/badge/child/$childId');
    return BadgeCollectionDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CardCollectionDto> getCardCollection(String childId) async {
    final response = await _dio.get('/card/collection/$childId');
    return CardCollectionDto.fromJson(response.data as Map<String, dynamic>);
  }
}

final collectionServiceProvider = Provider<CollectionService>((ref) {
  return CollectionService(ref.read(dioProvider));
});
