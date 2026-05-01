/// String genişletme metotları
extension StringExtensions on String {
  /// İlk harfi büyük yapar
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Her kelimenin ilk harfini büyük yapar
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Email formatı kontrolü
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  /// Kullanıcı adı formatı kontrolü (sadece harf, rakam, alt tire)
  bool get isValidUsername {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(this);
  }

  /// URL formatı kontrolü
  bool get isValidUrl {
    return RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    ).hasMatch(this);
  }

  /// Dosya boyutunu okunabilir formata çevirir
  String get toFileSize {
    final bytes = int.tryParse(this) ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Kısa hale getirir (max karakter)
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  /// Sadece rakam içerip içermediğini kontrol eder
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);

  /// HTML tag'larını temizler
  String get removeHtmlTags => replaceAll(RegExp(r'<[^>]*>'), '');
}

/// Nullable String genişletmeleri
extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
