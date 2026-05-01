import 'package:pocketbase/pocketbase.dart';
import 'package:equatable/equatable.dart';

enum ActivityType {
  upload,
  follow,
  favorite,
  download,
  review,
  unknown;

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ActivityType.unknown,
    );
  }
}

class ActivityModel extends Equatable {
  final String id;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final ActivityType type;
  final String targetId;
  final String targetName;
  final DateTime createdAt;

  const ActivityModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.type,
    required this.targetId,
    required this.targetName,
    required this.createdAt,
  });

  factory ActivityModel.fromPocketBase(RecordModel record) {
    final baseUrl = 'http://YOUR_POCKETBASE_SERVER_IP/api/files/users/${record.getStringValue('userId')}';
    
    return ActivityModel(
      id: record.id,
      userId: record.getStringValue('userId'),
      userName: record.get<List<RecordModel>>('expand.userId').isNotEmpty 
          ? record.get<List<RecordModel>>('expand.userId').first.getStringValue('displayName') 
          : 'Kullanıcı',
      userAvatar: (record.get<List<RecordModel>>('expand.userId').isNotEmpty && 
                   record.get<List<RecordModel>>('expand.userId').first.getStringValue('avatar').isNotEmpty)
          ? '$baseUrl/${record.get<List<RecordModel>>('expand.userId').first.getStringValue('avatar')}'
          : null,
      type: ActivityType.fromString(record.getStringValue('type')),
      targetId: record.getStringValue('targetId'),
      targetName: record.getStringValue('targetName'),
      createdAt: DateTime.parse(record.getStringValue('created')),
    );
  }

  @override
  List<Object?> get props => [id, userId, type, targetId, createdAt];
}
