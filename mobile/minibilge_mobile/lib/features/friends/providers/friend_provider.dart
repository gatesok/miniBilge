import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/friend_models.dart';
import '../services/friend_service.dart';
import '../services/social_hub_service.dart';
import '../../child_profile/providers/selected_child_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────

class FriendState {
  final List<FriendDto> friends;
  final List<FriendDto> pendingRequests;
  final FriendSearchResultDto? searchResult;
  final List<MatchInvitationDto> pendingInvites;
  final bool isLoading;
  final String? error;
  final Map<String, bool> onlineStatuses;
  /// Gönderilen bekleyen davetler: arkadaş childId → invitationId
  final Map<String, String> sentPendingInvites;

  const FriendState({
    this.friends = const [],
    this.pendingRequests = const [],
    this.searchResult,
    this.pendingInvites = const [],
    this.isLoading = false,
    this.error,
    this.onlineStatuses = const {},
    this.sentPendingInvites = const {},
  });

  FriendState copyWith({
    List<FriendDto>? friends,
    List<FriendDto>? pendingRequests,
    FriendSearchResultDto? searchResult,
    bool clearSearch = false,
    List<MatchInvitationDto>? pendingInvites,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Map<String, bool>? onlineStatuses,
    Map<String, String>? sentPendingInvites,
  }) =>
      FriendState(
        friends: friends ?? this.friends,
        pendingRequests: pendingRequests ?? this.pendingRequests,
        searchResult: clearSearch ? null : (searchResult ?? this.searchResult),
        pendingInvites: pendingInvites ?? this.pendingInvites,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        onlineStatuses: onlineStatuses ?? this.onlineStatuses,
        sentPendingInvites: sentPendingInvites ?? this.sentPendingInvites,
      );
}

// ── Notifier ─────────────────────────────────────────────────────────────

class FriendNotifier extends StateNotifier<FriendState> {
  final FriendService _service;
  final SocialHubService _hub;
  final Ref _ref;

  StreamSubscription? _friendReqSub;
  StreamSubscription? _matchInviteSub;
  StreamSubscription? _matchInviteRespSub;
  final Map<String, Timer> _inviteTimers = {};

  FriendNotifier(this._service, this._hub, this._ref) : super(const FriendState()) {
    _subscribeHub();
  }

  void _subscribeHub() {
    _friendReqSub = _hub.onFriendRequest.listen((e) {
      // Yeni bekleyen istek: listeye ekle
      final fake = FriendDto(
        friendshipId: e.friendshipId,
        childId: e.requesterId,
        name: e.requesterName,
        avatarImageUrl: e.requesterAvatar.isEmpty ? null : e.requesterAvatar,
        friendCode: '',
        status: 0,
        isRequester: false,
      );
      state = state.copyWith(
        pendingRequests: [fake, ...state.pendingRequests],
      );
    });

    _matchInviteSub = _hub.onMatchInvite.listen((e) {
      state = state.copyWith(
        pendingInvites: [e.invitation, ...state.pendingInvites],
      );
    });

    _matchInviteRespSub = _hub.onMatchInviteResponse.listen((e) {
      // Gelen daveti temizle (invitee tarafı)
      state = state.copyWith(
        pendingInvites: state.pendingInvites
            .where((i) => i.id != e.invitationId)
            .toList(),
      );
      // Gönderilen daveti temizle (inviter tarafı)
      _clearSentInvite(e.invitationId);
    });
  }

  void _clearSentInvite(String invitationId) {
    final entry = state.sentPendingInvites.entries
        .where((e) => e.value == invitationId)
        .firstOrNull;
    if (entry != null) {
      _inviteTimers[entry.key]?.cancel();
      _inviteTimers.remove(entry.key);
      final updated = Map<String, String>.from(state.sentPendingInvites)
        ..remove(entry.key);
      state = state.copyWith(sentPendingInvites: updated);
    }
  }

  // ── Connect hub ──────────────────────────────────────────────────────────

  Future<void> connectHub() async {
    final childId = _ref.read(selectedChildProvider)?.id;
    if (childId == null) return;
    try {
      await _hub.connect(childId);
    } catch (_) {}
  }

  // ── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadFriends() async {
    final childId = _ref.read(selectedChildProvider)?.id;
    if (childId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final friends = await _service.getFriends(childId);
      state = state.copyWith(friends: friends, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadPendingRequests() async {
    final childId = _ref.read(selectedChildProvider)?.id;
    if (childId == null) return;

    try {
      final pending = await _service.getPendingRequests(childId);
      state = state.copyWith(pendingRequests: pending);
    } catch (_) {}
  }

  Future<void> loadPendingInvites() async {
    final childId = _ref.read(selectedChildProvider)?.id;
    if (childId == null) return;

    try {
      final invites = await _service.getPendingInvites(childId);
      state = state.copyWith(pendingInvites: invites);
    } catch (_) {}
  }

  Future<void> loadOnlineStatuses() async {
    if (state.friends.isEmpty) return;
    try {
      final childIds = state.friends.map((f) => f.childId).toList();
      final statuses = await _service.getOnlineStatuses(childIds);
      state = state.copyWith(onlineStatuses: statuses);
    } catch (_) {}
  }

  // ── Search ────────────────────────────────────────────────────────────────

  Future<void> searchByCode(String code) async {
    final childId = _ref.read(selectedChildProvider)?.id;
    if (childId == null || code.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.searchByCode(childId, code.trim().toUpperCase());
      state = state.copyWith(searchResult: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Arama başarısız: $e');
    }
  }

  void clearSearch() => state = state.copyWith(clearSearch: true);

  // ── Request ───────────────────────────────────────────────────────────────

  Future<void> sendRequest(String friendCode) async {
    final childId = _ref.read(selectedChildProvider)?.id;
    if (childId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.sendRequest(childId, friendCode);
      state = state.copyWith(isLoading: false, clearSearch: true);
      await loadFriends();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'İstek gönderilemedi: $e');
    }
  }

  Future<void> respondRequest(String friendshipId, bool accept) async {
    final childId = _ref.read(selectedChildProvider)?.id;
    if (childId == null) return;

    try {
      await _service.respondRequest(friendshipId, childId, accept);
      state = state.copyWith(
        pendingRequests:
            state.pendingRequests.where((f) => f.friendshipId != friendshipId).toList(),
      );
      if (accept) await loadFriends();
    } catch (e) {
      state = state.copyWith(error: 'Yanıt gönderilemedi: $e');
    }
  }

  Future<void> removeFriend(String friendshipId) async {
    final childId = _ref.read(selectedChildProvider)?.id;
    if (childId == null) return;

    try {
      await _service.removeFriend(friendshipId, childId);
      state = state.copyWith(
        friends: state.friends.where((f) => f.friendshipId != friendshipId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Arkadaş kaldırılamadı: $e');
    }
  }

  // ── Match invite ─────────────────────────────────────────────────────────

  Future<MatchInvitationDto?> sendMatchInvite(String inviteeId, {String? subjectId}) async {
    final childId = _ref.read(selectedChildProvider)?.id;
    if (childId == null) return null;

    try {
      final result = await _service.sendMatchInvite(childId, inviteeId, subjectId: subjectId);
      // Bekleyen davet olarak işaretle
      final updated = Map<String, String>.from(state.sentPendingInvites)
        ..[inviteeId] = result.id;
      state = state.copyWith(sentPendingInvites: updated);
      // TTL sonunda (5dk) otomatik sıfırla
      _inviteTimers[inviteeId]?.cancel();
      _inviteTimers[inviteeId] = Timer(const Duration(seconds: 300), () {
        final m = Map<String, String>.from(state.sentPendingInvites)..remove(inviteeId);
        state = state.copyWith(sentPendingInvites: m);
        _inviteTimers.remove(inviteeId);
      });
      return result;
    } catch (e) {
      state = state.copyWith(error: 'Davet gönderilemedi: $e');
      return null;
    }
  }

  Future<MatchInvitationDto?> respondMatchInvite(String invitationId, bool accept) async {
    final childId = _ref.read(selectedChildProvider)?.id;
    if (childId == null) return null;

    try {
      final result = await _service.respondMatchInvite(invitationId, childId, accept);
      state = state.copyWith(
        pendingInvites:
            state.pendingInvites.where((i) => i.id != invitationId).toList(),
      );
      return result;
    } catch (e) {
      state = state.copyWith(error: 'Yanıt gönderilemedi: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _friendReqSub?.cancel();
    _matchInviteSub?.cancel();
    _matchInviteRespSub?.cancel();
    for (final t in _inviteTimers.values) {
      t.cancel();
    }
    _inviteTimers.clear();
    super.dispose();
  }
}

// ── Provider ─────────────────────────────────────────────────────────────

final friendProvider = StateNotifierProvider<FriendNotifier, FriendState>((ref) {
  final service = ref.read(friendServiceProvider);
  final hub     = ref.read(socialHubServiceProvider);
  return FriendNotifier(service, hub, ref);
});
