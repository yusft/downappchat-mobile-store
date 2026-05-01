import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/app/di/providers.dart';
import 'package:downapp/features/chat/domain/entities/chat_entity.dart';
import 'package:downapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:downapp/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:downapp/features/chat/data/datasources/chat_remote_datasource.dart';

// ── Data & Repository ─────────────────────────────

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSourceImpl(ref.watch(pocketBaseProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(chatRemoteDataSourceProvider));
});

// ── UI Providers ──────────────────────────────────

/// Kullanıcının sohbet listesi (realtime stream)
final chatsStreamProvider = StreamProvider.family<List<ChatEntity>, String>((ref, userId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchChats(userId);
});

/// Bir sohbetin mesajları (realtime stream)
final messagesStreamProvider = StreamProvider.family<List<MessageEntity>, String>((ref, chatId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages(chatId);
});

/// Belirli bir sohbetin detaylarını (katılımcı bilgileri vb.) getiren provider
final singleChatProvider = Provider.family<ChatEntity?, String>((ref, chatId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  final chatsAsync = ref.watch(chatsStreamProvider(user.uid));
  return chatsAsync.when(
    data: (chats) {
      final index = chats.indexWhere((c) => c.chatId == chatId);
      return index != -1 ? chats[index] : null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Chat işlemleri (mesaj gönderme, sohbet başlatma) notifier
class ChatNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repository;
  ChatNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    String type = 'text',
    String? mediaUrl,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.sendMessage(
      chatId: chatId, senderId: senderId,
      content: content, type: type, mediaUrl: mediaUrl,
    );
    state = result.fold(
      (f) => AsyncValue.error(f.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<String?> createChat({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final result = await _repository.createChat(
      currentUserId: currentUserId, targetUserId: targetUserId,
    );
    return result.fold((_) => null, (chatId) => chatId);
  }

  Future<void> markAsRead({
    required String chatId,
    required String userId,
  }) async {
    await _repository.markAsRead(chatId: chatId, userId: userId);
  }
}

/// Toplam okunmamış mesaj sayısını hesaplayan provider
final totalUnreadCountProvider = Provider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  
  final chatsAsync = ref.watch(chatsStreamProvider(user.uid));
  
  return chatsAsync.when(
    data: (chats) {
      return chats.fold(0, (sum, chat) {
        final count = chat.unreadCount[user.uid] ?? 0;
        return sum + count;
      });
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, AsyncValue<void>>((ref) {
  return ChatNotifier(ref.watch(chatRepositoryProvider));
});
