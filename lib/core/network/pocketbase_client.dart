import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PocketBase istemci servisi — Tüm uygulama bu servis üzerinden konuşur.
class PocketBaseClient {
  static const String baseUrl = 'http://YOUR_POCKETBASE_SERVER_IP';
  
  static late final PocketBase _instance;
  
  static void init(SharedPreferences prefs) {
    final store = AsyncAuthStore(
      save: (String data) async => prefs.setString('pb_auth', data),
      initial: prefs.getString('pb_auth'),
      clear: () async => prefs.remove('pb_auth'),
    );
    _instance = PocketBase(baseUrl, authStore: store);
  }

  static PocketBase get instance => _instance;

  /// Auth durumunu kontrol eder
  static bool get isAuthenticated => _instance.authStore.isValid;

  /// Mevcut kullanıcı ID'sini döndürür
  static String? get currentUserId => _instance.authStore.record?.id;
}
