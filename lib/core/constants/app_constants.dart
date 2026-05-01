/// Uygulama genelinde kullanılan sabit değerler
class AppConstants {
  AppConstants._();

  // Uygulama bilgileri
  static const String appName = 'DownApp';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Pagination
  static const int defaultPageSize = 20;
  static const int searchPageSize = 15;
  static const int chatPageSize = 30;

  // File limits
  static const int maxApkSizeMB = 500;
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 50;
  static const int maxAvatarSizeMB = 5;

  // Story
  static const int storyDurationHours = 24;
  static const int storyViewDurationSeconds = 5;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 32;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int maxBioLength = 250;
  static const int maxCommentLength = 1000;
  static const int maxAppDescriptionLength = 5000;

  // Cache durations
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration userCacheDuration = Duration(minutes: 30);
  static const Duration appCacheDuration = Duration(minutes: 15);

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration typingDebounce = Duration(seconds: 2);

  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 250);
}
