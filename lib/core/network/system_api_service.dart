import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/core/network/api_config.dart';

class SystemApiService {
  const SystemApiService({required this.apiClient});
  final ApiClient apiClient;

  Future<Map<String, dynamic>> getVersion() async {
    final data = await apiClient.getSystem('${ApiConfig.apiBasePath}/version');
    return _map(data);
  }

  Future<Map<String, dynamic>> getHealth() async {
    final data = await apiClient.getSystem('/health');
    return _map(data);
  }

  Future<Map<String, dynamic>> getReadiness() async {
    final data = await apiClient.getSystem('/ready');
    return _map(data);
  }

  Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : <String, dynamic>{'value': value};
}
