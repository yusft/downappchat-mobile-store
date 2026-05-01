import 'package:equatable/equatable.dart';

/// Chat mesaj modeli
class MessageModel extends Equatable {
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

  const MessageModel({
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

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      messageId: id,
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'text',
      mediaUrl: map['mediaUrl'],
      fileName: map['fileName'],
      fileSize: map['fileSize'],
      isRead: map['isRead'] ?? false,
      readAt: map['readAt'] != null ? DateTime.parse(map['readAt']) : null,
      createdAt: map['created'] != null ? DateTime.parse(map['created']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'content': content,
    'type': type,
    'mediaUrl': mediaUrl,
    'fileName': fileName,
    'fileSize': fileSize,
    'isRead': isRead,
    'readAt': readAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [messageId];
}

/// Chat odası modeli
class ChatModel extends Equatable {
  final String chatId;
  final List<String> participants;
  final Map<String, dynamic> participantDetails;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final DateTime createdAt;

  const ChatModel({
    required this.chatId,
    required this.participants,
    this.participantDetails = const {},
    this.lastMessage = '',
    this.lastMessageAt,
    this.lastMessageSenderId,
    this.unreadCount = const {},
    required this.createdAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      chatId: id,
      participants: List<String>.from(map['participants'] ?? []),
      participantDetails: Map<String, dynamic>.from(map['participantDetails'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: map['lastMessageAt'] != null ? DateTime.parse(map['lastMessageAt']) : null,
      lastMessageSenderId: map['lastMessageSenderId'],
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      createdAt: map['created'] != null ? DateTime.parse(map['created']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'participants': participants,
    'participantDetails': participantDetails,
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt?.toIso8601String(),
    'lastMessageSenderId': lastMessageSenderId,
    'unreadCount': unreadCount,
  };

  @override
  List<Object?> get props => [chatId];
}
