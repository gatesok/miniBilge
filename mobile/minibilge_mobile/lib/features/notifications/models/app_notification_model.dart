class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final String notificationType;
  final bool isRead;
  final DateTime createdAt;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.notificationType,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      AppNotificationModel(
        id: json['Id'] as String,
        title: json['Title'] as String? ?? '',
        body: json['Body'] as String? ?? '',
        notificationType: json['NotificationType'] as String? ?? '',
        isRead: json['IsRead'] as bool? ?? false,
        createdAt: DateTime.parse(json['CreatedAt'] as String),
      );
}
