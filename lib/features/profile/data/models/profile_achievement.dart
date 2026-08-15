class ProfileAchievement {
  const ProfileAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.unlocked,
    this.icon,
    this.progress,
    this.target,
  });

  final String id;
  final String title;
  final String description;
  final bool unlocked;
  final String? icon;
  final int? progress;
  final int? target;

  factory ProfileAchievement.fromJson(Map<String, dynamic> json) {
    final unlockedAt = json['unlocked_at'];
    return ProfileAchievement(
      id: '${json['id'] ?? json['code'] ?? ''}',
      title: '${json['title'] ?? json['name'] ?? 'Achievement'}',
      description: '${json['description'] ?? ''}',
      unlocked:
          json['unlocked'] == true ||
          json['is_unlocked'] == true ||
          (unlockedAt != null && '$unlockedAt'.isNotEmpty),
      icon: json['icon'] as String? ?? json['emoji'] as String?,
      progress: (json['progress'] as num?)?.toInt(),
      target: (json['target'] as num?)?.toInt(),
    );
  }
}
