import 'package:equatable/equatable.dart';

/// Geliştirici başvuru domain entity'si
class DeveloperApplicationEntity extends Equatable {
  final String applicationId;
  final String userId;
  final String reason;
  final String portfolio;
  final String status; // pending, approved, rejected
  final String? adminNote;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  const DeveloperApplicationEntity({
    required this.applicationId,
    required this.userId,
    required this.reason,
    this.portfolio = '',
    this.status = 'pending',
    this.adminNote,
    required this.createdAt,
    this.reviewedAt,
  });

  @override
  List<Object?> get props => [applicationId, userId, status];
}
