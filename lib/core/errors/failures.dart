import 'package:equatable/equatable.dart';

/// Hata yönetimi için temel Failure sınıfı
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Sunucu kaynaklı hatalar
class ServerFailure extends Failure {
  const ServerFailure(String message, {super.code}) : super(message: message);
}

/// Cache kaynaklı hatalar
class CacheFailure extends Failure {
  const CacheFailure(String message, {super.code}) : super(message: message);
}

/// Ağ bağlantısı hataları
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'İnternet bağlantınızı kontrol edin', int? code])
      : super(message: message, code: code);
}

/// Firebase Auth hataları
class AuthFailure extends Failure {
  const AuthFailure(String message, {super.code}) : super(message: message);

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthFailure('Bu email ile kayıtlı kullanıcı bulunamadı');
      case 'wrong-password':
        return const AuthFailure('Hatalı şifre');
      case 'email-already-in-use':
        return const AuthFailure('Bu email adresi zaten kullanımda');
      case 'weak-password':
        return const AuthFailure('Şifre en az 6 karakter olmalıdır');
      case 'invalid-email':
        return const AuthFailure('Geçersiz email adresi');
      case 'user-disabled':
        return const AuthFailure('Bu hesap devre dışı bırakılmış');
      case 'too-many-requests':
        return const AuthFailure('Çok fazla deneme yaptınız, lütfen bekleyin');
      case 'operation-not-allowed':
        return const AuthFailure('Bu işlem şu anda kullanılamıyor');
      case 'account-exists-with-different-credential':
        return const AuthFailure('Bu email farklı bir giriş yöntemiyle ilişkili');
      default:
        return AuthFailure('Bir hata oluştu: $code');
    }
  }
}

/// Dosya işlem hataları
class FileFailure extends Failure {
  const FileFailure(String message, {super.code}) : super(message: message);
}

/// Doğrulama hataları
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {super.code}) : super(message: message);
}

/// İzin hataları
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Gerekli izinler verilmedi', int? code])
      : super(message: message, code: code);
}
