import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/core/network/network_info.dart';
import 'package:downapp/features/developer/data/datasources/developer_remote_datasource.dart';
import 'package:downapp/features/developer/domain/entities/developer_application_entity.dart';
import 'package:downapp/features/developer/domain/repositories/developer_repository.dart';
import 'package:downapp/features/marketplace/domain/entities/app_entity.dart';

class DeveloperRepositoryImpl implements DeveloperRepository {
  final DeveloperRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  DeveloperRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, Unit>> applyForDeveloper({
    required String userId,
    required String reason,
    String portfolio = '',
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      await _remoteDataSource.applyForDeveloper(
        userId: userId, reason: reason, portfolio: portfolio,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeveloperApplicationEntity?>> getApplicationStatus(String userId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      final data = await _remoteDataSource.getApplicationStatus(userId);
      if (data == null) return const Right(null);
      return Right(DeveloperApplicationEntity(
        applicationId: data['id'] ?? '',
        userId: data['userId'] ?? '',
        reason: data['reason'] ?? '',
        portfolio: data['portfolio'] ?? '',
        status: data['status'] ?? 'pending',
        adminNote: data['adminNote'],
        createdAt: data['created'] != null ? DateTime.parse(data['created']) : DateTime.now(),
        reviewedAt: data['reviewedAt'] != null ? DateTime.parse(data['reviewedAt']) : null,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppEntity>>> getMyApps(String developerId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      final models = await _remoteDataSource.getMyApps(developerId);
      return Right(models.map((m) => AppEntity(
        appId: m.appId,
        developerId: m.developerId,
        developerName: m.developerName,
        name: m.name,
        packageName: m.packageName,
        description: m.description,
        shortDescription: m.shortDescription,
        category: m.category,
        tags: m.tags,
        status: m.status,
        downloadCount: m.downloadCount,
        ratingAverage: m.ratingAverage,
        ratingCount: m.ratingCount,
        updatedAt: m.updatedAt,
      )).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> uploadApp({
    required String developerId,
    required String developerName,
    required String name,
    required String packageName,
    required String shortDescription,
    required String description,
    required String category,
    required String version,
    required String changelog,
    required File apkFile,
    required File appIcon,
    required List<File> screenshots,
    Function(double)? onProgress,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      await _remoteDataSource.uploadApp(
        appData: {
          'developerId': developerId,
          'developerName': developerName,
          'name': name,
          'packageName': packageName,
          'shortDescription': shortDescription,
          'description': description,
          'category': category,
          'version': version,
          'changelog': changelog,
        },
        apkFile: apkFile,
        appIcon: appIcon,
        screenshots: screenshots,
        onProgress: onProgress,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateApp({
    required String appId,
    String? name,
    String? description,
    String? changelog,
    String? currentVersion,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (changelog != null) updates['changelog'] = changelog;
      if (currentVersion != null) updates['currentVersion'] = currentVersion;
      await _remoteDataSource.updateApp(appId, updates);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
