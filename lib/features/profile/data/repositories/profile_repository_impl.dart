import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/core/network/network_info.dart';
import 'package:downapp/features/auth/domain/entities/user_entity.dart';
import 'package:downapp/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:downapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:downapp/core/errors/exceptions.dart';
import 'package:downapp/features/auth/data/models/user_model.dart'; // Import models for mapping

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ProfileRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, UserEntity>> getProfile(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.getProfile(userId);
        return Right(_mapToEntity(model));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
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
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.updateProfile(
          userId: userId,
          displayName: displayName,
          bio: bio,
          website: website,
          socialLinks: socialLinks,
          isPrivate: isPrivate,
          showLastSeen: showLastSeen,
          allowMessages: allowMessages,
          notificationSettings: notificationSettings != null 
              ? NotificationSettings(
                  messages: notificationSettings.messages,
                  comments: notificationSettings.comments,
                  follows: notificationSettings.follows,
                  updates: notificationSettings.updates,
                )
              : null,
          preferences: preferences != null
              ? UserPreferences(
                  theme: preferences.theme,
                  language: preferences.language,
                  dataSaver: preferences.dataSaver,
                )
              : null,
        );
        return Right(_mapToEntity(model));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, Unit>> respondToFollowRequest({
    required String followId,
    required String currentUserId,
    required String targetUserId,
    required bool accept,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.respondToFollowRequest(
          followId: followId,
          accept: accept,
          currentUserId: currentUserId,
          targetUserId: targetUserId,
        );
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  // Eski toggleFollow metodunu toggle islevelligi icin respondToFollow ile uyumlu hale getiriyoruz veya siliyoruz.
  // Interface'den kalktigi icin silmek en iyisi. Ancak followUser cagrisi icin lazim olabilir.
  // Aslinda followUser direkt toggle degil, "istek gonder" oldu.
  // toggleFollow'u interface'e geri eklemeyecegiz simdi, respond ile devam edecegiz.
  // Ancak followUser'i cagiran bir yer lazim.
  // toggleFollow'un goresi aslında followUser'ı baslatmaktı.
  // Onu yeniden isimlendirelim veya respond icinde degil baska bir yerde tutalım.

  @override
  Future<Either<Failure, Unit>> sendFollowRequest({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.followUser(
          currentUserId: currentUserId,
          targetUserId: targetUserId,
        );
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, Unit>> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.unfollowUser(
          currentUserId: currentUserId,
          targetUserId: targetUserId,
        );
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getFollowers(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getFollowers(userId);
        return Right(models.map(_mapToEntity).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getFollowing(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getFollowing(userId);
        return Right(models.map(_mapToEntity).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({required String userId, required File file}) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _remoteDataSource.uploadAvatar(userId: userId, file: file);
        return Right(url);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCover({required String userId, required File file}) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _remoteDataSource.uploadCover(userId: userId, file: file);
        return Right(url);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  UserEntity _mapToEntity(UserModel model) {
    return UserEntity(
      uid: model.uid,
      email: model.email,
      username: model.username,
      displayName: model.displayName,
      bio: model.bio,
      avatarUrl: model.avatarUrl,
      coverUrl: model.coverUrl,
      website: model.website,
      badges: model.badges,
      role: model.role,
      isDeveloper: model.isDeveloper,
      followersCount: model.followersCount,
      followingCount: model.followingCount,
      appsCount: model.appsCount,
      isPrivate: model.isPrivate,
      showLastSeen: model.showLastSeen,
      allowMessages: model.allowMessages,
      notificationSettings: NotificationSettingsEntity(
        messages: model.notificationSettings.messages,
        comments: model.notificationSettings.comments,
        follows: model.notificationSettings.follows,
        updates: model.notificationSettings.updates,
      ),
      preferences: UserPreferencesEntity(
        theme: model.preferences.theme,
        language: model.preferences.language,
        dataSaver: model.preferences.dataSaver,
      ),
      createdAt: model.createdAt,
    );
  }
}
