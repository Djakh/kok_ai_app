import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';

class PublishedPostsPage extends StatelessWidget {
  const PublishedPostsPage({super.key});

  List<(String, String)> get posts => const [
    ('Registered a new maple in Central Park 🌳', '2 hours ago'),
    ('Completed weekly challenge with 10 trees', '1 day ago'),
    ('Joined community cleanup and tree walk', '3 days ago'),
    ('Shared healthy status update for Grand Oak', '6 days ago'),
    ('Posted weekly impact summary', '1 week ago'),
  ];

  Widget header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
    child: Row(
      children: [
        IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
        Expanded(child: Text('Published Posts', style: Style.title20(context))),
      ],
    ),
  );

  Widget postCard(BuildContext context, (String, String) item) => KokCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(Icons.feed_rounded, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.$1, style: Style.body14(context)),
              const SizedBox(height: 2),
              Text(item.$2, style: Style.body12(context, color: AppColors.gray717171)),
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
              itemBuilder: (context, index) => postCard(context, posts[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: posts.length,
            ),
          ),
        ],
      ),
    ),
  );
}
