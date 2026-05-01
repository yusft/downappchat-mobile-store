import 'package:pocketbase/pocketbase.dart';
import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/notifications/domain/entities/notification_entity.dart';

/// Notification repository arayüzü
abstract class NotificationRepository {
  /// Kullanıcının bildirimlerini getirir
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(String userId);

  /// Bildirimi okundu olarak işaretler
  Future<Either<Failure, Unit>> markAsRead(String notificationId);

  /// Tüm bildirimleri okundu olarak işaretler
  Future<Either<Failure, Unit>> markAllAsRead(String userId);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final PocketBase _pb;
  NotificationRepositoryImpl(this._pb);

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(String userId) async {
    try {
      final result = await _pb.collection('notifications').getList(
        filter: 'userId = "$userId"',
        sort: '-created',
        perPage: 50,
      );

      final notifications = result.items.map((item) {
        return NotificationEntity(
          notificationId: item.id,
          userId: item.getStringValue('userId'),
          type: item.getStringValue('type'),
          title: item.getStringValue('title'),
          body: item.getStringValue('body'),
          data: Map<String, dynamic>.from(item.get<Map<String, dynamic>>('data')),
          isRead: item.getBoolValue('isRead'),
          senderId: item.getStringValue('senderId'),
          createdAt: DateTime.parse(item.getStringValue('created')),
        );
      }).toList();

      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String notificationId) async {
    try {
      await _pb.collection('notifications').update(notificationId, body: {
        'isRead': true,
      });
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead(String userId) async {
    try {
      // PocketBase'de batch güncelleme için birden fazla istek gerekebilir
      // Şimdilik okunmamışları bulup tek tek güncelleyelim
      final result = await _pb.collection('notifications').getList(
        filter: 'userId = "$userId" && isRead = false',
      );
      
      for (final item in result.items) {
        await _pb.collection('notifications').update(item.id, body: {'isRead': true});
      }
      
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
