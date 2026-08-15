class ApiSocialComment {
  const ApiSocialComment({
    required this.id,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String content;
  final DateTime? createdAt;

  factory ApiSocialComment.fromJson(Map<String, dynamic> json) =>
      ApiSocialComment(
        id: '${json['id'] ?? ''}',
        authorId: '${json['author_id'] ?? json['user_id'] ?? ''}',
        content: '${json['content'] ?? ''}',
        createdAt: DateTime.tryParse('${json['created_at']}'),
      );
}
