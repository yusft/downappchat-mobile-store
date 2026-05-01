import 'package:intl/intl.dart';

/// Sayı ve metin formatlama yardımcı sınıfı
class Formatters {
  Formatters._();

  /// Büyük sayıları kısa formata çevirir (1.2K, 3.5M)
  static String formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) {
      final result = count / 1000;
      return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}K';
    }
    if (count < 1000000000) {
      final result = count / 1000000;
      return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}M';
    }
    final result = count / 1000000000;
    return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}B';
  }

  /// Dosya boyutunu okunabilir formata çevirir
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Yıldız puanını formatlar
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  /// Versiyon numarasını formatlar
  static String formatVersion(String version) {
    if (version.startsWith('v')) return version;
    return 'v$version';
  }

  /// İndirme sayısını formatlar
  static String formatDownloads(int downloads) {
    final count = formatCount(downloads);
    return '$count indirme';
  }

  /// Zamanı kullanıcı dostu formata çevirir (Bugünse 14:30, değilse 09/04)
  static String formatTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays < 1 && now.day == date.day) {
      return DateFormat('HH:mm').format(date);
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }

  /// Para birimi formatı
  static String formatCurrency(double amount, {String symbol = '₺'}) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
