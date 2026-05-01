import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/marketplace/domain/entities/app_entity.dart';
import 'package:downapp/features/marketplace/domain/repositories/marketplace_repository.dart';

/// Uygulama detayını getiren use case
class GetAppDetail {
  final MarketplaceRepository repository;
  GetAppDetail(this.repository);

  Future<Either<Failure, AppEntity>> call(String appId) {
    return repository.getAppDetail(appId);
  }
}
