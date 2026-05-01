import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';

import 'package:downapp/features/admin/presentation/pages/admin_panel_page.dart';
import 'package:downapp/features/auth/presentation/pages/login_page.dart';
import 'package:downapp/features/auth/presentation/pages/register_page.dart';
import 'package:downapp/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:downapp/features/auth/presentation/pages/onboarding_page.dart';
import 'package:downapp/features/marketplace/presentation/pages/home_page.dart';
import 'package:downapp/features/marketplace/presentation/pages/category_page.dart';
import 'package:downapp/features/app_detail/presentation/pages/app_detail_page.dart';
import 'package:downapp/features/search/presentation/pages/search_page.dart';
import 'package:downapp/features/profile/presentation/pages/profile_page.dart';
import 'package:downapp/features/profile/presentation/pages/find_friends_page.dart';
import 'package:downapp/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:downapp/features/profile/presentation/pages/followers_page.dart';
import 'package:downapp/features/settings/presentation/pages/settings_page.dart';
import 'package:downapp/features/settings/presentation/pages/account_settings_page.dart';
import 'package:downapp/features/settings/presentation/pages/privacy_settings_page.dart';
import 'package:downapp/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:downapp/features/settings/presentation/pages/app_settings_page.dart';
import 'package:downapp/features/settings/presentation/pages/feedback_page.dart';
import 'package:downapp/features/chat/presentation/pages/chat_list_page.dart';
import 'package:downapp/features/chat/presentation/pages/chat_page.dart';
import 'package:downapp/features/stories/presentation/pages/create_story_page.dart';
import 'package:downapp/features/stories/presentation/pages/story_view_page.dart';
import 'package:downapp/features/notifications/presentation/pages/notifications_page.dart';
import 'package:downapp/features/developer/presentation/pages/developer_apply_page.dart';
import 'package:downapp/features/developer/presentation/pages/developer_panel_page.dart';
import 'package:downapp/features/developer/presentation/pages/upload_app_page.dart';
import 'package:downapp/features/download/presentation/pages/download_history_page.dart';
import 'package:downapp/features/social/presentation/pages/activity_feed_page.dart';
import 'package:downapp/features/legal/presentation/pages/terms_page.dart';
import 'package:downapp/features/legal/presentation/pages/privacy_policy_page.dart';
import 'package:downapp/features/report/presentation/pages/report_page.dart';
import 'package:downapp/features/main/presentation/pages/main_shell_page.dart';

/// Route isimleri
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main
  static const String home = '/';
  static const String category = '/category/:id';
  static const String appDetail = '/app/:id';
  static const String search = '/search';

  // Profile
  static const String profile = '/profile/:id';
  static const String myProfile = '/my-profile';
  static const String editProfile = '/edit-profile';
  static const String followers = '/followers/:id';
  static const String following = '/following/:id';
  static const String findFriends = '/find-friends';

  // Settings
  static const String settings = '/settings';
  static const String accountSettings = '/settings/account';
  static const String privacySettings = '/settings/privacy';
  static const String notificationSettings = '/settings/notifications';
  static const String appSettings = '/settings/app';
  static const String feedback = '/settings/feedback';

  // Chat
  static const String chatList = '/chats';
  static const String chat = '/chat/:id';

  // Story
  static const String createStory = '/create-story';
  static const String storyView = '/story/:userId';

  // Notifications
  static const String notifications = '/notifications';

  // Developer
  static const String developerApply = '/developer/apply';
  static const String developerPanel = '/developer/panel';
  static const String uploadApp = '/developer/upload';
  static const String editApp = '/developer/edit/:id';

  // Download
  static const String downloadHistory = '/downloads';

  // Social
  static const String activityFeed = '/activity';

  // Legal
  static const String terms = '/terms';
  static const String privacy = '/privacy';

  // Report
  static const String report = '/report';
  static const String adminPanel = '/admin-panel';
}

/// GoRouter provider tanımı
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (authState.status == AuthStatus.loading || authState.status == AuthStatus.initial) {
        return null; // Yüklenirken yönlendirme yapma
      }
      
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.onboarding;

      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.onboarding;
      }
      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      // ── Auth Routes ──────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (_, __) => const ForgotPasswordPage(),
      ),

      // ── Main Shell ───────────────────────────────
      ShellRoute(
        builder: (_, state, child) => MainShellPage(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.chatList,
            name: 'chatList',
            builder: (_, __) => const ChatListPage(),
          ),
          GoRoute(
            path: AppRoutes.myProfile,
            name: 'myProfile',
            builder: (_, __) => const ProfilePage(isMyProfile: true),
          ),
          GoRoute(
            path: AppRoutes.developerPanel,
            name: 'developerPanelShell',
            builder: (_, __) => const DeveloperPanelPage(),
          ),
        ],
      ),

      // ── Category ────────────────────────────────
      GoRoute(
        path: AppRoutes.category,
        name: 'category',
        builder: (_, state) => CategoryPage(
          categoryId: state.pathParameters['id']!,
        ),
      ),

      // ── App Detail ──────────────────────────────
      GoRoute(
        path: AppRoutes.appDetail,
        name: 'appDetail',
        builder: (_, state) => AppDetailPage(
          appId: state.pathParameters['id']!,
        ),
      ),

      // ── Search ──────────────────────────────────
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (_, __) => const SearchPage(),
      ),
      GoRoute(
        path: AppRoutes.findFriends,
        name: 'findFriends',
        builder: (_, __) => const FindFriendsPage(),
      ),

      // ── Profile ─────────────────────────────────
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (_, state) => ProfilePage(
          userId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (_, __) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.followers,
        name: 'followers',
        builder: (_, state) => FollowersPage(
          userId: state.pathParameters['id']!,
          isFollowers: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.following,
        name: 'following',
        builder: (_, state) => FollowersPage(
          userId: state.pathParameters['id']!,
          isFollowers: false,
        ),
      ),

      // ── Settings ────────────────────────────────
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (_, __) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.accountSettings,
        name: 'accountSettings',
        builder: (_, __) => const AccountSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.privacySettings,
        name: 'privacySettings',
        builder: (_, __) => const PrivacySettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        name: 'notificationSettings',
        builder: (_, __) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.appSettings,
        name: 'appSettings',
        builder: (_, __) => const AppSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.feedback,
        name: 'feedback',
        builder: (_, __) => const FeedbackPage(),
      ),

      // ── Chat ────────────────────────────────────
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (_, state) => ChatPage(
          chatId: state.pathParameters['id']!,
        ),
      ),

      // ── Story ───────────────────────────────────
      GoRoute(
        path: AppRoutes.createStory,
        name: 'createStory',
        builder: (_, __) => const CreateStoryPage(),
      ),
      GoRoute(
        path: AppRoutes.storyView,
        name: 'storyView',
        builder: (_, state) => StoryViewPage(
          userId: state.pathParameters['userId']!,
        ),
      ),

      // ── Notifications ───────────────────────────
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (_, __) => const NotificationsPage(),
      ),

      // ── Developer ───────────────────────────────
      GoRoute(
        path: AppRoutes.developerApply,
        name: 'developerApply',
        builder: (_, __) => const DeveloperApplyPage(),
      ),
      GoRoute(
        path: AppRoutes.uploadApp,
        name: 'uploadApp',
        builder: (_, __) => const UploadAppPage(),
      ),

      GoRoute(
        path: AppRoutes.adminPanel,
        name: 'adminPanel',
        builder: (_, __) => const AdminPanelPage(),
      ),

      // ── Download ────────────────────────────────
      GoRoute(
        path: AppRoutes.downloadHistory,
        name: 'downloadHistory',
        builder: (_, __) => const DownloadHistoryPage(),
      ),

      // ── Social ──────────────────────────────────
      GoRoute(
        path: AppRoutes.activityFeed,
        name: 'activityFeed',
        builder: (_, __) => const ActivityFeedPage(),
      ),

      // ── Legal ───────────────────────────────────
      GoRoute(
        path: AppRoutes.terms,
        name: 'terms',
        builder: (_, __) => const TermsPage(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        name: 'privacy',
        builder: (_, __) => const PrivacyPolicyPage(),
      ),

      // ── Report ──────────────────────────────────
      GoRoute(
        path: AppRoutes.report,
        name: 'report',
        builder: (_, state) => ReportPage(
          type: state.uri.queryParameters['type'] ?? '',
          targetId: state.uri.queryParameters['targetId'] ?? '',
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Sayfa bulunamadı: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
});
