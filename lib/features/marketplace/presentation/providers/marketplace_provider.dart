import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:downapp/app/di/providers.dart';
import 'package:downapp/features/marketplace/domain/entities/app_entity.dart';
import 'package:downapp/features/marketplace/domain/entities/category_entity.dart';
import 'package:downapp/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:downapp/features/marketplace/data/repositories/marketplace_repository_impl.dart';
import 'package:downapp/features/marketplace/data/datasources/marketplace_remote_datasource.dart';
import 'package:downapp/features/marketplace/domain/usecases/get_trending_apps.dart';
import 'package:downapp/features/marketplace/domain/usecases/get_new_apps.dart';
import 'package:downapp/features/marketplace/domain/usecases/get_categories.dart';
import 'package:downapp/features/marketplace/domain/usecases/search_apps.dart';
import 'package:downapp/features/marketplace/domain/usecases/get_app_detail.dart';

// ── Data & Repository Providers ───────────────────

final marketplaceRemoteDataSourceProvider = Provider<MarketplaceRemoteDataSource>((ref) {
  return MarketplaceRemoteDataSourceImpl(ref.watch(pocketBaseProvider));
});

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepositoryImpl(
    ref.watch(marketplaceRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

// ── Use Case Providers ────────────────────────────

final getTrendingAppsProvider = Provider((ref) => GetTrendingApps(ref.watch(marketplaceRepositoryProvider)));
final getNewAppsProvider = Provider((ref) => GetNewApps(ref.watch(marketplaceRepositoryProvider)));
final getCategoriesProvider = Provider((ref) => GetCategories(ref.watch(marketplaceRepositoryProvider)));
final searchAppsProvider = Provider((ref) => SearchApps(ref.watch(marketplaceRepositoryProvider)));
final getAppDetailProvider = Provider((ref) => GetAppDetail(ref.watch(marketplaceRepositoryProvider)));

// ── UI Providers ──────────────────────────────────

/// Trend uygulamalar
final trendingAppsProvider = FutureProvider<List<AppEntity>>((ref) async {
  final getTrending = ref.watch(getTrendingAppsProvider);
  final result = await getTrending(limit: 10);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (apps) => apps,
  );
});

/// Yeni eklenen uygulamalar
final newAppsProvider = FutureProvider<List<AppEntity>>((ref) async {
  final getNew = ref.watch(getNewAppsProvider);
  final result = await getNew(limit: 10);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (apps) => apps,
  );
});

/// Kategoriler
final categoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final getCats = ref.watch(getCategoriesProvider);
  final result = await getCats();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
});

/// Arama sonuçları (query parametreli)
final searchResultsProvider = FutureProvider.family<List<AppEntity>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final search = ref.watch(searchAppsProvider);
  final result = await search(query);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (apps) => apps,
  );
});

/// Uygulama detayı (appId parametreli)
final appDetailProvider = FutureProvider.family<AppEntity, String>((ref, appId) async {
  final getDetail = ref.watch(getAppDetailProvider);
  final result = await getDetail(appId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (app) => app,
  );
});

/// Benzer uygulamalar (kategori bazlı)
final similarAppsProvider = FutureProvider.family<List<AppEntity>, String>((ref, category) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final result = await repo.getAppsByCategory(category);
  return result.fold((_) => [], (apps) => apps);
});

/// Bekleyen uygulamalar (Admin)
final pendingAppsProvider = FutureProvider<List<AppEntity>>((ref) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final result = await repo.getPendingApps();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (apps) => apps,
  );
});

/// Geliştiricinin kendi uygulamaları
final developerAppsProvider = FutureProvider.family<List<AppEntity>, String>((ref, userId) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final result = await repo.getAppsByDeveloper(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (apps) => apps,
  );
});
