import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kok_ai_app/assets/themes/app_colors.dart';
import 'package:kok_ai_app/assets/themes/style.dart';
import 'package:kok_ai_app/features/social/data/models/social_post_payload.dart';
import 'package:kok_ai_app/features/social/data/services/social_api_service.dart';
import 'package:kok_ai_app/features/social/data/services/social_post_draft_store.dart';
import 'package:kok_ai_app/features/common/presentation/widgets/kok_card.dart';
import 'package:kok_ai_app/injection_container.dart';

class SocialPostComment {
  const SocialPostComment({
    required this.user,
    required this.avatar,
    required this.text,
    required this.time,
  });

  final String user;
  final String avatar;
  final String text;
  final String time;
}

class SocialPost {
  const SocialPost({
    required this.id,
    required this.user,
    required this.avatar,
    required this.title,
    required this.time,
    required this.content,
    this.image,
    this.treeName,
    this.treeLocation,
    required this.likes,
    required this.comments,
  });

  final int id;
  final String user;
  final String avatar;
  final String title;
  final String time;
  final String content;
  final String? image;
  final String? treeName;
  final String? treeLocation;
  final int likes;
  final List<SocialPostComment> comments;

  SocialPost copyWith({int? likes, List<SocialPostComment>? comments}) =>
      SocialPost(
        id: id,
        user: user,
        avatar: avatar,
        title: title,
        time: time,
        content: content,
        image: image,
        treeName: treeName,
        treeLocation: treeLocation,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
      );
}

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => SocialPageState();
}

class SocialPageState extends State<SocialPage> {
  final newPostController = TextEditingController();
  final commentControllerMap = <int, TextEditingController>{};
  final imagePicker = ImagePicker();
  final postDraftStore = sl<SocialPostDraftStore>();
  final socialApiService = sl<SocialApiService>();

  bool showCreatePostSheet = false;
  bool isCreatingPost = false;
  String? draftImagePath;
  Position? draftPosition;
  SocialPostPayload? preparedPostPayload;

  List<int> likedPostIds = [];
  List<int> expandedPostIds = [];

  List<SocialPost> posts = [
    SocialPost(
      id: 1,
      user: 'Maria Garcia',
      avatar: '🌟',
      title: 'Tree Guardian • Level 4',
      time: '2 hours ago',
      content:
          'Just registered my 50th tree! 🎉 Found this beautiful oak in Central Park. This app has changed how I see my city! #TreeGuardian #UrbanForest',
      image: 'oak',
      treeName: 'Grand Oak',
      treeLocation: 'Central Park, NY',
      likes: 42,
      comments: [
        const SocialPostComment(
          user: 'John Smith',
          avatar: '🌲',
          text: 'Congratulations Maria! 🌳',
          time: '1 hour ago',
        ),
        const SocialPostComment(
          user: 'Emma Wilson',
          avatar: '🌳',
          text: 'Beautiful tree, I will look for it!',
          time: '45 min ago',
        ),
      ],
    ),
    SocialPost(
      id: 2,
      user: 'Alex Chen',
      avatar: '🍃',
      title: 'Environmental Advocate',
      time: '5 hours ago',
      content:
          'Completed the weekly challenge! Registered 10 trees across 3 neighborhoods. Let\'s keep our cities green! 🌿',
      likes: 67,
      comments: const [
        SocialPostComment(
          user: 'Sarah Chen',
          avatar: '🌟',
          text: 'Amazing work Alex!',
          time: '4 hours ago',
        ),
      ],
    ),
    SocialPost(
      id: 3,
      user: 'Sarah Chen',
      avatar: '🌟',
      title: 'Top Guardian • Level 5',
      time: '1 day ago',
      content:
          'Organized a community tree walk this weekend. 15 people joined and we registered 23 new trees together! 🚶‍♀️🌳',
      image: 'community',
      likes: 89,
      comments: const [
        SocialPostComment(
          user: 'Mike Johnson',
          avatar: '🌲',
          text: 'Count me in next week!',
          time: '1 day ago',
        ),
        SocialPostComment(
          user: 'Emma Davis',
          avatar: '🌿',
          text: 'I\'d love to join too 🙋‍♀️',
          time: '20 hours ago',
        ),
      ],
    ),
  ];

  /// --- Life cycle ---

  @override
  void dispose() {
    newPostController.dispose();
    for (final item in commentControllerMap.values) {
      item.dispose();
    }
    super.dispose();
  }

  /// --- Methods ---

  TextEditingController commentController(int postId) {
    final current = commentControllerMap[postId];
    if (current != null) return current;

    final created = TextEditingController();
    commentControllerMap[postId] = created;
    return created;
  }

  void onToggleLike(int postId) {
    final exists = likedPostIds.contains(postId);
    setState(() {
      if (exists) {
        likedPostIds = likedPostIds.where((item) => item != postId).toList();
      } else {
        likedPostIds = [...likedPostIds, postId];
      }
    });
  }

  void onToggleComments(int postId) {
    final exists = expandedPostIds.contains(postId);
    setState(() {
      if (exists) {
        expandedPostIds = expandedPostIds
            .where((item) => item != postId)
            .toList();
      } else {
        expandedPostIds = [...expandedPostIds, postId];
      }
    });
  }

  void onAddComment(int postId) {
    final controller = commentController(postId);
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      posts = posts
          .map(
            (post) => post.id == postId
                ? post.copyWith(
                    comments: [
                      ...post.comments,
                      SocialPostComment(
                        user: 'You',
                        avatar: '🍃',
                        text: text,
                        time: 'Just now',
                      ),
                    ],
                  )
                : post,
          )
          .toList();
      controller.clear();
    });
  }

  Future<void> onPickPostImage() async {
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 86,
    );
    if (image == null) return;
    setState(() => draftImagePath = image.path);
  }

  Future<void> captureDraftLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final location = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
    setState(() => draftPosition = location);
  }

  Future<void> onCreatePost() async {
    if (isCreatingPost) return;

    final text = newPostController.text.trim();
    if (text.isEmpty) return;

    setState(() => isCreatingPost = true);

    await captureDraftLocation();

    preparedPostPayload = postDraftStore.preparePayload(
      content: text,
      imagePath: draftImagePath,
      latitude: draftPosition?.latitude,
      longitude: draftPosition?.longitude,
    );

    final newPost = SocialPost(
      id: posts.length + 1,
      user: 'You',
      avatar: '🍃',
      title: 'Tree Guardian',
      time: 'Just now',
      content: text,
      image: draftImagePath,
      treeLocation: draftPosition == null
          ? null
          : '${draftPosition!.latitude.toStringAsFixed(6)}, ${draftPosition!.longitude.toStringAsFixed(6)}',
      likes: 0,
      comments: const [],
    );

    try {
      await socialApiService.createPost(preparedPostPayload!);
      if (!mounted) return;

      setState(() {
        posts = [newPost, ...posts];
        newPostController.clear();
        draftImagePath = null;
        draftPosition = null;
        showCreatePostSheet = false;
        isCreatingPost = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('social_payload_ready'.tr())));
    } catch (error) {
      if (!mounted) return;
      setState(() => isCreatingPost = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  /// --- Widgets ---

  Widget header() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
    child: Row(
      children: [
        Expanded(
          child: Text('social_title'.tr(), style: Style.headline24(context)),
        ),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: () => setState(() => showCreatePostSheet = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: Style.border12),
              elevation: 0,
            ),
            child: Text(
              'social_create_post'.tr(),
              style: Style.body14(
                context,
                color: Colors.white,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget createPostSheet() => Positioned.fill(
    child: Material(
      color: Colors.black.withValues(alpha: 0.35),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'social_create_post_sheet_title'.tr(),
                      style: Style.title20(context),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => showCreatePostSheet = false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  avatarCircle('🍃', [
                    AppColors.primary,
                    AppColors.brightLeafGreen,
                  ]),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You',
                        style: Style.body14(context, weight: FontWeight.w700),
                      ),
                      Text(
                        'Tree Guardian',
                        style: Style.body12(
                          context,
                          color: AppColors.gray717171,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPostController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'social_post_hint'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: Style.border12,
                    borderSide: const BorderSide(color: AppColors.grayE8E8E8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: Style.border12,
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              if (draftImagePath != null) ...[
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: Style.border12,
                        gradient: const LinearGradient(
                          colors: [Color(0x334CAF6D), Color(0x336BCB77)],
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      alignment: Alignment.center,
                      child: Image.file(
                        File(draftImagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: GestureDetector(
                        onTap: () => setState(() => draftImagePath = null),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (draftPosition != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Location: ${draftPosition!.latitude.toStringAsFixed(6)}, ${draftPosition!.longitude.toStringAsFixed(6)}',
                    style: Style.body12(context, color: AppColors.gray717171),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: isCreatingPost ? null : onPickPostImage,
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: Text(
                      'social_add_photo'.tr(),
                      style: Style.body14(context),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: isCreatingPost ? null : () => onCreatePost(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: Style.border12,
                      ),
                      elevation: 0,
                    ),
                    child: isCreatingPost
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'social_post_button'.tr(),
                            style: Style.body14(
                              context,
                              color: Colors.white,
                              weight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget avatarCircle(String emoji, List<Color> colors) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors),
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text(emoji, style: const TextStyle(fontSize: 22)),
  );

  Widget postCard(SocialPost post) {
    final isLiked = likedPostIds.contains(post.id);
    final isExpanded = expandedPostIds.contains(post.id);
    final controller = commentController(post.id);

    return KokCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    avatarCircle(post.avatar, const [
                      AppColors.warmEarthBrown,
                      AppColors.lightEarthBrown,
                    ]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.user,
                            style: Style.body14(
                              context,
                              weight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            post.title,
                            style: Style.body12(
                              context,
                              color: AppColors.gray717171,
                            ),
                          ),
                          Text(
                            post.time,
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
                const SizedBox(height: 12),
                Text(post.content, style: Style.body14(context)),
              ],
            ),
          ),
          if (post.image != null)
            Container(
              height: 190,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFF5F5DC)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: post.image != null && File(post.image!).existsSync()
                        ? Image.file(File(post.image!), fit: BoxFit.cover)
                        : const Center(
                            child: Icon(
                              Icons.park_rounded,
                              color: AppColors.primary,
                              size: 72,
                            ),
                          ),
                  ),
                  if (post.treeName != null)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: Style.border12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.park_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.treeName!,
                                    style: Style.body14(
                                      context,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    post.treeLocation ?? '',
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
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '${post.likes + (isLiked ? 1 : 0)} likes',
                      style: Style.body12(context, color: AppColors.gray717171),
                    ),
                    const Spacer(),
                    Text(
                      '${post.comments.length} comments',
                      style: Style.body12(context, color: AppColors.gray717171),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: AppColors.grayE8E8E8, height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    actionTextButton(
                      icon: isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      label: 'Like',
                      color: isLiked ? AppColors.primary : AppColors.gray717171,
                      onTap: () => onToggleLike(post.id),
                    ),
                    actionTextButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Comment',
                      color: AppColors.gray717171,
                      onTap: () => onToggleComments(post.id),
                    ),
                    actionTextButton(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      color: AppColors.gray717171,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              color: AppColors.neutralLight,
              child: Column(
                children: [
                  for (final item in post.comments)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          avatarCircle(item.avatar, const [
                            AppColors.brightLeafGreen,
                            AppColors.primary,
                          ]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: Style.border16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.user,
                                        style: Style.body12(
                                          context,
                                          weight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        item.text,
                                        style: Style.body14(context),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    top: 4,
                                  ),
                                  child: Text(
                                    item.time,
                                    style: Style.body12(
                                      context,
                                      color: AppColors.gray717171,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      avatarCircle('🍃', const [
                        AppColors.primary,
                        AppColors.brightLeafGreen,
                      ]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onSubmitted: (value) => onAddComment(post.id),
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: AppColors.grayE8E8E8,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => onAddComment(post.id),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget actionTextButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) => Expanded(
    child: TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 18),
      label: Text(label, style: TextStyle(color: color)),
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.neutralLight,
    body: SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            children: [
              header(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
                  itemBuilder: (context, index) => postCard(posts[index]),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: posts.length,
                ),
              ),
            ],
          ),
          if (showCreatePostSheet) createPostSheet(),
        ],
      ),
    ),
  );
}
