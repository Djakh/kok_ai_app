class SocialPostResult {
  const SocialPostResult({required this.postId});

  final String postId;

  factory SocialPostResult.fromJson(Map<String, dynamic> json) =>
      SocialPostResult(postId: '${json['id'] ?? json['post_id'] ?? ''}');
}
