class UploadedAsset {
  const UploadedAsset({
    required this.id,
    required this.url,
    required this.contentType,
    required this.fileName,
    required this.fileSize,
    required this.createdAt,
  });

  final String id;
  final String url;
  final String contentType;
  final String fileName;
  final int fileSize;
  final DateTime createdAt;

  factory UploadedAsset.fromJson(Map<String, dynamic> json) => UploadedAsset(
    id: '${json['id']}',
    url: '${json['url']}',
    contentType: '${json['content_type']}',
    fileName: '${json['file_name']}',
    fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
    createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
  );
}
