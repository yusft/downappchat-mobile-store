import 'package:pocketbase/pocketbase.dart';
import 'package:equatable/equatable.dart';
import 'package:downapp/core/utils/url_utils.dart';

/// Kullanıcı veri modeli — PocketBase ile tam uyumlu
class UserModel extends Equatable {
  final String uid;
  final String email;
  final String username;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final String coverUrl;
  final String website;
  final Map<String, String> socialLinks;
  final List<String> badges;
  final bool isPrivate;
  final DateTime? lastSeen;
  final bool showLastSeen;
  final String allowMessages;
  final String role;
  final bool isDeveloper;
  final String developerStatus;
  final int followersCount;
  final int followingCount;
  final int appsCount;
  final String? fcmToken;
  final NotificationSettings notificationSettings;
  final UserPreferences preferences;
  final LegalConsent legalConsent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
    this.bio = '',
    this.avatarUrl = '',
    this.coverUrl = '',
    this.website = '',
    this.socialLinks = const {},
    this.badges = const [],
    this.isPrivate = false,
    this.lastSeen,
    this.showLastSeen = true,
    this.allowMessages = 'everyone',
    this.role = 'user',
    this.isDeveloper = false,
    this.developerStatus = 'none',
    this.followersCount = 0,
    this.followingCount = 0,
    this.appsCount = 0,
    this.fcmToken,
    this.notificationSettings = const NotificationSettings(),
    this.preferences = const UserPreferences(),
    this.legalConsent = const LegalConsent(),
    required this.createdAt,
    required this.updatedAt,
  });

  /// PocketBase'den oluştur
  factory UserModel.fromPocketBase(RecordModel record) {
    return UserModel(
      uid: record.id,
      email: record.getStringValue('email'),
      username: record.getStringValue('username'),
      displayName: record.getStringValue('displayName'),
      bio: record.getStringValue('bio'),
      website: record.getStringValue('website'),
      avatarUrl: UrlUtils.getUserAvatarUrl(record.id, record.getStringValue('avatar')),
      coverUrl: UrlUtils.getFileUrl(record.collectionId, record.id, record.getStringValue('cover')),
      isDeveloper: record.getBoolValue('isDeveloper'),
      developerStatus: record.getStringValue('developerStatus'),
      role: record.getStringValue('developerStatus') == 'admin' ? 'admin' : record.getStringValue('role', 'user'),
      followersCount: record.getIntValue('followersCount'),
      followingCount: record.getIntValue('followingCount'),
      appsCount: record.getIntValue('appsCount'),
      isPrivate: record.getBoolValue('isPrivate'),
      createdAt: DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(record.getStringValue('updated')) ?? DateTime.now(),
    );
  }

  /// copyWith
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
    String? website,
    Map<String, String>? socialLinks,
    List<String>? badges,
    bool? isPrivate,
    DateTime? lastSeen,
    bool? showLastSeen,
    String? allowMessages,
    String? role,
    bool? isDeveloper,
    String? developerStatus,
    int? followersCount,
    int? followingCount,
    int? appsCount,
    String? fcmToken,
    NotificationSettings? notificationSettings,
    UserPreferences? preferences,
    LegalConsent? legalConsent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      website: website ?? this.website,
      socialLinks: socialLinks ?? this.socialLinks,
      badges: badges ?? this.badges,
      isPrivate: isPrivate ?? this.isPrivate,
      lastSeen: lastSeen ?? this.lastSeen,
      showLastSeen: showLastSeen ?? this.showLastSeen,
      allowMessages: allowMessages ?? this.allowMessages,
      role: role ?? this.role,
      isDeveloper: isDeveloper ?? this.isDeveloper,
      developerStatus: developerStatus ?? this.developerStatus,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      appsCount: appsCount ?? this.appsCount,
      fcmToken: fcmToken ?? this.fcmToken,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      preferences: preferences ?? this.preferences,
      legalConsent: legalConsent ?? this.legalConsent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [uid, email, username, updatedAt];
}

/// Bildirim ayarları alt modeli
class NotificationSettings extends Equatable {
  final bool messages;
  final bool comments;
  final bool follows;
  final bool updates;

  const NotificationSettings({
    this.messages = true,
    this.comments = true,
    this.follows = true,
    this.updates = true,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      messages: map['messages'] ?? true,
      comments: map['comments'] ?? true,
      follows: map['follows'] ?? true,
      updates: map['updates'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'messages': messages,
    'comments': comments,
    'follows': follows,
    'updates': updates,
  };

  NotificationSettings copyWith({
    bool? messages, bool? comments, bool? follows, bool? updates,
  }) {
    return NotificationSettings(
      messages: messages ?? this.messages,
      comments: comments ?? this.comments,
      follows: follows ?? this.follows,
      updates: updates ?? this.updates,
    );
  }

  @override
  List<Object?> get props => [messages, comments, follows, updates];
}

/// Kullanıcı tercihleri alt modeli
class UserPreferences extends Equatable {
  final String theme;
  final String language;
  final bool dataSaver;

  const UserPreferences({
    this.theme = 'system',
    this.language = 'tr',
    this.dataSaver = false,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      theme: map['theme'] ?? 'system',
      language: map['language'] ?? 'tr',
      dataSaver: map['dataSaver'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'theme': theme,
    'language': language,
    'dataSaver': dataSaver,
  };

  UserPreferences copyWith({String? theme, String? language, bool? dataSaver}) {
    return UserPreferences(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      dataSaver: dataSaver ?? this.dataSaver,
    );
  }

  @override
  List<Object?> get props => [theme, language, dataSaver];
}

/// Yasal onay alt modeli
class LegalConsent extends Equatable {
  final bool termsAccepted;
  final DateTime? termsAcceptedAt;
  final bool privacyAccepted;
  final bool cookiesAccepted;

  const LegalConsent({
    this.termsAccepted = false,
    this.termsAcceptedAt,
    this.privacyAccepted = false,
    this.cookiesAccepted = false,
  });

  factory LegalConsent.fromMap(Map<String, dynamic> map) {
    return LegalConsent(
      termsAccepted: map['termsAccepted'] ?? false,
      termsAcceptedAt: map['termsAcceptedAt'] != null 
          ? DateTime.tryParse(map['termsAcceptedAt'].toString()) 
          : null,
      privacyAccepted: map['privacyAccepted'] ?? false,
      cookiesAccepted: map['cookiesAccepted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'termsAccepted': termsAccepted,
    'termsAcceptedAt': termsAcceptedAt?.toIso8601String(),
    'privacyAccepted': privacyAccepted,
    'cookiesAccepted': cookiesAccepted,
  };

  @override
  List<Object?> get props => [termsAccepted, privacyAccepted, cookiesAccepted];
}
