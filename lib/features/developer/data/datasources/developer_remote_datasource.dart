import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:downapp/features/marketplace/data/models/app_model.dart';

/// Developer remote data source — PocketBase implementation
abstract class DeveloperRemoteDataSource {
  Future<void> applyForDeveloper({
    required String userId,
    required String reason,
    String portfolio,
  });
  Future<Map<String, dynamic>?> getApplicationStatus(String userId);
  Future<List<AppModel>> getMyApps(String developerId);
  Future<void> uploadApp({
    required Map<String, dynamic> appData,
    required File apkFile,
    required File appIcon,
    required List<File> screenshots,
    Function(double)? onProgress,
  });
  Future<void> updateApp(String appId, Map<String, dynamic> updates);
}

class DeveloperRemoteDataSourceImpl implements DeveloperRemoteDataSource {
  final PocketBase _pb;

  DeveloperRemoteDataSourceImpl(this._pb);

  @override
  Future<void> applyForDeveloper({
    required String userId,
    required String reason,
    String portfolio = '',
  }) async {
    final body = {
      'userId': userId,
      'reason': reason,
      'portfolio': portfolio,
      'status': 'pending',
    };
    await _pb.collection('developer_applications').create(body: body);
    
    // Kullanıcının developerStatus'ünü güncelle
    await _pb.collection('users').update(userId, body: {
      'developerStatus': 'pending',
    });
  }

  @override
  Future<Map<String, dynamic>?> getApplicationStatus(String userId) async {
    try {
      final snapshot = await _pb.collection('developer_applications').getList(
        page: 1,
        perPage: 1,
        filter: 'userId = "$userId"',
        sort: '-created',
      );
      
      if (snapshot.items.isEmpty) return null;
      final item = snapshot.items.first;
      return {'id': item.id, ...item.data};
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<AppModel>> getMyApps(String developerId) async {
    final result = await _pb.collection('apps').getList(
      filter: 'developer = "$developerId"',
      sort: '-updated',
    );
    return result.items.map((item) => AppModel.fromPocketBase(item)).toList();
  }

  @override
  Future<void> uploadApp({
    required Map<String, dynamic> appData,
    required File apkFile,
    required File appIcon,
    required List<File> screenshots,
    Function(double)? onProgress,
  }) async {
    final dio = dio_lib.Dio();
    final url = '${_pb.baseURL}/api/collections/apps/records';
    
    final formData = dio_lib.FormData.fromMap({
      'name': appData['name'],
      'packageName': appData['packageName'],
      'shortDescription': appData['shortDescription'],
      'description': appData['description'],
      'category': appData['category'],
      'developer': appData['developerId'],
      'version': appData['version'],
      'changelog': appData['changelog'],
      'status': 'pending',
      'fileSize': apkFile.lengthSync(), // Dosya boyutu eklendi
      'downloadCount': 0,
      'ratingAverage': 0.0,
      'ratingCount': 0,
      'icon': await dio_lib.MultipartFile.fromFile(appIcon.path, filename: 'icon.png'),
      'apk': await dio_lib.MultipartFile.fromFile(apkFile.path, filename: 'app.apk'),
    });

    // Ekran görüntüleri ekle
    for (var file in screenshots) {
      formData.files.add(
        MapEntry('screenshots', await dio_lib.MultipartFile.fromFile(file.path)),
      );
    }

    try {
      await dio.post(
        url,
        data: formData,
        options: dio_lib.Options(
          headers: {
            'Authorization': _pb.authStore.token,
          },
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );
    } catch (e) {
      throw Exception('Yükleme başarısız: $e');
    }
  }

  @override
  Future<void> updateApp(String appId, Map<String, dynamic> updates) async {
    await _pb.collection('apps').update(appId, body: updates);
  }
}
