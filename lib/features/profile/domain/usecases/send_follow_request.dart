import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/profile/domain/repositories/profile_repository.dart';

class SendFollowRequest {
  final ProfileRepository repository;
  SendFollowRequest(this.repository);

  Future<Either<Failure, Unit>> call({
    required String currentUserId,
    required String targetUserId,
  }) {
    return repository.sendFollowRequest(
      currentUserId: currentUserId,
      targetUserId: targetUserId,
    );
  }
}
