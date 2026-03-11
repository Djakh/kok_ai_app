import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/features/tree/data/models/tree_register_result.dart';
import 'package:kok_ai_app/features/tree/data/models/tree_registration_payload.dart';
import 'package:kok_ai_app/features/upload/data/services/upload_api_service.dart';

class TreeApiService {
  const TreeApiService({
    required this.apiClient,
    required this.uploadApiService,
  });

  final ApiClient apiClient;
  final UploadApiService uploadApiService;

  Future<TreeRegisterResult> registerTree(
    TreeRegistrationPayload payload,
  ) async {
    final uploads = await uploadApiService.uploadImages(
      paths: [
        payload.frontImagePath,
        payload.trunkImagePath,
        payload.leavesImagePath,
      ],
    );

    if (uploads.length < 3) {
      throw const FormatException(
        'Not enough uploaded images for tree registration',
      );
    }

    final body = {
      'name': payload.name,
      'location': {
        'latitude': payload.latitude,
        'longitude': payload.longitude,
        'accuracy_meters': payload.accuracyMeters,
      },
      'images': {
        'front': uploads[0].id,
        'trunk': uploads[1].id,
        'leaves': uploads[2].id,
      },
      'captured_at': payload.capturedAt.toUtc().toIso8601String(),
    };

    final idempotencyKey =
        'reg-tree-${DateTime.now().millisecondsSinceEpoch}-${payload.name}';
    final data = await apiClient.post(
      '/trees/register',
      body: body,
      headers: {'Idempotency-Key': idempotencyKey},
    );
    return TreeRegisterResult.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
