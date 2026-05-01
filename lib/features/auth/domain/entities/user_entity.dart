import 'package:equatable/equatable.dart';

/// Kullanıcı temel varlığı (Domain Entity)
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String username;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final String coverUrl;
  final String website;
  final List<String> badges;
  final String role;
  final bool isDeveloper;
  final int followersCount;
  final int followingCount;
  final int appsCount;
  final bool isPrivate;
  final bool showLastSeen;
  final String allowMessages;
  final NotificationSettingsEntity notificationSettings;
  final UserPreferencesEntity preferences;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
    this.bio = '',
    this.avatarUrl = '',
    this.coverUrl = '',
    this.website = '',
    this.badges = const [],
    this.role = 'user',
    this.isDeveloper = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.appsCount = 0,
    this.isPrivate = false,
    this.showLastSeen = true,
    this.allowMessages = 'everyone',
    this.notificationSettings = const NotificationSettingsEntity(),
    this.preferences = const UserPreferencesEntity(),
    required this.createdAt,
  });

  UserEntity copyWith({
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
    String? website,
    bool? isPrivate,
    bool? showLastSeen,
    String? allowMessages,
    NotificationSettingsEntity? notificationSettings,
    UserPreferencesEntity? preferences,
  }) {
    return UserEntity(
      uid: uid,
      email: email,
      username: username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      website: website ?? this.website,
      badges: badges,
      role: role,
      isDeveloper: isDeveloper,
      followersCount: followersCount,
      followingCount: followingCount,
      appsCount: appsCount,
      isPrivate: isPrivate ?? this.isPrivate,
      showLastSeen: showLastSeen ?? this.showLastSeen,
      allowMessages: allowMessages ?? this.allowMessages,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
    );
  }

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [uid, email, username, isPrivate, showLastSeen, allowMessages];
}

class NotificationSettingsEntity extends Equatable {
  final bool messages;
  final bool comments;
  final bool follows;
  final bool updates;

  const NotificationSettingsEntity({
    this.messages = true,
    this.comments = true,
    this.follows = true,
    this.updates = true,
  });

  NotificationSettingsEntity copyWith({
    bool? messages, bool? comments, bool? follows, bool? updates,
  }) {
    return NotificationSettingsEntity(
      messages: messages ?? this.messages,
      comments: comments ?? this.comments,
      follows: follows ?? this.follows,
      updates: updates ?? this.updates,
    );
  }

  @override
  List<Object?> get props => [messages, comments, follows, updates];
}

class UserPreferencesEntity extends Equatable {
  final String theme;
  final String language;
  final bool dataSaver;

  const UserPreferencesEntity({
    this.theme = 'system',
    this.language = 'tr',
    this.dataSaver = false,
  });

  UserPreferencesEntity copyWith({String? theme, String? language, bool? dataSaver}) {
    return UserPreferencesEntity(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      dataSaver: dataSaver ?? this.dataSaver,
    );
  }

  @override
  List<Object?> get props => [theme, language, dataSaver];
}

