class ProfileStats {
  const ProfileStats({
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.treesCount,
  });

  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int treesCount;

  factory ProfileStats.fromJson(Map<String, dynamic> json) => ProfileStats(
    followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
    followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
    postsCount: (json['posts_count'] as num?)?.toInt() ?? 0,
    treesCount: (json['trees_count'] as num?)?.toInt() ?? 0,
  );
}
