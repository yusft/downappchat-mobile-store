import 'package:dartz/dartz.dart';
import 'package:downapp/core/errors/failures.dart';
import 'package:downapp/features/auth/domain/entities/user_entity.dart';

/// Kimlik doğrulama işlemleri için repository arayüzü
abstract class AuthRepository {
  /// Email ve şifre ile giriş
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Email ve şifre ile kayıt
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
    bool isDeveloper = false,
  });

  /// Google ile giriş
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Şifre sıfırlama e-postası gönder
  Future<Either<Failure, Unit>> resetPassword(String email);

  /// Hesabı sil
  Future<Either<Failure, Unit>> deleteAccount();

  /// Çıkış yap
  Future<Either<Failure, Unit>> signOut();

  /// Mevcut oturum açmış kullanıcıyı getir
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Oturum durumu değişikliklerini dinle
  Stream<UserEntity?> get onAuthStateChanged;

  /// PocketBase authStore'dan mevcut kaydı döndür (senkron)
  dynamic getCurrentAuthRecord();

  /// Bir record nesnesinden UserEntity oluştur
  Future<UserEntity?> getCurrentUserFromRecord(dynamic record);
}
