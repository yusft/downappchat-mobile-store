import 'package:equatable/equatable.dart';

/// Rapor domain entity'si
class ReportEntity extends Equatable {
  final String reportId;
  final String reporterId;
  final String reportedId;
  final String type; // user, app, comment, chat
  final String reason;
  final String description;
  final String status; // pending, reviewed, resolved, dismissed
  final String? adminNote;
  final DateTime createdAt;

  const ReportEntity({
    required this.reportId,
    required this.reporterId,
    required this.reportedId,
    required this.type,
    required this.reason,
    this.description = '',
    this.status = 'pending',
    this.adminNote,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [reportId, reporterId, type];
}
