import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/marketplace/domain/entities/app_entity.dart';
import 'package:downapp/features/marketplace/domain/repositories/marketplace_repository.dart';

/// Yeni eklenen uygulamaları getiren use case
class GetNewApps {
  final MarketplaceRepository repository;
  GetNewApps(this.repository);

  Future<Either<Failure, List<AppEntity>>> call({int limit = 10}) {
    return repository.getNewApps(limit: limit);
  }
}
