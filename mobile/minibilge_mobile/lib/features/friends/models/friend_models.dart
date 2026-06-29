/// Friend system models
/// These mirror the backend DTOs without code-generation overhead.

class FriendDto {
  final String friendshipId;
  final String childId;
  final String name;
  final String? avatarImageUrl;
  final String friendCode;
  /// 0=Pending, 1=Accepted, 2=Blocked
  final int status;
  /// true = bu çocuk isteği gönderdi
  final bool isRequester;

  const FriendDto({
    required this.friendshipId,
    required this.childId,
    required this.name,
    this.avatarImageUrl,
    required this.friendCode,
    required this.status,
    required this.isRequester,
  });

  factory FriendDto.fromJson(Map<String, dynamic> json) => FriendDto(
        friendshipId: json['FriendshipId']?.toString() ?? '',
        childId: json['ChildId']?.toString() ?? '',
        name: json['Name']?.toString() ?? '',
        avatarImageUrl: json['AvatarImageUrl'] as String?,
        friendCode: json['FriendCode']?.toString() ?? '',
        status: (json['Status'] as num?)?.toInt() ?? 0,
        isRequester: json['IsRequester'] as bool? ?? false,
      );
}

class FriendSearchResultDto {
  final String childId;
  final String name;
  final String? avatarImageUrl;
  final String friendCode;
  final int? friendshipStatus;

  const FriendSearchResultDto({
    required this.childId,
    required this.name,
    this.avatarImageUrl,
    required this.friendCode,
    this.friendshipStatus,
  });

  factory FriendSearchResultDto.fromJson(Map<String, dynamic> json) =>
      FriendSearchResultDto(
        childId: json['ChildId']?.toString() ?? '',
        name: json['Name']?.toString() ?? '',
        avatarImageUrl: json['AvatarImageUrl'] as String?,
        friendCode: json['FriendCode']?.toString() ?? '',
        friendshipStatus: (json['FriendshipStatus'] as num?)?.toInt(),
      );
}

class MatchInvitationDto {
  final String id;
  final String inviterId;
  final String inviterName;
  final String? inviterAvatar;
  final String inviteeId;
  final String inviteeName;
  final String? subjectId;
  final String? subjectName;
  /// 0=Pending, 1=Accepted, 2=Declined, 3=Expired
  final int status;
  final DateTime expiresAt;
  final String? matchSessionId;

  const MatchInvitationDto({
    required this.id,
    required this.inviterId,
    required this.inviterName,
    this.inviterAvatar,
    required this.inviteeId,
    required this.inviteeName,
    this.subjectId,
    this.subjectName,
    required this.status,
    required this.expiresAt,
    this.matchSessionId,
  });

  factory MatchInvitationDto.fromJson(Map<String, dynamic> json) =>
      MatchInvitationDto(
        id: json['Id']?.toString() ?? '',
        inviterId: json['InviterId']?.toString() ?? '',
        inviterName: json['InviterName']?.toString() ?? '',
        inviterAvatar: json['InviterAvatar'] as String?,
        inviteeId: json['InviteeId']?.toString() ?? '',
        inviteeName: json['InviteeName']?.toString() ?? '',
        subjectId: json['SubjectId']?.toString(),
        subjectName: json['SubjectName'] as String?,
        status: (json['Status'] as num?)?.toInt() ?? 0,
        expiresAt: DateTime.tryParse(json['ExpiresAt']?.toString() ?? '') ??
            DateTime.now(),
        matchSessionId: json['MatchSessionId']?.toString(),
      );
}
