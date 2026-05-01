import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/core/network/network_info.dart';
import 'package:downapp/features/marketplace/data/datasources/marketplace_remote_datasource.dart';
import 'package:downapp/features/marketplace/data/models/app_model.dart';
import 'package:downapp/features/marketplace/data/models/category_model.dart';
import 'package:downapp/features/marketplace/domain/entities/app_entity.dart';
import 'package:downapp/features/marketplace/domain/entities/category_entity.dart';
import 'package:downapp/features/marketplace/domain/repositories/marketplace_repository.dart';

/// MarketplaceRepository'nin Firebase implementasyonu
class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  MarketplaceRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<AppEntity>>> getTrendingApps({int limit = 10}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      final models = await _remoteDataSource.getTrendingApps(limit: limit);
      return Right(models.map(_mapAppToEntity).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppEntity>>> getNewApps({int limit = 10}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      final models = await _remoteDataSource.getNewApps(limit: limit);
      return Right(models.map(_mapAppToEntity).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppEntity>>> getAppsByCategory(
    String category, {
    int limit = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      final models = await _remoteDataSource.getAppsByCategory(category, limit: limit);
      return Right(models.map(_mapAppToEntity).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppEntity>>> searchApps(String query) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      final models = await _remoteDataSource.searchApps(query);
      return Right(models.map(_mapAppToEntity).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppEntity>> getAppDetail(String appId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      final model = await _remoteDataSource.getAppDetail(appId);
      return Right(_mapAppToEntity(model));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      final models = await _remoteDataSource.getCategories();
      return Right(models.map(_mapCategoryToEntity).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppEntity>>> getPendingApps() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      final models = await _remoteDataSource.getPendingApps();
      return Right(models.map(_mapAppToEntity).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateAppStatus(String appId, String status) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      await _remoteDataSource.updateAppStatus(appId, status);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppEntity>>> getAppsByDeveloper(String userId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }
    try {
      final models = await _remoteDataSource.getAppsByDeveloper(userId);
      return Right(models.map(_mapAppToEntity).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── Mappers ──────────────────────────────────────

  AppEntity _mapAppToEntity(AppModel model) {
    return AppEntity(
      appId: model.appId,
      developerId: model.developerId,
      developerName: model.developerName,
      name: model.name,
      packageName: model.packageName,
      description: model.description,
      shortDescription: model.shortDescription,
      category: model.category,
      tags: model.tags,
      iconUrl: model.iconUrl,
      screenshots: model.screenshots,
      bannerUrl: model.bannerUrl,
      currentVersion: model.currentVersion,
      minAndroidVersion: model.minAndroidVersion,
      apkUrl: model.apkUrl,
      obbUrl: model.obbUrl,
      fileSize: model.fileSize,
      changelog: model.changelog,
      status: model.status,
      downloadCount: model.downloadCount,
      ratingAverage: model.ratingAverage,
      ratingCount: model.ratingCount,
      favoriteCount: model.favoriteCount,
      isVirusScanned: model.isVirusScanned,
      updatedAt: model.updatedAt,
    );
  }

  CategoryEntity _mapCategoryToEntity(CategoryModel model) {
    return CategoryEntity(
      categoryId: model.categoryId,
      nameTr: model.nameTr,
      nameEn: model.nameEn,
      icon: model.icon,
      color: model.color,
      appCount: model.appCount,
      order: model.order,
    );
  }
}
