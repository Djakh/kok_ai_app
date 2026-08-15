import 'package:dio/dio.dart';
import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/features/upload/data/models/uploaded_asset.dart';

class UploadApiService {
  const UploadApiService({required this.apiClient});

  final ApiClient apiClient;

  Future<UploadedAsset> uploadImage({required String path}) async {
    final fileName = path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: fileName),
    });
    final data = await apiClient.post('/uploads/images', body: formData);
    return UploadedAsset.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<UploadedAsset>> uploadImages({
    required List<String> paths,
  }) async {
    final parts = <MapEntry<String, MultipartFile>>[];
    for (final path in paths) {
      final fileName = path.split('/').last;
      parts.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(path, filename: fileName),
        ),
      );
    }
    final formData = FormData();
    formData.files.addAll(parts);
    final data = await apiClient.post('/uploads/images/batch', body: formData);
    final list = List<Map<String, dynamic>>.from(data as List);
    return list.map(UploadedAsset.fromJson).toList();
  }

  Future<UploadedAsset> getUpload(String uploadId) async {
    final data = await apiClient.get('/uploads/$uploadId');
    return UploadedAsset.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
