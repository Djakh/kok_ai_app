import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/features/auth/presentation/pages/login_page.dart';
import 'package:kok_ai_app/features/auth/presentation/pages/register_page.dart';
import 'package:kok_ai_app/features/community/presentation/pages/community_page.dart';
import 'package:kok_ai_app/features/map/presentation/pages/map_page.dart';
import 'package:kok_ai_app/features/home/presentation/pages/home_page.dart';
import 'package:kok_ai_app/features/achievements/presentation/pages/achievements_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/published_posts_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/profile_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/profile_liked_posts_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/profile_localization_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/top_guardians_page.dart';
import 'package:kok_ai_app/features/social/presentation/pages/social_page.dart';
import 'package:kok_ai_app/features/tree_list/presentation/pages/tree_list_page.dart';
import 'package:kok_ai_app/features/tree/presentation/pages/register_tree_camera_page.dart';
import 'package:kok_ai_app/features/tree/presentation/pages/register_tree_location_page.dart';
import 'package:kok_ai_app/features/tree/presentation/pages/register_tree_name_page.dart';
import 'package:kok_ai_app/features/tree/presentation/pages/tree_profile_page.dart';

const loginRoute = '/';
const registerRoute = '/register';

const dashboardRoute = '/app';
const mapRoute = '/app/map';
const socialRoute = '/app/social';
const profileRoute = '/app/profile';

const communityRoute = '/app/community';
const achievementsRoute = '/app/profile/achievements';
const topGuardiansRoute = '/app/profile/top-guardians';
const publishedPostsRoute = '/app/profile/published-posts';
const profileSettingsRoute = '/app/profile/settings';
const profileEditRoute = '/app/profile/settings/edit-profile';
const profileLikedPostsRoute = '/app/profile/settings/liked-posts';
const profileLocalizationRoute = '/app/profile/settings/localization';
const registerTreeCameraRoute = '/app/register-tree/camera';
const registerTreeLocationRoute = '/app/register-tree/location';
const registerTreeNameRoute = '/app/register-tree/name';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final dashboardNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'dashboard',
);
final mapNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'map');
final socialNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'social');
final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: loginRoute,
  routes: [
    GoRoute(path: loginRoute, builder: (context, state) => const LoginPage()),
    GoRoute(
      path: registerRoute,
      builder: (context, state) => const RegisterPage(),
    ),
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state, navigationShell) =>
          HomePage(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: dashboardNavigatorKey,
          routes: [
            GoRoute(
              path: dashboardRoute,
              builder: (context, state) => const SocialPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: mapNavigatorKey,
          routes: [
            GoRoute(
              path: mapRoute,
              builder: (context, state) => const MapPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: socialNavigatorKey,
          routes: [
            GoRoute(
              path: socialRoute,
              builder: (context, state) => const TreeListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: profileNavigatorKey,
          routes: [
            GoRoute(
              path: profileRoute,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: communityRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CommunityPage(),
    ),
    GoRoute(
      path: achievementsRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AchievementsPage(),
    ),
    GoRoute(
      path: topGuardiansRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const TopGuardiansPage(),
    ),
    GoRoute(
      path: publishedPostsRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const PublishedPostsPage(),
    ),
    GoRoute(
      path: profileSettingsRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ProfileSettingsPage(),
    ),
    GoRoute(
      path: profileEditRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ProfileEditPage(),
    ),
    GoRoute(
      path: profileLikedPostsRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ProfileLikedPostsPage(),
    ),
    GoRoute(
      path: profileLocalizationRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ProfileLocalizationPage(),
    ),
    GoRoute(
      path: registerTreeCameraRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const RegisterTreeCameraPage(),
    ),
    GoRoute(
      path: registerTreeLocationRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const RegisterTreeLocationPage(),
    ),
    GoRoute(
      path: registerTreeNameRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const RegisterTreeNamePage(),
    ),
    GoRoute(
      path: '/app/tree/:treeId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) =>
          TreeProfilePage(treeId: state.pathParameters['treeId'] ?? '1'),
    ),
  ],
);
