import 'package:equatable/equatable.dart';

/// Mesaj domain entity'si
class MessageEntity extends Equatable {
  final String messageId;
  final String senderId;
  final String content;
  final String type; // text, image, gif, file
  final String? mediaUrl;
  final String? fileName;
  final int? fileSize;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const MessageEntity({
    required this.messageId,
    required this.senderId,
    required this.content,
    this.type = 'text',
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [messageId, senderId, createdAt];
}

/// Chat domain entity'si
class ChatEntity extends Equatable {
  final String chatId;
  final List<String> participants;
  final Map<String, dynamic> participantDetails;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String lastMessageSenderId;
  final Map<String, int> unreadCount;
  final DateTime createdAt;

  const ChatEntity({
    required this.chatId,
    required this.participants,
    this.participantDetails = const {},
    this.lastMessage = '',
    this.lastMessageAt,
    this.lastMessageSenderId = '',
    this.unreadCount = const {},
    required this.createdAt,
  });

  DateTime? get lastMessageTime => lastMessageAt;

  @override
  List<Object?> get props => [chatId, lastMessageAt];
}
