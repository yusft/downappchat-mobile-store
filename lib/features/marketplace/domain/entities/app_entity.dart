import 'package:equatable/equatable.dart';

/// Uygulama temel varlığı (Domain Entity)
class AppEntity extends Equatable {
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
  final String status;
  final int downloadCount;
  final double ratingAverage;
  final int ratingCount;
  final int favoriteCount;
  final bool isVirusScanned;
  final DateTime updatedAt;

  const AppEntity({
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
    this.status = 'approved',
    this.downloadCount = 0,
    this.ratingAverage = 0.0,
    this.ratingCount = 0,
    this.favoriteCount = 0,
    this.isVirusScanned = false,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [appId, name, updatedAt];
}
