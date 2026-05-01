import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  /// Kullanıcı profilini getir
  Future<Either<Failure, UserEntity>> getProfile(String userId);

  /// Profil bilgilerini güncelle
  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? website,
    Map<String, String>? socialLinks,
    bool? isPrivate,
    bool? showLastSeen,
    String? allowMessages,
    NotificationSettingsEntity? notificationSettings,
    UserPreferencesEntity? preferences,
  });

  /// Arkadaşlık isteği gönder
  Future<Either<Failure, Unit>> sendFollowRequest({
    required String currentUserId,
    required String targetUserId,
  });

  /// Arkadaşlıktan çıkar / Takibi bırak
  Future<Either<Failure, Unit>> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Takip isteğine yanıt ver (kullanıcının isteğini kabul et/reddet)
  Future<Either<Failure, Unit>> respondToFollowRequest({
    required String followId,
    required String currentUserId,
    required String targetUserId,
    required bool accept,
  });

  /// Takipçi listesini getir
  Future<Either<Failure, List<UserEntity>>> getFollowers(String userId);

  /// Takip edilenler listesini getir
  Future<Either<Failure, List<UserEntity>>> getFollowing(String userId);

  /// Profil fotoğrafı yükle
  Future<Either<Failure, String>> uploadAvatar({required String userId, required File file});

  /// Kapak fotoğrafı yükle
  Future<Either<Failure, String>> uploadCover({required String userId, required File file});
}

