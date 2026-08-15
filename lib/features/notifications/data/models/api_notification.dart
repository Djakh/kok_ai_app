class ApiNotification {
  const ApiNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  factory ApiNotification.fromJson(Map<String, dynamic> json) =>
      ApiNotification(
        id: '${json['id'] ?? ''}',
        title: '${json['title'] ?? json['type'] ?? 'Notification'}',
        body: '${json['body'] ?? json['message'] ?? ''}',
        isRead: json['is_read'] == true,
        createdAt: DateTime.tryParse('${json['created_at']}'),
      );

  ApiNotification copyWith({bool? isRead}) => ApiNotification(
    id: id,
    title: title,
    body: body,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );
}
