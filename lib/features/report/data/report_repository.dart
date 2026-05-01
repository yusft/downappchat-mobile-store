import 'package:pocketbase/pocketbase.dart';
import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:downapp/app/di/providers.dart';

/// Rapor gönderme repository
class ReportRepository {
  final PocketBase _pb;
  ReportRepository(this._pb);

  Future<Either<Failure, Unit>> sendReport({
    required String reporterId,
    required String reportedId,
    required String type,
    required String reason,
    String description = '',
  }) async {
    try {
      await _pb.collection('reports').create(body: {
        'reporterId': reporterId,
        'reportedId': reportedId,
        'type': type,
        'reason': reason,
        'description': description,
        'status': 'pending',
      });
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

// ── Providers ─────────────────────────────────────

final reportRepositoryProvider = Provider((ref) {
  return ReportRepository(ref.watch(pocketBaseProvider));
});

class ReportNotifier extends StateNotifier<AsyncValue<void>> {
  final ReportRepository _repository;
  ReportNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> sendReport({
    required String reporterId,
    required String reportedId,
    required String type,
    required String reason,
    String description = '',
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.sendReport(
      reporterId: reporterId, reportedId: reportedId,
      type: type, reason: reason, description: description,
    );
    state = result.fold(
      (f) => AsyncValue.error(f.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}

final reportNotifierProvider = StateNotifierProvider<ReportNotifier, AsyncValue<void>>((ref) {
  return ReportNotifier(ref.watch(reportRepositoryProvider));
});
