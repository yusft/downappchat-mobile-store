import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

/// İndirme durumu
enum DownloadStatus { downloading, completed, failed }

class DownloadInfo {
  final double progress;
  final DownloadStatus status;
  final String? filePath;

  const DownloadInfo({
    this.progress = 0.0,
    this.status = DownloadStatus.downloading,
    this.filePath,
  });

  DownloadInfo copyWith({double? progress, DownloadStatus? status, String? filePath}) {
    return DownloadInfo(
      progress: progress ?? this.progress,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
    );
  }
}

final downloadNotifierProvider = StateNotifierProvider<DownloadNotifier, Map<String, DownloadInfo>>((ref) {
  return DownloadNotifier();
});

class DownloadNotifier extends StateNotifier<Map<String, DownloadInfo>> {
  DownloadNotifier() : super({});

  final Dio _dio = Dio();

  bool isDownloading(String appId) {
    final info = state[appId];
    return info != null && info.status == DownloadStatus.downloading;
  }

  bool isCompleted(String appId) {
    final info = state[appId];
    return info != null && info.status == DownloadStatus.completed;
  }

  /// Gerekli izinleri iste
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Depolama izni (Android < 13)
      final storageStatus = await Permission.storage.request();

      // Android 11+ (SDK 30+) için MANAGE_EXTERNAL_STORAGE
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }

      // APK yükleme izni
      if (await Permission.requestInstallPackages.isDenied) {
        await Permission.requestInstallPackages.request();
      }

      // İzinlerden en az biri varsa devam et
      return storageStatus.isGranted || 
             await Permission.manageExternalStorage.isGranted ||
             true; // App-specific directory her zaman yazılabilir
    }
    return true;
  }

  /// İndirme için en iyi yazılabilir klasörü bul
  Future<String> _getSavePath(String safeName) async {
    // Önce harici depolama dene (kullanıcı görebilsin)
    if (Platform.isAndroid) {
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          // Download klasörü oluştur
          final downloadDir = Directory('${extDir.path}/DownApp');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          return '${downloadDir.path}/$safeName.apk';
        }
      } catch (_) {
        // Harici depolama erişilemezse dahili kullan
      }
    }

    // Fallback: App Documents (her zaman yazılabilir)
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$safeName.apk';
  }

  Future<void> startDownload({
    required String appId,
    required String appName,
    required String apkUrl,
    required Function(String status, {String? path}) onProgressUpdate,
  }) async {
    // Zaten indiriliyor mu?
    if (isDownloading(appId)) {
      onProgressUpdate('Zaten indiriliyor...');
      return;
    }

    try {
      // İzinleri iste
      await _requestPermissions();

      onProgressUpdate('İndirme başlatıldı...');
      
      // State'e ekle
      state = {
        ...state,
        appId: const DownloadInfo(progress: 0.0, status: DownloadStatus.downloading),
      };

      // Dosya adını temizle ve yol oluştur
      final safeName = appName.replaceAll(RegExp(r'[^\w\-.]'), '_');
      final savePath = await _getSavePath(safeName);

      await _dio.download(
        apkUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            state = {
              ...state,
              appId: DownloadInfo(progress: progress, status: DownloadStatus.downloading),
            };
          }
        },
      );

      // İndirme tamamlandı
      final file = File(savePath);
      if (await file.exists() && await file.length() > 0) {
        state = {
          ...state,
          appId: DownloadInfo(progress: 1.0, status: DownloadStatus.completed, filePath: savePath),
        };
        onProgressUpdate('İndirme tamamlandı! 🎉 (${(await file.length() / 1048576).toStringAsFixed(1)} MB)', path: savePath);
      } else {
        state = {
          ...state,
          appId: const DownloadInfo(progress: 0.0, status: DownloadStatus.failed),
        };
        onProgressUpdate('Dosya indirilemedi. Sunucu boş dosya göndermiş olabilir.');
      }
      
    } catch (e) {
      // Hata durumu
      state = {
        ...state,
        appId: const DownloadInfo(progress: 0.0, status: DownloadStatus.failed),
      };
      
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.connectionTimeout:
            onProgressUpdate('Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.');
            break;
          case DioExceptionType.receiveTimeout:
            onProgressUpdate('İndirme zaman aşımına uğradı. Tekrar deneyin.');
            break;
          default:
            onProgressUpdate('İndirme hatası: ${e.message ?? 'Bilinmeyen hata'}');
        }
      } else {
        onProgressUpdate('İndirme başarısız: ${e.toString().length > 80 ? '${e.toString().substring(0, 80)}...' : e}');
      }
    }
  }

  void openApk(String path) {
    OpenFile.open(path);
  }
}
