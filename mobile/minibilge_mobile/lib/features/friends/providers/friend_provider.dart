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

  const FriendState({
    this.friends = const [],
    this.pendingRequests = const [],
    this.searchResult,
    this.pendingInvites = const [],
    this.isLoading = false,
    this.error,
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
  }) =>
      FriendState(
        friends: friends ?? this.friends,
        pendingRequests: pendingRequests ?? this.pendingRequests,
        searchResult: clearSearch ? null : (searchResult ?? this.searchResult),
        pendingInvites: pendingInvites ?? this.pendingInvites,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
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
      // Kabul edildiyse pending invite'ı kaldır
      state = state.copyWith(
        pendingInvites: state.pendingInvites
            .where((i) => i.id != e.invitationId)
            .toList(),
      );
    });
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
      return await _service.sendMatchInvite(childId, inviteeId, subjectId: subjectId);
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
    super.dispose();
  }
}

// ── Provider ─────────────────────────────────────────────────────────────

final friendProvider = StateNotifierProvider<FriendNotifier, FriendState>((ref) {
  final service = ref.read(friendServiceProvider);
  final hub     = ref.read(socialHubServiceProvider);
  return FriendNotifier(service, hub, ref);
});
