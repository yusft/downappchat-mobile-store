import 'package:pocketbase/pocketbase.dart';
import 'package:downapp/features/marketplace/data/models/app_model.dart';
import 'package:downapp/features/marketplace/data/models/category_model.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<AppModel>> getTrendingApps({int limit = 10});
  Future<List<AppModel>> getNewApps({int limit = 10});
  Future<List<AppModel>> getAppsByCategory(String category, {int limit = 20});
  Future<List<AppModel>> searchApps(String query);
  Future<AppModel> getAppDetail(String appId);
  Future<List<CategoryModel>> getCategories();
  Future<List<AppModel>> getPendingApps();
  Future<void> updateAppStatus(String appId, String status);
  Future<List<AppModel>> getAppsByDeveloper(String userId);
}

/// PocketBase implementasyonu
class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final PocketBase _pb;

  MarketplaceRemoteDataSourceImpl(this._pb);

  @override
  Future<List<AppModel>> getTrendingApps({int limit = 10}) async {
    try {
      final result = await _pb.collection('apps').getList(
        page: 1,
        perPage: limit,
        filter: 'status = "approved"',
        sort: '-created', // PocketBase sunucusunda downloadCount / trendScore alanı olmadığı için
        expand: 'developer',
      );
      return result.items.map((item) => AppModel.fromPocketBase(item)).toList();
    } on ClientException catch (e) {
      if (e.statusCode == 400) {
        throw Exception("Lütfen PocketBase'de 'apps' tablosuna 'status' (Text) alanı ekleyin.");
      }
      throw Exception(e.response['message'] ?? e.toString());
    }
  }

  @override
  Future<List<AppModel>> getNewApps({int limit = 10}) async {
    try {
      final result = await _pb.collection('apps').getList(
        page: 1,
        perPage: limit,
        filter: 'status = "approved"',
        sort: '-created',
        expand: 'developer',
      );
      return result.items.map((item) => AppModel.fromPocketBase(item)).toList();
    } on ClientException catch (e) {
      if (e.statusCode == 400) {
        throw Exception("Lütfen PocketBase'de 'apps' tablosuna 'status' (Text) alanı ekleyin.");
      }
      throw Exception(e.response['message'] ?? e.toString());
    }
  }

  @override
  Future<List<AppModel>> getAppsByCategory(String category, {int limit = 20}) async {
    try {
      final result = await _pb.collection('apps').getList(
        page: 1,
        perPage: limit,
        filter: 'status = "approved" && category = "$category"',
        sort: '-created', // downloadCount olmadığı için modified
        expand: 'developer',
      );
      return result.items.map((item) => AppModel.fromPocketBase(item)).toList();
    } on ClientException catch (e) {
      if (e.statusCode == 400) {
         throw Exception("Lütfen PocketBase'de 'apps' tablosuna 'status' ve 'category' alanlarını ekleyin.");
      }
      throw Exception(e.response['message'] ?? e.toString());
    }
  }

  @override
  Future<List<AppModel>> searchApps(String query) async {
    try {
      final result = await _pb.collection('apps').getList(
        page: 1,
        perPage: 50,
        filter: 'status = "approved" && (name ~ "$query" || shortDescription ~ "$query")',
        sort: '-created',
        expand: 'developer',
      );
      return result.items.map((item) => AppModel.fromPocketBase(item)).toList();
    } on ClientException catch (e) {
      if (e.statusCode == 400) {
        throw Exception("Filtre hatası. Lütfen 'status' alanının eklendiğinden emin olun.");
      }
      throw Exception(e.response['message'] ?? e.toString());
    }
  }

  @override
  Future<AppModel> getAppDetail(String appId) async {
    final item = await _pb.collection('apps').getOne(
      appId,
      expand: 'developer',
    );
    return AppModel.fromPocketBase(item);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    // PocketBase sunucusunda "categories" adında bir tablo bulunmuyor, bu yüzden her zaman statik listeyi kullanıyoruz ki app çökmesin.
    return const [
      CategoryModel(categoryId: '1', nameTr: 'Oyunlar', nameEn: 'Games', icon: 'sports_esports_rounded', color: 'AppColors.primary', appCount: 0, order: 1),
      CategoryModel(categoryId: '2', nameTr: 'Araçlar', nameEn: 'Tools', icon: 'build_rounded', color: 'AppColors.accentOrange', appCount: 0, order: 2),
      CategoryModel(categoryId: '3', nameTr: 'Sosyal', nameEn: 'Social', icon: 'people_rounded', color: 'AppColors.secondary', appCount: 0, order: 3),
      CategoryModel(categoryId: '4', nameTr: 'Eğitim', nameEn: 'Education', icon: 'school_rounded', color: 'AppColors.accentGreen', appCount: 0, order: 4),
      CategoryModel(categoryId: '5', nameTr: 'Müzik', nameEn: 'Music', icon: 'music_note_rounded', color: 'AppColors.accentPurple', appCount: 0, order: 5),
    ];
  }

  @override
  Future<List<AppModel>> getPendingApps() async {
    try {
      final result = await _pb.collection('apps').getList(
        page: 1,
        perPage: 50,
        filter: 'status = "pending"',
        sort: '-created',
        expand: 'developer',
      );
      return result.items.map((item) => AppModel.fromPocketBase(item)).toList();
    } on ClientException catch (e) {
      if (e.statusCode == 400) {
        throw Exception("Lütfen PocketBase'de 'apps' tablosuna 'status' adında bir TEXT alanı oluşturun. Aksi halde onay sistemi çalışmaz.");
      }
      throw Exception(e.response['message'] ?? e.toString());
    }
  }

  @override
  Future<void> updateAppStatus(String appId, String status) async {
    try {
      await _pb.collection('apps').update(appId, body: {
        'status': status,
        if (status == 'approved') 'approvedAt': DateTime.now().toIso8601String(),
      });
    } on ClientException catch (e) {
      if (e.statusCode == 404) {
        throw Exception("Yetki Hatası (404)! PocketBase Admin panelinde 'apps' tablosunun UPDATE kuralını (API Rules) herkesin veya Admin'in güncelleyebileceği şekilde ayarlayın (örn: boş bırakın).");
      }
      rethrow;
    }
  }

  @override
  Future<List<AppModel>> getAppsByDeveloper(String userId) async {
    final result = await _pb.collection('apps').getList(
      page: 1,
      perPage: 50,
      filter: 'developer = "$userId"',
      sort: '-created',
      expand: 'developer',
    );
    return result.items.map((item) => AppModel.fromPocketBase(item)).toList();
  }
}
