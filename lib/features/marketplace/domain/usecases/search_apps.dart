import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/marketplace/domain/entities/app_entity.dart';
import 'package:downapp/features/marketplace/domain/repositories/marketplace_repository.dart';

/// Uygulama arayan use case
class SearchApps {
  final MarketplaceRepository repository;
  SearchApps(this.repository);

  Future<Either<Failure, List<AppEntity>>> call(String query) {
    return repository.searchApps(query);
  }
}
