import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/marketplace/domain/entities/app_entity.dart';
import 'package:downapp/features/marketplace/domain/entities/category_entity.dart';

/// Marketplace repository arayüzü (Domain Layer)
abstract class MarketplaceRepository {
  /// Trend uygulamaları getirir (trendScore'a göre sıralı)
  Future<Either<Failure, List<AppEntity>>> getTrendingApps({int limit = 10});

  /// Yeni eklenen uygulamaları getirir (tarih sırası)
  Future<Either<Failure, List<AppEntity>>> getNewApps({int limit = 10});

  /// Kategoriye göre uygulamaları listeler
  Future<Either<Failure, List<AppEntity>>> getAppsByCategory(
    String category, {
    int limit = 20,
  });

  /// Uygulama arar (isim veya açıklama)
  Future<Either<Failure, List<AppEntity>>> searchApps(String query);

  /// Tek bir uygulamanın detayını getirir
  Future<Either<Failure, AppEntity>> getAppDetail(String appId);

  /// Tüm kategorileri getirir
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// Bekleyen uygulamaları getirir (Admin)
  Future<Either<Failure, List<AppEntity>>> getPendingApps();

  /// Uygulama durumunu günceller (Admin)
  Future<Either<Failure, Unit>> updateAppStatus(String appId, String status);

  /// Geliştiricinin kendi uygulamalarını getirir
  Future<Either<Failure, List<AppEntity>>> getAppsByDeveloper(String userId);
}
