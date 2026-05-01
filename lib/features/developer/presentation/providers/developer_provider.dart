import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:downapp/app/di/providers.dart';
import 'package:downapp/features/developer/domain/entities/developer_application_entity.dart';
import 'package:downapp/features/developer/domain/repositories/developer_repository.dart';
import 'package:downapp/features/developer/data/repositories/developer_repository_impl.dart';
import 'package:downapp/features/developer/data/datasources/developer_remote_datasource.dart';
import 'package:downapp/features/marketplace/domain/entities/app_entity.dart';

// ── Data & Repository ─────────────────────────────

final developerRemoteDataSourceProvider = Provider<DeveloperRemoteDataSource>((ref) {
  return DeveloperRemoteDataSourceImpl(
    ref.watch(pocketBaseProvider),
  );
});

final developerRepositoryProvider = Provider<DeveloperRepository>((ref) {
  return DeveloperRepositoryImpl(
    ref.watch(developerRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

// ── UI Providers ──────────────────────────────────

/// Geliştirici başvuru durumu
final developerApplicationProvider = FutureProvider.family<DeveloperApplicationEntity?, String>((ref, userId) async {
  final repo = ref.watch(developerRepositoryProvider);
  final result = await repo.getApplicationStatus(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (app) => app,
  );
});

/// Geliştiricinin uygulamaları
final myAppsProvider = FutureProvider.family<List<AppEntity>, String>((ref, developerId) async {
  final repo = ref.watch(developerRepositoryProvider);
  final result = await repo.getMyApps(developerId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (apps) => apps,
  );
});

/// Developer State
class DeveloperState {
  final AsyncValue<void> status;
  final double uploadProgress;

  const DeveloperState({
    this.status = const AsyncValue.data(null),
    this.uploadProgress = 0,
  });

  bool get isLoading => status.isLoading;
  bool get hasError => status.hasError;
  Object? get error => status.error;

  DeveloperState copyWith({
    AsyncValue<void>? status,
    double? uploadProgress,
  }) {
    return DeveloperState(
      status: status ?? this.status,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

/// Geliştirici işlemleri (başvuru, yükleme vb.) için notifier
class DeveloperNotifier extends StateNotifier<DeveloperState> {
  final DeveloperRepository _repository;
  DeveloperNotifier(this._repository) : super(const DeveloperState());

  Future<void> apply({
    required String userId,
    required String reason,
    String portfolio = '',
  }) async {
    state = state.copyWith(status: const AsyncValue.loading());
    final result = await _repository.applyForDeveloper(
      userId: userId, reason: reason, portfolio: portfolio,
    );
    state = state.copyWith(
      status: result.fold(
        (f) => AsyncValue.error(f.message, StackTrace.current),
        (_) => const AsyncValue.data(null),
      ),
    );
  }

  Future<void> uploadApp({
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
  }) async {
    state = state.copyWith(
      status: const AsyncValue.loading(),
      uploadProgress: 0,
    );

    final result = await _repository.uploadApp(
      developerId: developerId,
      developerName: developerName,
      name: name,
      packageName: packageName,
      shortDescription: shortDescription,
      description: description,
      category: category,
      version: version,
      changelog: changelog,
      apkFile: apkFile,
      appIcon: appIcon,
      screenshots: screenshots,
      onProgress: (progress) {
        state = state.copyWith(uploadProgress: progress);
      },
    );

    state = state.copyWith(
      status: result.fold(
        (f) => AsyncValue.error(f.message, StackTrace.current),
        (_) => const AsyncValue.data(null),
      ),
      uploadProgress: result.isRight() ? 1.0 : 0,
    );
  }
}

final developerNotifierProvider = StateNotifierProvider<DeveloperNotifier, DeveloperState>((ref) {
  return DeveloperNotifier(ref.watch(developerRepositoryProvider));
});
