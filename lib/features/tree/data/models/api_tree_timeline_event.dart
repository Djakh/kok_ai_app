class ApiTreeTimelineEvent {
  const ApiTreeTimelineEvent({
    required this.id,
    required this.eventType,
    required this.details,
    required this.createdAt,
  });

  final String id;
  final String eventType;
  final dynamic details;
  final DateTime? createdAt;

  factory ApiTreeTimelineEvent.fromJson(Map<String, dynamic> json) =>
      ApiTreeTimelineEvent(
        id: '${json['id'] ?? ''}',
        eventType: '${json['event_type'] ?? ''}',
        details: json['details'],
        createdAt: DateTime.tryParse('${json['created_at']}'),
      );
}
