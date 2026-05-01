import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/developer/domain/entities/developer_application_entity.dart';
import 'package:downapp/features/marketplace/domain/entities/app_entity.dart';

/// Geliştirici repository arayüzü
abstract class DeveloperRepository {
  /// Geliştirici başvurusu gönderir
  Future<Either<Failure, Unit>> applyForDeveloper({
    required String userId,
    required String reason,
    String portfolio,
  });

  /// Geliştirici başvuru durumunu sorgular
  Future<Either<Failure, DeveloperApplicationEntity?>> getApplicationStatus(String userId);

  /// Geliştiricinin uygulamalarını listeler
  Future<Either<Failure, List<AppEntity>>> getMyApps(String developerId);

  /// Yeni uygulama yükler
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
  });

  /// Uygulamayı günceller
  Future<Either<Failure, Unit>> updateApp({
    required String appId,
    String? name,
    String? description,
    String? changelog,
    String? currentVersion,
  });
}
