import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/stories/domain/entities/story_entity.dart';

/// Story repository arayüzü
abstract class StoryRepository {
  /// Aktif hikayeleri getirir (süresi dolmamış, takip edilenler)
  Future<Either<Failure, List<StoryEntity>>> getActiveStories(String userId);

  /// Hikaye oluşturur
  Future<Either<Failure, Unit>> createStory({
    required String userId,
    required String userName,
    required String mediaUrl,
    String mediaType,
    String caption,
  });

  /// Hikayeyi görüntülendi olarak işaretler
  Future<Either<Failure, Unit>> markStoryViewed({
    required String storyId,
    required String viewerUserId,
  });
}
