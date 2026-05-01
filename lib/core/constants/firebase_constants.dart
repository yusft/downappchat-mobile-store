/// Firestore collection ve storage path sabitleri
class FirebaseConstants {
  FirebaseConstants._();

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String appsCollection = 'apps';
  static const String categoriesCollection = 'categories';
  static const String chatsCollection = 'chats';
  static const String storiesCollection = 'stories';
  static const String notificationsCollection = 'notifications';
  static const String reportsCollection = 'reports';
  static const String favoritesCollection = 'favorites';
  static const String activitiesCollection = 'activities';
  static const String developerApplicationsCollection = 'developer_applications';
  static const String typingIndicatorsCollection = 'typing_indicators';
  static const String onlineStatusCollection = 'online_status';

  // Subcollections
  static const String followersSubcollection = 'followers';
  static const String followingSubcollection = 'following';
  static const String blockedSubcollection = 'blocked';
  static const String downloadHistorySubcollection = 'download_history';
  static const String versionsSubcollection = 'versions';
  static const String reviewsSubcollection = 'reviews';
  static const String repliesSubcollection = 'replies';
  static const String messagesSubcollection = 'messages';

  // Storage Paths
  static const String avatarsPath = 'avatars';
  static const String coversPath = 'covers';
  static const String appIconsPath = 'app_icons';
  static const String appScreenshotsPath = 'app_screenshots';
  static const String appBannersPath = 'app_banners';
  static const String apkFilesPath = 'apk_files';
  static const String obbFilesPath = 'obb_files';
  static const String chatMediaPath = 'chat_media';
  static const String storyMediaPath = 'story_media';
}
