import 'package:pocketbase/pocketbase.dart';
import 'package:downapp/features/auth/data/models/user_model.dart';
import 'package:downapp/core/errors/exceptions.dart';
import 'package:downapp/core/utils/url_utils.dart';

/// PocketBase ile iletişim kuran veri kaynağı
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
    bool isDeveloper = false,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<void> resetPassword(String email);

  Future<void> deleteAccount();

  Future<UserModel?> getCurrentUserData(String uid);

  Stream<RecordModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final PocketBase _pb;

  AuthRemoteDataSourceImpl(this._pb);

  /// PocketBase instance'ı dışarıdan erişim için (authStore kontrolü)
  PocketBase get pb => _pb;

  @override
  Stream<RecordModel?> get authStateChanges => _pb.authStore.onChange.map((event) => event.record);

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final authData = await _pb.collection('users').authWithPassword(email, password);
      
      return _mapRecordToUserModel(authData.record);
    } on ClientException catch (e) {
      // PocketBase hata kodlarına göre Türkçe mesaj
      if (e.statusCode == 400) {
        throw const AuthException('E-posta veya şifre hatalı. Lütfen tekrar deneyin.');
      } else if (e.statusCode == 401) {
        throw const AuthException('Giriş bilgileri yanlış.');
      } else if (e.statusCode == 403) {
        throw const AuthException('Bu hesap devre dışı bırakılmış.');
      } else if (e.statusCode == 429) {
        throw const AuthException('Çok fazla deneme yaptınız. Lütfen bir süre bekleyin.');
      }
      throw AuthException('Giriş başarısız: ${e.response['message'] ?? e.toString()}');
    } catch (e) {
      throw AuthException('Bağlantı hatası: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
    bool isDeveloper = false,
  }) async {
    try {
      final body = <String, dynamic>{
        "username": username.toLowerCase(),
        "email": email,
        "emailVisibility": true,
        "password": password,
        "passwordConfirm": password,
        "displayName": displayName,
        "role": isDeveloper ? "developer" : "user",
        "isDeveloper": isDeveloper,
        "developerStatus": isDeveloper ? "approved" : "none",
      };

      final record = await _pb.collection('users').create(body: body);
      
      // Kayıt sonrası otomatik giriş yap
      await _pb.collection('users').authWithPassword(email, password);
      
      return _mapRecordToUserModel(record);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // PocketBase'de Google auth için OAuth2 akışı gerekir. 
    // Bu Flutter tarafında tarayıcı açmayı gerektirir. Şimdilik unimplemented.
    throw UnimplementedError('Google Sign-In PocketBase OAuth2 yapılandırması gerektirir.');
  }

  @override
  Future<void> signOut() async {
    _pb.authStore.clear();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _pb.collection('users').requestPasswordReset(email);
  }

  @override
  Future<UserModel?> getCurrentUserData(String uid) async {
    try {
      final record = await _pb.collection('users').getOne(uid);
      return _mapRecordToUserModel(record);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final userId = _pb.authStore.record?.id;
      if (userId == null) return;
      
      await _pb.collection('users').delete(userId);
      _pb.authStore.clear();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  UserModel _mapRecordToUserModel(RecordModel record) {
    String avatarUrl = record.getStringValue('avatar');
    // UrlUtils kullanıyoruz
    avatarUrl = UrlUtils.getUserAvatarUrl(record.id, avatarUrl);

    return UserModel(
      uid: record.id,
      email: record.getStringValue('email'),
      username: record.getStringValue('username'),
      displayName: record.getStringValue('displayName'),
      bio: record.getStringValue('bio'),
      avatarUrl: avatarUrl,
      isDeveloper: record.getBoolValue('isDeveloper'),
      developerStatus: record.getStringValue('developerStatus'),
      createdAt: DateTime.parse(record.getStringValue('created')),
      updatedAt: DateTime.parse(record.getStringValue('updated')),
    );
  }
}
