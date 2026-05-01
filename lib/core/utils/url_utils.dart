class UrlUtils {
  static const String _pbHost = 'http://YOUR_POCKETBASE_SERVER_IP';
  static const String _pbFilesPath = '/api/files';

  /// PocketBase dosya URL'sini oluşturur.
  /// collection: Koleksiyon adı (örn: apps, users, stories)
  /// recordId: Kayıt ID'si
  /// filename: Dosya adı
  static String getFileUrl(String collection, String recordId, String? filename) {
    if (filename == null || filename.isEmpty) return '';
    if (filename.startsWith('http')) return filename;
    
    // Koleksiyon adı bazen _pb_users_auth_ gibi sistem isimleri olabilir, 
    // bunu modele/repository'e bırakıyoruz ama apps, stories vs için direkt kullanılabilir.
    return '$_pbHost$_pbFilesPath/$collection/$recordId/$filename';
  }

  /// Kullanıcı avatarı için özel URL oluşturucu
  static String getUserAvatarUrl(String userId, String? avatarFilename) {
    return getFileUrl('_pb_users_auth_', userId, avatarFilename);
  }

  /// Story medyası için özel URL oluşturucu
  static String getStoryMediaUrl(String storyId, String? mediaFilename) {
    return getFileUrl('stories', storyId, mediaFilename);
  }

  /// App ikonu/bannerı için özel URL oluşturucu
  static String getAppFileUrl(String appRecordId, String? filename) {
    return getFileUrl('apps', appRecordId, filename);
  }
}
