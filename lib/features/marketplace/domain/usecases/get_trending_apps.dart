import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/marketplace/domain/entities/app_entity.dart';
import 'package:downapp/features/marketplace/domain/repositories/marketplace_repository.dart';

/// Trend uygulamaları getiren use case
class GetTrendingApps {
  final MarketplaceRepository repository;
  GetTrendingApps(this.repository);

  Future<Either<Failure, List<AppEntity>>> call({int limit = 10}) {
    return repository.getTrendingApps(limit: limit);
  }
}
