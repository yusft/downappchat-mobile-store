import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/auth/domain/entities/user_entity.dart';
import 'package:downapp/features/profile/domain/repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<Either<Failure, UserEntity>> call(String userId) {
    return repository.getProfile(userId);
  }
}
