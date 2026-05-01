import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/chat/domain/entities/chat_entity.dart';

/// Chat repository arayüzü
abstract class ChatRepository {
  /// Kullanıcının sohbet listesini dinler (realtime)
  Stream<List<ChatEntity>> watchChats(String userId);

  /// Bir sohbetin mesajlarını dinler (realtime)
  Stream<List<MessageEntity>> watchMessages(String chatId);

  /// Mesaj gönderir
  Future<Either<Failure, Unit>> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    String type = 'text',
    String? mediaUrl,
  });

  /// Yeni sohbet başlatır
  Future<Either<Failure, String>> createChat({
    required String currentUserId,
    required String targetUserId,
  });

  /// Mesajları okundu olarak işaretler
  Future<Either<Failure, Unit>> markAsRead({
    required String chatId,
    required String userId,
  });

  /// Yazıyor göstergesi günceller
  Future<void> updateTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  });
}
