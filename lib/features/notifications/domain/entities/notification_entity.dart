import 'package:equatable/equatable.dart';

/// Bildirim domain entity'si
class NotificationEntity extends Equatable {
  final String notificationId;
  final String userId;
  final String type; // message, comment, follow, update, system
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final String? senderId;
  final DateTime createdAt;

  const NotificationEntity({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    this.isRead = false,
    this.senderId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [notificationId, userId, createdAt];
}
