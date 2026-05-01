import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/profile/domain/repositories/profile_repository.dart';

class RespondToFollowRequest {
  final ProfileRepository repository;
  RespondToFollowRequest(this.repository);

  Future<Either<Failure, Unit>> call({
    required String followId,
    required String currentUserId,
    required String targetUserId,
    required bool accept,
  }) {
    return repository.respondToFollowRequest(
      followId: followId,
      currentUserId: currentUserId,
      targetUserId: targetUserId,
      accept: accept,
    );
  }
}
