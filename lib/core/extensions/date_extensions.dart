import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// DateTime genişletme metotları
extension DateExtensions on DateTime {
  /// "2 saat önce" formatında gösterir
  String get timeAgo => timeago.format(this, locale: 'tr');

  /// "11 Nisan 2026" formatında gösterir
  String get formattedDate => DateFormat('d MMMM yyyy', 'tr_TR').format(this);

  /// "11 Nis 2026" kısa format
  String get shortDate => DateFormat('d MMM yyyy', 'tr_TR').format(this);

  /// "14:30" saat formatı
  String get formattedTime => DateFormat('HH:mm').format(this);

  /// "11 Nis 14:30" tarih + saat
  String get dateTime => DateFormat('d MMM HH:mm', 'tr_TR').format(this);

  /// Bugün mü?
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Dün mü?
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Chat mesajı için akıllı tarih gösterimi
  String get chatDate {
    if (isToday) return formattedTime;
    if (isYesterday) return 'Dün';
    return shortDate;
  }

  /// Story süresi dolmuş mu?
  bool get isStoryExpired {
    return DateTime.now().difference(this).inHours >= 24;
  }

  /// Story kalan süre
  String get storyRemainingTime {
    final remaining = Duration(hours: 24) - DateTime.now().difference(this);
    if (remaining.isNegative) return 'Sona erdi';
    if (remaining.inHours > 0) return '${remaining.inHours}s kaldı';
    return '${remaining.inMinutes}dk kaldı';
  }
}
