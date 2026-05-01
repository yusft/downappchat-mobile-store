import 'package:pocketbase/pocketbase.dart';
import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/stories/domain/entities/story_entity.dart';
import 'package:downapp/features/stories/domain/repositories/story_repository.dart';
import 'package:downapp/core/utils/url_utils.dart';

class StoryRepositoryImpl implements StoryRepository {
  final PocketBase _pb;
  StoryRepositoryImpl(this._pb);

  @override
  Future<Either<Failure, List<StoryEntity>>> getActiveStories(String userId) async {
    try {
      final now = DateTime.now().toUtc();
      
      // expiresAt filtresi ile dene, yoksa filtresiz dene
      ResultList<RecordModel> result;
      try {
        result = await _pb.collection('stories').getList(
          filter: 'expiresAt > "${now.toIso8601String()}"',
          sort: '-created',
          perPage: 50,
        );
      } catch (_) {
        // expiresAt alanı yoksa tüm story'leri getir
        result = await _pb.collection('stories').getList(
          sort: '-created',
          perPage: 50,
        );
      }

      final stories = result.items.map((item) {
        // mediaUrl, File alanı ise sadece dosya adı olarak gelir
        String rawMediaUrl = item.getStringValue('mediaUrl');
        String fullMediaUrl = UrlUtils.getStoryMediaUrl(item.id, rawMediaUrl);

        // userAvatar'ı da düzgün URL'ye çevir
        String rawUserAvatar = item.getStringValue('userAvatar');
        String userAvatar = UrlUtils.getUserAvatarUrl(item.getStringValue('userId'), rawUserAvatar);

        // expiresAt parse et — yoksa 12 saat sonrasını default yap
        DateTime expiresAt;
        try {
          expiresAt = DateTime.parse(item.getStringValue('expiresAt'));
        } catch (_) {
          expiresAt = DateTime.now().add(const Duration(hours: 12));
        }

        return StoryEntity(
          storyId: item.id,
          userId: item.getStringValue('userId'),
          userName: item.getStringValue('userName'),
          userAvatar: userAvatar,
          mediaUrl: fullMediaUrl,
          mediaType: item.getStringValue('mediaType'),
          caption: item.getStringValue('caption'),
          viewCount: item.getIntValue('viewCount'),
          viewers: item.getListValue<String>('viewers'),
          createdAt: DateTime.tryParse(item.getStringValue('created')) ?? DateTime.now(),
          expiresAt: expiresAt,
        );
      }).toList();

      return Right(stories);
    } catch (e) {
      // Collection yoksa boş liste döndür
      return const Right([]);
    }
  }

  @override
  Future<Either<Failure, Unit>> createStory({
    required String userId,
    required String userName,
    required String mediaUrl,
    String mediaType = 'image',
    String caption = '',
  }) async {
    try {
      final now = DateTime.now().toUtc();
      await _pb.collection('stories').create(body: {
        'userId': userId,
        'userName': userName,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'caption': caption,
        'viewCount': 0,
        'viewers': [],
        'expiresAt': now.add(const Duration(hours: 12)).toIso8601String(),
      });
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markStoryViewed({
    required String storyId,
    required String viewerUserId,
  }) async {
    try {
      final record = await _pb.collection('stories').getOne(storyId);
      final viewers = record.getListValue<String>('viewers');
      
      if (!viewers.contains(viewerUserId)) {
        viewers.add(viewerUserId);
        await _pb.collection('stories').update(storyId, body: {
          'viewers': viewers,
          'viewCount': record.getIntValue('viewCount') + 1,
        });
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
