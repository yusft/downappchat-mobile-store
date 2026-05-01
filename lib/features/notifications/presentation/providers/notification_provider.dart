import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:downapp/app/di/providers.dart';
import 'package:downapp/features/notifications/domain/entities/notification_entity.dart';
import 'package:downapp/features/notifications/data/repositories/notification_repository_impl.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(pocketBaseProvider));
});

/// Kullanıcının bildirimleri
final notificationsProvider = FutureProvider.family<List<NotificationEntity>, String>((ref, userId) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final result = await repo.getNotifications(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (notifications) => notifications,
  );
});

/// Okunmamış bildirim var mı kontrolü
final hasUnreadNotificationsProvider = Provider.family<bool, String>((ref, userId) {
  final asyncNotifications = ref.watch(notificationsProvider(userId));
  return asyncNotifications.maybeWhen(
    data: (notifications) => notifications.any((n) => !n.isRead),
    orElse: () => false,
  );
});

/// Bildirim işlemleri notifier
class NotificationNotifier extends StateNotifier<AsyncValue<void>> {
  final NotificationRepository _repository;
  NotificationNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> markAsRead(String notificationId) async {
    await _repository.markAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    state = const AsyncValue.loading();
    final result = await _repository.markAllAsRead(userId);
    state = result.fold(
      (f) => AsyncValue.error(f.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}

final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<void>>((ref) {
  return NotificationNotifier(ref.watch(notificationRepositoryProvider));
});
