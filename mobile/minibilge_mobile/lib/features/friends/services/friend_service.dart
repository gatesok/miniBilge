import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/friend_models.dart';

class FriendService {
  final Dio _dio;
  FriendService(this._dio);

  Future<List<FriendDto>> getFriends(String childId) async {
    final r = await _dio.get('/friends', queryParameters: {'childId': childId});
    return (r.data as List).map((e) => FriendDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<FriendDto>> getPendingRequests(String childId) async {
    final r = await _dio.get('/friends/requests', queryParameters: {'childId': childId});
    return (r.data as List).map((e) => FriendDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FriendSearchResultDto?> searchByCode(String requesterId, String code) async {
    final r = await _dio.get('/friends/search',
        queryParameters: {'requesterId': requesterId, 'code': code});
    if (r.data == null) return null;
    return FriendSearchResultDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<FriendDto> sendRequest(String requesterId, String friendCode) async {
    final r = await _dio.post('/friends/request',
        data: {'RequesterId': requesterId, 'FriendCode': friendCode});
    return FriendDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> respondRequest(String friendshipId, String childId, bool accept) async {
    await _dio.put('/friends/$friendshipId/respond',
        data: {'AddresseeId': childId, 'Accept': accept});
  }

  Future<void> removeFriend(String friendshipId, String childId) async {
    await _dio.delete('/friends/$friendshipId', queryParameters: {'childId': childId});
  }

  // ── Match invitations ────────────────────────────────────────────────────

  Future<MatchInvitationDto> sendMatchInvite(
      String inviterId, String inviteeId, {String? subjectId}) async {
    final r = await _dio.post('/match/invite', data: {
      'InviterId': inviterId,
      'InviteeId': inviteeId,
      if (subjectId != null) 'SubjectId': subjectId,
    });
    return MatchInvitationDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<MatchInvitationDto> respondMatchInvite(
      String invitationId, String inviteeId, bool accept) async {
    final r = await _dio.put('/match/invite/$invitationId/respond',
        data: {'InviteeId': inviteeId, 'Accept': accept});
    return MatchInvitationDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<List<MatchInvitationDto>> getPendingInvites(String inviteeId) async {
    final r = await _dio.get('/match/invites/pending',
        queryParameters: {'inviteeId': inviteeId});
    return (r.data as List)
        .map((e) => MatchInvitationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelMatchInvite(String invitationId, String inviterId) async {
    await _dio.delete('/match/invite/$invitationId',
        queryParameters: {'inviterId': inviterId});
  }

  Future<Map<String, bool>> getOnlineStatuses(List<String> childIds) async {
    if (childIds.isEmpty) return {};
    final r = await _dio.get('/friends/online-statuses',
        queryParameters: {'childIds': childIds});
    return (r.data as Map).map(
        (k, v) => MapEntry(k.toString(), v as bool));
  }
}

final friendServiceProvider = Provider<FriendService>((ref) {
  return FriendService(ref.read(dioProvider));
});
