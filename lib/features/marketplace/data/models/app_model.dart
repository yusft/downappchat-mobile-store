import 'package:pocketbase/pocketbase.dart';
import 'package:equatable/equatable.dart';
import 'package:downapp/core/utils/url_utils.dart';

/// Uygulama veri modeli — PocketBase ile tam uyumlu
class AppModel extends Equatable {
  final String appId;
  final String developerId;
  final String developerName;
  final String name;
  final String packageName;
  final String description;
  final String shortDescription;
  final String category;
  final List<String> tags;
  final String iconUrl;
  final List<String> screenshots;
  final String bannerUrl;
  final String currentVersion;
  final String minAndroidVersion;
  final String apkUrl;
  final String? obbUrl;
  final int fileSize;
  final String changelog;
  final String status; // pending, approved, rejected, suspended
  final String? rejectionReason;
  final int downloadCount;
  final double ratingAverage;
  final int ratingCount;
  final int favoriteCount;
  final double trendScore;
  final bool isVirusScanned;
  final String? virusScanResult;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;

  const AppModel({
    required this.appId,
    required this.developerId,
    required this.developerName,
    required this.name,
    required this.packageName,
    this.description = '',
    this.shortDescription = '',
    this.category = '',
    this.tags = const [],
    this.iconUrl = '',
    this.screenshots = const [],
    this.bannerUrl = '',
    this.currentVersion = '1.0.0',
    this.minAndroidVersion = '5.0',
    this.apkUrl = '',
    this.obbUrl,
    this.fileSize = 0,
    this.changelog = '',
    this.status = 'pending',
    this.rejectionReason,
    this.downloadCount = 0,
    this.ratingAverage = 0.0,
    this.ratingCount = 0,
    this.favoriteCount = 0,
    this.trendScore = 0.0,
    this.isVirusScanned = false,
    this.virusScanResult,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
  });

  factory AppModel.fromPocketBase(RecordModel record) {
    // PocketBase dosya URL yapısı - Koleksiyon adı (apps) kullanımı daha garantidir.
    final collectionName = record.collectionName.isNotEmpty
        ? record.collectionName
        : 'apps';
    final baseUrl =
        'http://YOUR_POCKETBASE_SERVER_IP/api/files/$collectionName/${record.id}';

    return AppModel(
      appId: record.id,
      developerId: record.getStringValue('developer'),
      developerName: _safeGetDeveloperName(record),
      name: record.getStringValue('name'),
      packageName: record.getStringValue('packageName'),
      description: _safeGetDescription(record),
      shortDescription: record.getStringValue('shortDescription'),
      category: record.getStringValue('category'),
      tags: record.getListValue<String>('tags'),
      iconUrl: _safeGetFileUrl(record, 'icon', baseUrl),
      screenshots: _safeGetFileList(record, 'screenshots', baseUrl),
      bannerUrl: _safeGetFileUrl(record, 'banner', baseUrl),
      currentVersion: record.getStringValue('version').isNotEmpty
          ? record.getStringValue('version')
          : (record.getStringValue('currentVersion').isNotEmpty
                ? record.getStringValue('currentVersion')
                : '1.0.0'),
      minAndroidVersion: record.getStringValue('minAndroidVersion', '5.0'),
      apkUrl: _safeGetFileUrl(record, 'apk', baseUrl),
      changelog: record.getStringValue('changelog'),
      status: record.getStringValue('status', 'pending'),
      fileSize: record.getIntValue('fileSize', 0),
      downloadCount: record.getIntValue('downloadCount', 0),
      favoriteCount: record.getIntValue('favoriteCount', 0),
      trendScore: record.getDoubleValue('trendScore', 0.0),
      ratingAverage: record.getDoubleValue('ratingAverage', 0.0),
      ratingCount: record.getIntValue('ratingCount', 0),
      isVirusScanned: record.getBoolValue('isVirusScanned'),
      virusScanResult: record.getStringValue('virusScanResult'),
      createdAt:
          DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(record.getStringValue('updated')) ?? DateTime.now(),
    );
  }

  static String _safeGetFileUrl(
    RecordModel record,
    String field,
    String? baseUrl, // Artık UrlUtils kullanıyoruz, bu fallback için durabilir
  ) {
    final collectionName = record.collectionName.isNotEmpty ? record.collectionName : 'apps';
    final filename = record.getStringValue(field);
    if (filename.isNotEmpty) {
      return UrlUtils.getFileUrl(collectionName, record.id, filename);
    }

    // Alternatif deneme (data içinden)
    final dataFilename = record.data[field]?.toString();
    if (dataFilename != null && dataFilename.isNotEmpty) {
      return UrlUtils.getFileUrl(collectionName, record.id, dataFilename);
    }

    return '';
  }

  static List<String> _safeGetFileList(
    RecordModel record,
    String field,
    String? baseUrl,
  ) {
    final collectionName = record.collectionName.isNotEmpty ? record.collectionName : 'apps';
    try {
      final list = record.getListValue<String>(field);
      if (list.isNotEmpty) {
        return list.map((e) => UrlUtils.getFileUrl(collectionName, record.id, e)).toList();
      }
    } catch (_) {}

    // Alternatif deneme (data içinden liste veya tekil string)
    final raw = record.data[field];
    if (raw is List) {
      return raw.map((e) => UrlUtils.getFileUrl(collectionName, record.id, e.toString())).toList();
    } else if (raw is String && raw.isNotEmpty) {
      return [UrlUtils.getFileUrl(collectionName, record.id, raw)];
    }

    return [];
  }

  static String _safeGetDescription(RecordModel record) {
    final fields = ['description', 'desc', 'content', 'details'];
    for (final field in fields) {
      final val = record.getStringValue(field);
      if (val.isNotEmpty) return val;
      final dataVal = record.data[field]?.toString();
      if (dataVal != null && dataVal.isNotEmpty) return dataVal;
    }
    return '';
  }

  AppModel copyWith({
    String? appId,
    String? developerId,
    String? developerName,
    String? name,
    String? packageName,
    String? description,
    String? shortDescription,
    String? category,
    List<String>? tags,
    String? iconUrl,
    List<String>? screenshots,
    String? bannerUrl,
    String? currentVersion,
    String? minAndroidVersion,
    String? apkUrl,
    String? obbUrl,
    int? fileSize,
    String? changelog,
    String? status,
    String? rejectionReason,
    int? downloadCount,
    double? ratingAverage,
    int? ratingCount,
    int? favoriteCount,
    double? trendScore,
    bool? isVirusScanned,
    String? virusScanResult,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
  }) {
    return AppModel(
      appId: appId ?? this.appId,
      developerId: developerId ?? this.developerId,
      developerName: developerName ?? this.developerName,
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      iconUrl: iconUrl ?? this.iconUrl,
      screenshots: screenshots ?? this.screenshots,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      currentVersion: currentVersion ?? this.currentVersion,
      minAndroidVersion: minAndroidVersion ?? this.minAndroidVersion,
      apkUrl: apkUrl ?? this.apkUrl,
      obbUrl: obbUrl ?? this.obbUrl,
      fileSize: fileSize ?? this.fileSize,
      changelog: changelog ?? this.changelog,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      downloadCount: downloadCount ?? this.downloadCount,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      trendScore: trendScore ?? this.trendScore,
      isVirusScanned: isVirusScanned ?? this.isVirusScanned,
      virusScanResult: virusScanResult ?? this.virusScanResult,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  @override
  List<Object?> get props => [appId, name, updatedAt];

  static String _safeGetDeveloperName(RecordModel record) {
    try {
      // 1. Durum: Expand nesne olarak gelmiş olabilir
      try {
        final dev = record.get<RecordModel>('expand.developer');
        final dn = dev.getStringValue('displayName');
        final un = dev.getStringValue('username');
        return dn.isNotEmpty ? dn : (un.isNotEmpty ? un : 'Geliştirici');
      } catch (_) {}

      // 2. Durum: Expand liste olarak gelmiş olabilir
      final devList = record.get<List<RecordModel>>('expand.developer');
      if (devList.isNotEmpty) {
        final dev = devList.first;
        final dn = dev.getStringValue('displayName');
        final un = dev.getStringValue('username');
        return dn.isNotEmpty ? dn : (un.isNotEmpty ? un : 'Geliştirici');
      }
    } catch (_) {
      // expand yoksa default dön
    }
    return 'Geliştirici';
  }
}
