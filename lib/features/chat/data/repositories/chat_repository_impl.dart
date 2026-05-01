import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/core/utils/url_utils.dart';
import 'package:downapp/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:downapp/features/chat/domain/entities/chat_entity.dart';
import 'package:downapp/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<ChatEntity>> watchChats(String userId) {
    return _remoteDataSource.watchChats(userId).map((list) => list.map((data) {
      // DataSource'dan gelen Map formatındaki genişletilmiş verileri işle
      final participants = List<String>.from(data['participants'] ?? []);
      final expandedParticipants = data['expanded_participants'] as List<dynamic>? ?? [];
      final participantDetails = <String, dynamic>{};

      for (final p in expandedParticipants) {
        if (p is Map<String, dynamic>) {
          final pId = p['id'] ?? '';
          if (pId.isNotEmpty) {
            final avatarFile = p['avatar'] ?? '';
            final baseUrl = UrlUtils.getUserAvatarUrl(pId, avatarFile);
            participantDetails[pId] = {
              'displayName': p['displayName'] ?? p['username'] ?? 'Kullanıcı',
              'avatar': avatarFile.isNotEmpty ? baseUrl : '',
              'username': p['username'] ?? '',
            };
          }
        }
      }

      return ChatEntity(
        chatId: data['id'] ?? '',
        participants: participants,
        participantDetails: participantDetails,
        lastMessage: data['lastMessage'] ?? '',
        lastMessageAt: data['lastMessageAt'] != null && data['lastMessageAt'].toString().isNotEmpty 
            ? DateTime.tryParse(data['lastMessageAt'].toString()) 
            : null,
        lastMessageSenderId: data['lastMessageSenderId'] ?? '',
        unreadCount: Map<String, int>.from((data['unreadCount'] as Map? ?? {}).map((k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0))),
        createdAt: DateTime.tryParse(data['created']?.toString() ?? '') ?? DateTime.now(),
      );
    }).toList());
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String chatId) {
    return _remoteDataSource.watchMessages(chatId).map((list) => list.map((data) {
      // MessageEntity mapping
      // Not: expanded_sender şu an domain entity içinde kullanılmıyor ama gerekirse buraya eklenebilir.
      return MessageEntity(
        messageId: data['id'] ?? '',
        senderId: data['senderId'] ?? '',
        content: data['content'] ?? '',
        type: data['type'] ?? 'text',
        mediaUrl: data['mediaUrl'],
        fileName: data['fileName'],
        fileSize: data['fileSize'],
        isRead: data['isRead'] ?? false,
        readAt: data['readAt'] != null ? DateTime.parse(data['readAt']) : null,
        createdAt: data['created'] != null ? DateTime.parse(data['created']) : DateTime.now(),
      );
    }).toList());
  }

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    String type = 'text',
    String? mediaUrl,
  }) async {
    try {
      await _remoteDataSource.sendMessage(chatId, {
        'senderId': senderId,
        'content': content,
        'type': type,
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
      });
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createChat({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final chatId = await _remoteDataSource.createChat({
        'participants': [currentUserId, targetUserId],
        'lastMessage': '',
        'lastMessageSenderId': '',
        'unreadCount': {
          currentUserId: 0, 
          targetUserId: 0
        },
        'lastMessageAt': '', // Veya hiç gönderme
      });
      return Right(chatId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _remoteDataSource.markAsRead(chatId, userId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> updateTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    await _remoteDataSource.updateTypingStatus(chatId, userId, isTyping);
  }
}
