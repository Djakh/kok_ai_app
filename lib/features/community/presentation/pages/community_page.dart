import 'package:flutter/material.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_tab_switcher.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => CommunityPageState();
}

class CommunityPageState extends State<CommunityPage> {
  int tabIndex = 0;
  List<int> likedIds = [];

  final posts = const [
    (
      'Maria Garcia',
      '🌟',
      'registered a new tree',
      'Central Park',
      '2 hours ago',
      24,
      5,
      'Maple Guardian',
      '🍁',
    ),
    (
      'John Smith',
      '🌲',
      'completed the Weekly Challenge',
      '',
      '5 hours ago',
      42,
      8,
      '',
      '🏆',
    ),
    (
      'Emma Wilson',
      '🌳',
      'registered 3 trees today',
      'Riverside Park',
      '8 hours ago',
      36,
      12,
      '',
      '',
    ),
    (
      'Alex Chen',
      '🍃',
      'reached Guardian Level 5',
      '',
      '1 day ago',
      58,
      15,
      '',
      '⭐',
    ),
  ];

  final challenges = const [
    (
      'Weekly Tree Hunter',
      'Register 10 trees this week',
      6,
      10,
      200,
      '🎯',
      1234,
    ),
    (
      'Species Explorer',
      'Find and register 5 different tree species',
      3,
      5,
      150,
      '🔍',
      856,
    ),
    (
      'Community Champion',
      'Help verify 20 tree reports',
      12,
      20,
      100,
      '🤝',
      645,
    ),
  ];

  final leaderboard = const [
    (1, 'Sarah Chen', 156, 8450, '🌟', true, false),
    (2, 'Mike Johnson', 142, 7890, '🌲', true, false),
    (3, 'Emma Davis', 128, 6950, '🌳', false, false),
    (4, 'You', 58, 1240, '🍃', true, true),
    (5, 'Alex Brown', 52, 1180, '🌿', true, false),
  ];

  /// --- Methods ---

  void onToggleLike(int index) {
    setState(() {
      if (likedIds.contains(index)) {
        likedIds = likedIds.where((item) => item != index).toList();
      } else {
        likedIds = [...likedIds, index];
      }
    });
  }

  /// --- Widgets ---

  Widget header() => Container(
    padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.brightLeafGreen],
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community',
          style: Style.headline32(context, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          'Connect with fellow tree guardians',
          style: Style.body16(
            context,
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
      ],
    ),
  );

  Widget feedTab() => Column(
    children: List.generate(posts.length, (index) {
      final post = posts[index];
      final liked = likedIds.contains(index);

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: KokCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.brightLeafGreen],
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(post.$2, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 4,
                          children: [
                            Text(
                              post.$1,
                              style: Style.body14(
                                context,
                                weight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              post.$3,
                              style: Style.body14(
                                context,
                                color: AppColors.gray717171,
                              ),
                            ),
                          ],
                        ),
                        if (post.$4.isNotEmpty)
                          Text(
                            '📍 ${post.$4}',
                            style: Style.body12(
                              context,
                              color: AppColors.gray717171,
                            ),
                          ),
                        Text(
                          post.$5,
                          style: Style.body12(
                            context,
                            color: AppColors.gray717171,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.$9.isNotEmpty)
                    Text(post.$9, style: const TextStyle(fontSize: 28)),
                ],
              ),
              if (post.$8.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF5F5F5), Color(0xFFE8F5E9)],
                    ),
                    borderRadius: Style.border12,
                  ),
                  child: Row(
                    children: [
                      Text(post.$9, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.$8,
                            style: Style.body14(
                              context,
                              weight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'New tree registered',
                            style: Style.body12(
                              context,
                              color: AppColors.gray717171,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              const Divider(color: AppColors.grayE8E8E8, height: 1),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => onToggleLike(index),
                    icon: Icon(
                      liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: liked ? AppColors.primary : AppColors.gray717171,
                      size: 18,
                    ),
                    label: Text(
                      '${post.$6 + (liked ? 1 : 0)}',
                      style: Style.body12(
                        context,
                        color: liked ? AppColors.primary : AppColors.gray717171,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.gray717171,
                      size: 18,
                    ),
                    label: Text(
                      '${post.$7}',
                      style: Style.body12(context, color: AppColors.gray717171),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }),
  );

  Widget challengesTab() => Column(
    children: challenges
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: KokCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.brightLeafGreen],
                      ),
                      borderRadius: Style.border16,
                    ),
                    alignment: Alignment.center,
                    child: Text(item.$6, style: const TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.$1,
                                style: Style.body16(
                                  context,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warmEarthBrown,
                                borderRadius: Style.border12,
                              ),
                              child: Text(
                                '+${item.$5} 🪙',
                                style: Style.body12(
                                  context,
                                  color: Colors.white,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          item.$2,
                          style: Style.body12(
                            context,
                            color: AppColors.gray717171,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Progress',
                              style: Style.body12(
                                context,
                                color: AppColors.gray717171,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${item.$3}/${item.$4}',
                              style: Style.body12(
                                context,
                                color: AppColors.primary,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: item.$3 / item.$4,
                            minHeight: 10,
                            backgroundColor: AppColors.neutralLight,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '🔥 ${item.$7} participants',
                          style: Style.body12(
                            context,
                            color: AppColors.gray717171,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList(),
  );

  Widget leaderboardTab() => Column(
    children: leaderboard
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: KokCard(
              color: item.$7 ? const Color(0x1A4CAF6D) : Colors.white,
              child: Row(
                children: [
                  Text(
                    '#${item.$1}',
                    style: Style.title20(
                      context,
                      color: item.$1 == 1
                          ? const Color(0xFFFFD700)
                          : AppColors.gray717171,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.warmEarthBrown,
                          AppColors.lightEarthBrown,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(item.$5, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.$2,
                              style: Style.body14(
                                context,
                                color: item.$7
                                    ? AppColors.primary
                                    : AppColors.secondary,
                                weight: FontWeight.w700,
                              ),
                            ),
                            if (item.$7)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: Style.border8,
                                ),
                                child: Text(
                                  'You',
                                  style: Style.body12(
                                    context,
                                    color: Colors.white,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '🌳 ${item.$3} trees   🪙 ${item.$4}',
                          style: Style.body12(
                            context,
                            color: AppColors.gray717171,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    item.$6
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 14,
                    color: item.$6
                        ? AppColors.primary
                        : AppColors.warmEarthBrown,
                  ),
                ],
              ),
            ),
          ),
        )
        .toList(),
  );

  Widget contentByTab() {
    if (tabIndex == 0) return feedTab();
    if (tabIndex == 1) return challengesTab();
    return leaderboardTab();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 92),
              children: [
                KokTabSwitcher(
                  tabs: const ['Feed', 'Challenges', 'Leaderboard'],
                  currentIndex: tabIndex,
                  onChanged: (index) => setState(() => tabIndex = index),
                ),
                const SizedBox(height: 14),
                contentByTab(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
