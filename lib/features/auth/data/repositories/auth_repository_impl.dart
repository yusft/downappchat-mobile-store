import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/core/network/network_info.dart';
import 'package:downapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:downapp/features/auth/domain/entities/user_entity.dart';
import 'package:downapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:downapp/core/errors/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Stream<UserEntity?> get onAuthStateChanged {
    return _remoteDataSource.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      final model = await _remoteDataSource.getCurrentUserData(user.id);
      return model != null ? _mapToEntity(model) : null;
    });
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.signInWithEmail(
          email: email,
          password: password,
        );
        return Right(_mapToEntity(model));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        if (e.code != null) return Left(AuthFailure.fromCode(e.code!));
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
    bool isDeveloper = false,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.signUpWithEmail(
          email: email,
          password: password,
          username: username,
          displayName: displayName,
          isDeveloper: isDeveloper,
        );
        return Right(_mapToEntity(model));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        if (e.code != null) return Left(AuthFailure.fromCode(e.code!));
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.signInWithGoogle();
        return Right(_mapToEntity(model));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        if (e.code != null) return Left(AuthFailure.fromCode(e.code!));
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(String email) async {
    try {
      await _remoteDataSource.resetPassword(email);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteAccount();
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        if (e.code != null) return Left(AuthFailure.fromCode(e.code!));
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      // Firebase current user'dan uid al
      // Bu metod genelde başlangıçta çağrılır
      return const Right(null); // Basitlik için stream'i kullanacağız
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  dynamic getCurrentAuthRecord() {
    // PocketBase authStore'dan mevcut kaydı döndür (senkron)
    final pb = (_remoteDataSource as AuthRemoteDataSourceImpl).pb;
    if (pb.authStore.isValid && pb.authStore.record != null) {
      return pb.authStore.record;
    }
    return null;
  }

  @override
  Future<UserEntity?> getCurrentUserFromRecord(dynamic record) async {
    try {
      final model = await _remoteDataSource.getCurrentUserData(record.id);
      return model != null ? _mapToEntity(model) : null;
    } catch (e) {
      return null;
    }
  }

  UserEntity _mapToEntity(dynamic model) {
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
