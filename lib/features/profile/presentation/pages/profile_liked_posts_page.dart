import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';

class ProfileLikedPostsPage extends StatelessWidget {
  const ProfileLikedPostsPage({super.key});

  List<(String, String, String)> get likedPosts => const [
    (
      'Emma Davis',
      'Planted two young pines near the river park today 🌲',
      '18m ago',
    ),
    (
      'Mike Johnson',
      'Community cleanup complete and 12 trees watered 💧',
      '1h ago',
    ),
    (
      'Alex Brown',
      'Healthy check update for old oak on 9th street 🌳',
      '3h ago',
    ),
    (
      'Maria Garcia',
      'Joined new guardian challenge for this weekend 🏅',
      '5h ago',
    ),
    ('Green Team', 'Urban biodiversity report just published 📊', '1d ago'),
  ];

  /// --- Widgets ---

  Widget header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
    child: Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(child: Text('Liked Posts', style: Style.title20(context))),
      ],
    ),
  );

  Widget likedPostCard(BuildContext context, (String, String, String) post) =>
      KokCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.$1,
                    style: Style.body14(context, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(post.$2, style: Style.body14(context)),
                  const SizedBox(height: 4),
                  Text(
                    post.$3,
                    style: Style.body12(context, color: AppColors.gray717171),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: SafeArea(
      child: Column(
        children: [
          header(context),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemBuilder: (context, index) =>
                  likedPostCard(context, likedPosts[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: likedPosts.length,
            ),
          ),
        ],
      ),
    ),
  );
}
