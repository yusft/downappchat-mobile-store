import 'package:equatable/equatable.dart';

/// Story domain entity'si
class StoryEntity extends Equatable {
  final String storyId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String mediaUrl;
  final String mediaType; // image, gif, video
  final String caption;
  final int viewCount;
  final List<String> viewers;
  final DateTime createdAt;
  final DateTime expiresAt;

  const StoryEntity({
    required this.storyId,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.mediaUrl,
    this.mediaType = 'image',
    this.caption = '',
    this.viewCount = 0,
    this.viewers = const [],
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [storyId, userId, createdAt];
}
