import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:downapp/app/di/providers.dart';
import 'package:downapp/features/auth/domain/entities/user_entity.dart';
import 'package:downapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:downapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:downapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:downapp/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:downapp/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:downapp/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:downapp/features/auth/domain/usecases/sign_out.dart';
import 'package:downapp/features/auth/domain/usecases/reset_password.dart';

/// Auth durumu
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Auth State
class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, UserEntity? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Auth Notifier — Clean Architecture Use Case'lerini kullanır
class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final ResetPassword _resetPassword;
  final AuthRepository _repository;

  AuthNotifier({
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
    required ResetPassword resetPassword,
    required AuthRepository repository,
  })  : _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        _resetPassword = resetPassword,
        _repository = repository,
        super(const AuthState()) {
    _init();
  }

  void _init() {
    // Uygulama açıldığında mevcut oturumu kontrol et
    final record = _repository.getCurrentAuthRecord();
    if (record != null) {
      _repository.getCurrentUserFromRecord(record).then((user) {
        if (user != null) {
          state = AuthState(status: AuthStatus.authenticated, user: user);
        } else {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      });
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }

    // Sonraki değişiklikleri dinle
    _repository.onAuthStateChanged.listen((user) {
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _signInWithEmail(email: email, password: password);
    result.fold(
      (failure) => state = AuthState(status: AuthStatus.error, error: failure.message),
      (user) => state = AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
    bool isDeveloper = false,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _signUpWithEmail(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
      isDeveloper: isDeveloper,
    );
    result.fold(
      (failure) => state = AuthState(status: AuthStatus.error, error: failure.message),
      (user) => state = AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _signInWithGoogle();
    result.fold(
      (failure) => state = AuthState(status: AuthStatus.error, error: failure.message),
      (user) => state = AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> signOut() async {
    await _signOut();
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _resetPassword(email);
    result.fold(
      (failure) => state = AuthState(status: AuthStatus.error, error: failure.message),
      (_) => state = const AuthState(status: AuthStatus.unauthenticated),
    );
  }

  /// Kullanıcı bilgilerini Firestore'dan yeniden çeker
  Future<void> refreshUser() async {
    final currentUser = state.user;
    if (currentUser == null) return;
    // Auth state stream otomatik olarak güncelleyecektir
    // Bu metod sadece bir tetikleyici olarak çalışır
    _repository.onAuthStateChanged.first.then((user) {
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      }
    });
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _repository.deleteAccount();
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, error: failure.message),
      (_) => state = const AuthState(status: AuthStatus.unauthenticated),
    );
  }
}

// ── Providers ───────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    ref.watch(pocketBaseProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final signInWithEmailProvider = Provider((ref) => SignInWithEmail(ref.watch(authRepositoryProvider)));
final signUpWithEmailProvider = Provider((ref) => SignUpWithEmail(ref.watch(authRepositoryProvider)));
final signInWithGoogleProvider = Provider((ref) => SignInWithGoogle(ref.watch(authRepositoryProvider)));
final signOutProvider = Provider((ref) => SignOut(ref.watch(authRepositoryProvider)));
final resetPasswordProvider = Provider((ref) => ResetPassword(ref.watch(authRepositoryProvider)));

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signInWithEmail: ref.watch(signInWithEmailProvider),
    signUpWithEmail: ref.watch(signUpWithEmailProvider),
    signInWithGoogle: ref.watch(signInWithGoogleProvider),
    signOut: ref.watch(signOutProvider),
    resetPassword: ref.watch(resetPasswordProvider),
    repository: ref.watch(authRepositoryProvider),
  );
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

