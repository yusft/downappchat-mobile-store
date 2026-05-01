import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:downapp/app/di/providers.dart';
import 'package:downapp/features/stories/domain/entities/story_entity.dart';
import 'package:downapp/features/stories/domain/repositories/story_repository.dart';
import 'package:downapp/features/stories/data/repositories/story_repository_impl.dart';

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepositoryImpl(ref.watch(pocketBaseProvider));
});

/// Aktif hikayeler
final activeStoriesProvider = FutureProvider.family<List<StoryEntity>, String>((ref, userId) async {
  final repo = ref.watch(storyRepositoryProvider);
  final result = await repo.getActiveStories(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stories) => stories,
  );
});

/// Story işlemleri notifier
class StoryNotifier extends StateNotifier<AsyncValue<void>> {
  final StoryRepository _repository;
  StoryNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createStory({
    required String userId,
    required String userName,
    required String mediaUrl,
    String mediaType = 'image',
    String caption = '',
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.createStory(
      userId: userId, userName: userName,
      mediaUrl: mediaUrl, mediaType: mediaType, caption: caption,
    );
    state = result.fold(
      (f) => AsyncValue.error(f.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<void> markViewed({required String storyId, required String viewerUserId}) async {
    await _repository.markStoryViewed(storyId: storyId, viewerUserId: viewerUserId);
  }
}

final storyNotifierProvider = StateNotifierProvider<StoryNotifier, AsyncValue<void>>((ref) {
  return StoryNotifier(ref.watch(storyRepositoryProvider));
});
