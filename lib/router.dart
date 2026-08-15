import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';
import 'package:kok_ai_app/core/widgets/app_state_page.dart';
import 'package:kok_ai_app/features/auth/presentation/pages/login_page.dart';
import 'package:kok_ai_app/features/auth/presentation/pages/register_page.dart';
import 'package:kok_ai_app/features/social/presentation/pages/social_page.dart';
import 'package:kok_ai_app/features/map/presentation/pages/map_page.dart';
import 'package:kok_ai_app/features/home/presentation/pages/home_page.dart';
import 'package:kok_ai_app/features/home/presentation/pages/home_dashboard_page.dart';
import 'package:kok_ai_app/features/achievements/presentation/pages/achievements_page.dart';
import 'package:kok_ai_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/published_posts_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/profile_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/profile_liked_posts_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/profile_localization_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/backend_status_page.dart';
import 'package:kok_ai_app/features/profile/presentation/pages/top_guardians_page.dart';
import 'package:kok_ai_app/features/tree_list/presentation/pages/tree_list_page.dart';
import 'package:kok_ai_app/features/tree/presentation/pages/tree_profile_page.dart';
import 'package:kok_ai_app/features/tree_registration/presentation/pages/tree_registration_page.dart';
import 'package:kok_ai_app/features/user/presentation/pages/user_connections_page.dart';
import 'package:kok_ai_app/injection_container.dart';

const loginRoute = '/';
const registerRoute = '/register';

const dashboardRoute = '/app';
const mapRoute = '/app/map';
const socialRoute = '/app/social';
const treesRoute = '/app/trees';
const profileRoute = '/app/profile';

const communityRoute = '/app/community';
const achievementsRoute = '/app/profile/achievements';
const topGuardiansRoute = '/app/profile/top-guardians';
const publishedPostsRoute = '/app/profile/published-posts';
const profileSettingsRoute = '/app/profile/settings';
const profileEditRoute = '/app/profile/settings/edit-profile';
const profileLikedPostsRoute = '/app/profile/settings/liked-posts';
const profileLocalizationRoute = '/app/profile/settings/localization';
const backendStatusRoute = '/app/profile/settings/backend-status';
const notificationsRoute = '/app/notifications';
const profileConnectionsRoute = '/app/profile/connections';
const registerTreeCameraRoute = '/app/register-tree/camera';
const registerTreeLocationRoute = '/app/register-tree/location';
const registerTreeNameRoute = '/app/register-tree/name';
const registerTreeRoute = '/app/register-tree';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final dashboardNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'dashboard',
);
final mapNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'map');
final socialNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'social');
final profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

Future<bool> readHasAuthenticatedSession() async {
  final tokenStore = sl<AuthTokenStore>();
  try {
    return await tokenStore.hasSession();
  } on AuthStorageUnavailableException catch (error) {
    debugPrint('[ROUTER] $error Continuing as a signed-out user.');
    return false;
  }
}

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: loginRoute,
  errorBuilder: (context, state) => AppErrorPage(
    icon: Icons.explore_off_rounded,
    title: 'We could not open this page',
    message:
        'The destination may no longer exist, or the app could not finish checking access. Return to the start and try again.',
    primaryLabel: 'Return to start',
    onPrimary: () => context.go(loginRoute),
  ),
  redirect: (context, state) async {
    final hasAuthenticatedSession = await readHasAuthenticatedSession();
    final isAuthRoute =
        state.matchedLocation == loginRoute ||
        state.matchedLocation == registerRoute;
    if (!hasAuthenticatedSession && !isAuthRoute) return loginRoute;
    if (hasAuthenticatedSession && isAuthRoute) return dashboardRoute;
    return null;
  },
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
              builder: (context, state) => const HomeDashboardPage(),
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
              path: treesRoute,
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
      builder: (context, state) => const SocialPage(),
    ),
    GoRoute(
      path: socialRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SocialPage(),
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
      path: backendStatusRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const BackendStatusPage(),
    ),
    GoRoute(
      path: notificationsRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '$profileConnectionsRoute/:kind/:userId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => UserConnectionsPage(
        userId: state.pathParameters['userId'] ?? '',
        showFollowers: state.pathParameters['kind'] == 'followers',
      ),
    ),
    GoRoute(
      path: registerTreeRoute,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const TreeRegistrationPage(),
    ),
    GoRoute(
      path: registerTreeCameraRoute,
      parentNavigatorKey: rootNavigatorKey,
      redirect: (context, state) => registerTreeRoute,
    ),
    GoRoute(
      path: registerTreeLocationRoute,
      parentNavigatorKey: rootNavigatorKey,
      redirect: (context, state) => registerTreeRoute,
    ),
    GoRoute(
      path: registerTreeNameRoute,
      parentNavigatorKey: rootNavigatorKey,
      redirect: (context, state) => registerTreeRoute,
    ),
    GoRoute(
      path: '/app/tree/:treeId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) =>
          TreeProfilePage(treeId: state.pathParameters['treeId'] ?? '1'),
    ),
  ],
);
