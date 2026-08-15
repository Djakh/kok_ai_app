import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';
import 'package:kok_ai_app/features/profile/data/services/profile_api_service.dart';
import 'package:kok_ai_app/features/social/data/models/api_social_post.dart';
import 'package:kok_ai_app/injection_container.dart';

class PublishedPostsPage extends StatefulWidget {
  const PublishedPostsPage({super.key});

  @override
  State<PublishedPostsPage> createState() => PublishedPostsPageState();
}

class PublishedPostsPageState extends State<PublishedPostsPage> {
  final profileApiService = sl<ProfileApiService>();

  late Future<List<ApiSocialPost>> postsFuture;

  /// --- Life cycle ---

  @override
  void initState() {
    super.initState();
    postsFuture = profileApiService.getMyPosts();
  }

  /// --- Methods ---

  void onReload() {
    setState(() {
      postsFuture = profileApiService.getMyPosts();
    });
  }

  String timeText(DateTime? value) {
    if (value == null) return '-';
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

  /// --- Widgets ---

  Widget header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
    child: Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(child: Text('Published Posts', style: Style.title20(context))),
      ],
    ),
  );

  Widget postCard(BuildContext context, ApiSocialPost item) => KokCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.feed_rounded,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.content, style: Style.body14(context)),
              const SizedBox(height: 2),
              Text(
                timeText(item.createdAt),
                style: Style.body12(context, color: AppColors.gray717171),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget body(BuildContext context) => FutureBuilder<List<ApiSocialPost>>(
    future: postsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(
          child: ElevatedButton(
            onPressed: onReload,
            child: const Text('Retry'),
          ),
        );
      }
      final posts = snapshot.data ?? const <ApiSocialPost>[];
      if (posts.isEmpty) {
        return Center(
          child: Text(
            'No posts yet',
            style: Style.body16(context, color: AppColors.gray717171),
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemBuilder: (context, index) => postCard(context, posts[index]),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: posts.length,
      );
    },
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: SafeArea(
      child: Column(
        children: [
          header(context),
          Expanded(child: body(context)),
        ],
      ),
    ),
  );
}
