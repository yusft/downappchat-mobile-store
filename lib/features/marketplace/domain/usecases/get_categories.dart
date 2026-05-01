import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/marketplace/domain/entities/category_entity.dart';
import 'package:downapp/features/marketplace/domain/repositories/marketplace_repository.dart';

/// Kategorileri getiren use case
class GetCategories {
  final MarketplaceRepository repository;
  GetCategories(this.repository);

  Future<Either<Failure, List<CategoryEntity>>> call() {
    return repository.getCategories();
  }
}
