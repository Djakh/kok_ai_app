import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/features/social/data/models/api_social_post.dart';
import 'package:kok_ai_app/features/tree/data/models/api_tree.dart';
import 'package:kok_ai_app/features/tree/data/models/api_tree_timeline_event.dart';
import 'package:kok_ai_app/features/tree/data/models/tree_registration_payload.dart';

class TreeApiService {
  const TreeApiService({required this.apiClient});

  final ApiClient apiClient;

  Future<List<ApiTree>> listTrees({
    String? cursor,
    int limit = 20,
    String sort = 'newest',
    String? status,
    String? ownerId,
    String? query,
  }) async {
    final data = await apiClient.get(
      '/trees',
      queryParameters: {
        'cursor': cursor,
        'limit': limit,
        'sort': sort,
        'status': status,
        'owner_id': ownerId,
        'q': query,
      },
    );
    final raw = data is Map ? data['items'] as List? ?? const [] : data as List;
    final list = raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
    return list.map(ApiTree.fromJson).toList();
  }

  Future<List<ApiTree>> listMapTrees({
    String? bbox,
    String? center,
    double? radius,
    String? status,
  }) async {
    final data = await apiClient.get(
      '/trees/map',
      queryParameters: {
        'bbox': bbox,
        'center': center,
        'radius': radius,
        'status': status,
      },
    );
    final raw = data is Map ? data['items'] as List? ?? const [] : data as List;
    return raw
        .whereType<Map>()
        .map((item) => ApiTree.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ApiTree> getTreeDetail(String treeId) async {
    final data = await apiClient.get('/trees/$treeId');
    return ApiTree.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<ApiTree> updateTree(
    String treeId, {
    String? name,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (status != null) body['status'] = status;
    final data = await apiClient.patch('/trees/$treeId', body: body);
    return ApiTree.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<ApiTreeTimelineEvent>> getTreeTimeline(String treeId) async {
    final data = await apiClient.get('/trees/$treeId/timeline');
    final raw = data is Map ? data['items'] as List? ?? const [] : data as List;
    final list = List<Map<String, dynamic>>.from(raw);
    return list.map(ApiTreeTimelineEvent.fromJson).toList();
  }

  Future<List<ApiSocialPost>> getTreePosts(String treeId) async {
    final data = await apiClient.get('/trees/$treeId/posts');
    final raw = data is Map ? data['items'] as List? ?? const [] : data as List;
    final list = List<Map<String, dynamic>>.from(raw);
    return list.map(ApiSocialPost.fromJson).toList();
  }

  Future<dynamic> verifyTree(String treeId, {String? note}) async {
    return apiClient.post('/trees/$treeId/verify', body: {'note': note});
  }

  @Deprecated('Use the tree-analyses -> nearby -> trees workflow')
  Future<void> registerTree(TreeRegistrationPayload payload) async {
    throw StateError(
      'Legacy tree registration is disabled. Open the guided registration flow.',
    );
  }
}
