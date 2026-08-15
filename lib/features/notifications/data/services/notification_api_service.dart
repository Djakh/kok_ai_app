import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/features/notifications/data/models/api_notification.dart';

class NotificationApiService {
  const NotificationApiService({required this.apiClient});

  final ApiClient apiClient;

  Future<List<ApiNotification>> listNotifications() async {
    final data = await apiClient.get('/notifications');
    final raw = data is Map ? data['items'] as List? ?? const [] : data as List;
    final list = List<Map<String, dynamic>>.from(raw);
    return list.map(ApiNotification.fromJson).toList();
  }

  Future<void> readOne(String notificationId) async {
    await apiClient.patch('/notifications/$notificationId/read');
  }

  Future<void> readAll() async {
    await apiClient.patch('/notifications/read-all');
  }
}
