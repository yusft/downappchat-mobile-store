import 'package:downapp/core/constants/app_constants.dart';

/// Form doğrulama fonksiyonları
class Validators {
  Validators._();

  /// Email doğrulama
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi gerekli';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Geçerli bir email adresi girin';
    }
    return null;
  }

  /// Şifre doğrulama
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Şifre en az ${AppConstants.minPasswordLength} karakter olmalı';
    }
    if (value.length > AppConstants.maxPasswordLength) {
      return 'Şifre en fazla ${AppConstants.maxPasswordLength} karakter olabilir';
    }
    return null;
  }

  /// Şifre tekrar doğrulama
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }

  /// Kullanıcı adı doğrulama
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı gerekli';
    }
    if (value.length < AppConstants.minUsernameLength) {
      return 'Kullanıcı adı en az ${AppConstants.minUsernameLength} karakter olmalı';
    }
    if (value.length > AppConstants.maxUsernameLength) {
      return 'Kullanıcı adı en fazla ${AppConstants.maxUsernameLength} karakter olabilir';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Sadece harf, rakam ve alt tire kullanabilirsiniz';
    }
    return null;
  }

  /// Genel boş alan doğrulama
  static String? validateRequired(String? value, [String fieldName = 'Bu alan']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gerekli';
    }
    return null;
  }

  /// Biyografi doğrulama
  static String? validateBio(String? value) {
    if (value != null && value.length > AppConstants.maxBioLength) {
      return 'Biyografi en fazla ${AppConstants.maxBioLength} karakter olabilir';
    }
    return null;
  }

  /// URL doğrulama
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) return null; // Opsiyonel alan
    if (!RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    ).hasMatch(value)) {
      return 'Geçerli bir URL girin';
    }
    return null;
  }

  /// Yorum doğrulama
  static String? validateComment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Yorum boş olamaz';
    }
    if (value.length > AppConstants.maxCommentLength) {
      return 'Yorum en fazla ${AppConstants.maxCommentLength} karakter olabilir';
    }
    return null;
  }
}
