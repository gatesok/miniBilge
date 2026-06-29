import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../models/friend_models.dart';

/// Event payloads
class FriendRequestEvent {
  final String friendshipId;
  final String requesterId;
  final String requesterName;
  final String requesterAvatar;
  const FriendRequestEvent({
    required this.friendshipId,
    required this.requesterId,
    required this.requesterName,
    required this.requesterAvatar,
  });
}

class MatchInviteEvent {
  final MatchInvitationDto invitation;
  const MatchInviteEvent(this.invitation);
}

class MatchInviteResponseEvent {
  final String invitationId;
  final bool accepted;
  final String? matchSessionId;
  const MatchInviteResponseEvent({
    required this.invitationId,
    required this.accepted,
    this.matchSessionId,
  });
}

/// SignalR SocialHub client
class SocialHubService {
  HubConnection? _hub;
  final String _hubUrl;
  final FlutterSecureStorage _secureStorage;

  final _friendRequestCtrl = StreamController<FriendRequestEvent>.broadcast();
  final _matchInviteCtrl    = StreamController<MatchInviteEvent>.broadcast();
  final _matchInviteRespCtrl = StreamController<MatchInviteResponseEvent>.broadcast();

  Stream<FriendRequestEvent>       get onFriendRequest       => _friendRequestCtrl.stream;
  Stream<MatchInviteEvent>         get onMatchInvite         => _matchInviteCtrl.stream;
  Stream<MatchInviteResponseEvent> get onMatchInviteResponse => _matchInviteRespCtrl.stream;

  SocialHubService({
    required String baseUrl,
    required FlutterSecureStorage secureStorage,
  })  : _hubUrl = '$baseUrl/hubs/social',
        _secureStorage = secureStorage;

  bool get isConnected => _hub?.state == HubConnectionState.Connected;

  Future<void> connect() async {
    if (isConnected) return;

    final token = await _secureStorage.read(key: StorageKeys.accessToken) ?? '';

    _hub = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            transport: HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _hub!.on('FriendRequestReceived', _onFriendRequest);
    _hub!.on('MatchInviteReceived',   _onMatchInvite);
    _hub!.on('MatchInviteResponded',  _onMatchInviteResponse);

    await _hub!.start();
  }

  Future<void> disconnect() async {
    await _hub?.stop();
    _hub = null;
  }

  void _onFriendRequest(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final d = args[0] as Map<String, dynamic>;
    _friendRequestCtrl.add(FriendRequestEvent(
      friendshipId:   d['FriendshipId']?.toString() ?? '',
      requesterId:    d['RequesterId']?.toString()  ?? '',
      requesterName:  d['RequesterName']?.toString() ?? '',
      requesterAvatar: d['RequesterAvatar']?.toString() ?? '',
    ));
  }

  void _onMatchInvite(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final d = args[0] as Map<String, dynamic>;
    _matchInviteCtrl.add(MatchInviteEvent(
      MatchInvitationDto(
        id:           d['InvitationId']?.toString() ?? '',
        inviterId:    d['InviterId']?.toString()    ?? '',
        inviterName:  d['InviterName']?.toString()  ?? '',
        inviterAvatar: d['InviterAvatar']?.toString(),
        inviteeId:    '',
        inviteeName:  '',
        subjectId:    d['SubjectId']?.toString(),
        subjectName:  d['SubjectName'] as String?,
        status: 0,
        expiresAt: DateTime.tryParse(d['ExpiresAt']?.toString() ?? '') ?? DateTime.now(),
      ),
    ));
  }

  void _onMatchInviteResponse(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final d = args[0] as Map<String, dynamic>;
    _matchInviteRespCtrl.add(MatchInviteResponseEvent(
      invitationId:  d['InvitationId']?.toString() ?? '',
      accepted:      d['Accepted'] as bool? ?? false,
      matchSessionId: d['MatchSessionId']?.toString(),
    ));
  }

  void dispose() {
    _friendRequestCtrl.close();
    _matchInviteCtrl.close();
    _matchInviteRespCtrl.close();
    _hub?.stop();
  }
}

final socialHubServiceProvider = Provider<SocialHubService>((ref) {
  final storage = ref.read(secureStorageProvider);
  final baseUrl = ApiConstants.baseUrl
      .replaceFirst(RegExp(r'/api$'), ''); // hub URL'si /api içermez
  final svc = SocialHubService(baseUrl: baseUrl, secureStorage: storage);
  ref.onDispose(svc.dispose);
  return svc;
});
