import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/auth/domain/entities/user_entity.dart';
import 'package:downapp/features/auth/domain/repositories/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String username,
    required String displayName,
    bool isDeveloper = false,
  }) {
    return repository.signUpWithEmail(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
      isDeveloper: isDeveloper,
    );
  }
}
