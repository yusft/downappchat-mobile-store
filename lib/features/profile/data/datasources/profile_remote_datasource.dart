import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:downapp/features/auth/data/models/user_model.dart';
import 'package:downapp/core/errors/exceptions.dart';
import 'package:downapp/core/utils/url_utils.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile(String userId);
  Future<UserModel> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? website,
    Map<String, String>? socialLinks,
    bool? isPrivate,
    bool? showLastSeen,
    String? allowMessages,
    NotificationSettings? notificationSettings,
    UserPreferences? preferences,
  });
  Future<void> followUser({required String currentUserId, required String targetUserId});
  Future<void> unfollowUser({required String currentUserId, required String targetUserId});
  Future<void> respondToFollowRequest({
    required String followId,
    required String currentUserId,
    required String targetUserId,
    required bool accept,
  });
  Future<List<UserModel>> getFollowers(String userId);
  Future<List<UserModel>> getFollowing(String userId);
  Future<String> uploadAvatar({required String userId, required File file});
  Future<String> uploadCover({required String userId, required File file});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final PocketBase _pb;

  ProfileRemoteDataSourceImpl(this._pb);

  @override
  Future<UserModel> getProfile(String userId) async {
    try {
      final record = await _pb.collection('users').getOne(userId);
      
      // Gerçek takipçi/takip verilerini çek
      try {
        final followersRes = await _pb.collection('follows').getList(
          filter: 'target = "$userId" && status = "accepted"',
          perPage: 1,
        );
        final followingRes = await _pb.collection('follows').getList(
          filter: 'user = "$userId" && status = "accepted"',
          perPage: 1,
        );
        final appsRes = await _pb.collection('apps').getList(
          filter: 'developer = "$userId"',
          perPage: 1,
        );

        // Record data'yı güncelle ( UserModel.fromPocketBase buraları okuyor )
        record.data['followersCount'] = followersRes.totalItems;
        record.data['followingCount'] = followingRes.totalItems;
        record.data['appsCount'] = appsRes.totalItems;
      } catch (e) {
        // Hata durumunda (tablo yoksa vs) mevcut verilerle devam et
      }

      return UserModel.fromPocketBase(record);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? website,
    Map<String, String>? socialLinks,
    bool? isPrivate,
    bool? showLastSeen,
    String? allowMessages,
    NotificationSettings? notificationSettings,
    UserPreferences? preferences,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (website != null) updates['website'] = website;
      if (socialLinks != null) updates['socialLinks'] = socialLinks;
      if (isPrivate != null) updates['isPrivate'] = isPrivate;
      if (showLastSeen != null) updates['showLastSeen'] = showLastSeen;
      if (allowMessages != null) updates['allowMessages'] = allowMessages;
      if (notificationSettings != null) updates['notificationSettings'] = notificationSettings.toMap();
      if (preferences != null) updates['preferences'] = preferences.toMap();

      final record = await _pb.collection('users').update(userId, body: updates);
      return UserModel.fromPocketBase(record);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // 1. follows tablosuna kayıt ekle (DURUM: pending)
      final followRecord = await _pb.collection('follows').create(body: {
        'user': currentUserId,
        'target': targetUserId,
        'status': 'pending',
      });
      
      // 2. Bildirim oluştur (hedef kullanıcı görsün)
      try {
        final currentUserRecord = await _pb.collection('users').getOne(currentUserId);
        final senderName = currentUserRecord.getStringValue('displayName').isNotEmpty 
            ? currentUserRecord.getStringValue('displayName') 
            : currentUserRecord.getStringValue('username');
        
        await _pb.collection('notifications').create(body: {
          'userId': targetUserId,
          'type': 'follow_request', // tip guncellendi
          'title': 'Yeni Arkadaş İsteği',
          'body': '$senderName sana arkadaşlık isteği gönderdi!',
          'senderId': currentUserId,
          'isRead': false,
          'data': {
            'type': 'follow_request', 
            'userId': currentUserId,
            'followId': followRecord.id, // Takibi kabul etmek icin ID
          },
        });
      } catch (_) {
        // Bildirim oluşturulamadıysa devam et
      }

      // 3. Aktivite oluştur (opsiyonel)
      try {
        final targetUser = await _pb.collection('users').getOne(targetUserId);
        await _pb.collection('activities').create(body: {
          'userId': currentUserId,
          'type': 'follow',
          'targetId': targetUserId,
          'targetName': targetUser.getStringValue('displayName'),
        });
      } catch (_) {
        // activities yoksa sorun değil
      }
    } on ClientException catch (e) {
      throw ServerException('Arkadaş ekleme hatası: ${e.response['message'] ?? e.toString()}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> respondToFollowRequest({
    required String followId,
    required String currentUserId,
    required String targetUserId,
    required bool accept,
  }) async {
    try {
      if (accept) {
        // 1. Mevcut follows durumunu 'accepted' yap (A -> B)
        await _pb.collection('follows').update(followId, body: {
          'status': 'accepted',
        });

        // 2. Karşılıklı takip oluştur (B -> A) - Eğer zaten yoksa
        try {
          final existing = await _pb.collection('follows').getList(
            filter: 'user = "$currentUserId" && target = "$targetUserId"',
            perPage: 1,
          );
          if (existing.items.isEmpty) {
            await _pb.collection('follows').create(body: {
              'user': currentUserId,
              'target': targetUserId,
              'status': 'accepted',
            });
            
            // 3. Sayaçları güncelle (Karşılıklı olduğu için ikisi de birbirini takip ediyor)
            // Her iki kullanıcının hem takipçi hem takip edilen sayısını 1 artırıyoruz (safe atomic)
            await _pb.collection('users').update(targetUserId, body: {
              'followersCount+': 1,
              'followingCount+': 1,
            });
            await _pb.collection('users').update(currentUserId, body: {
              'followersCount+': 1,
              'followingCount+': 1,
            });
          }
        } catch (_) {
          // Eğer bi-directional bir hata olursa en azından orijinali kalsın
        }

        // 4. Bildirimleri Güncelle / Oluştur
        try {
          final currentUserRecord = await _pb.collection('users').getOne(currentUserId);
          final acceptorName = currentUserRecord.getStringValue('displayName').isNotEmpty 
              ? currentUserRecord.getStringValue('displayName') 
              : currentUserRecord.getStringValue('username');

          // İstek atana bildirim (A'ya bildirim: B kabul etti)
          await _pb.collection('notifications').create(body: {
            'userId': targetUserId,
            'type': 'follow_accepted',
            'title': 'Arkadaşlık İsteği Kabul Edildi',
            'body': '$acceptorName arkadaşlık isteğini kabul etti. Artık arkadaşsınız!',
            'senderId': currentUserId,
            'isRead': false,
            'data': {'type': 'follow_accepted', 'userId': currentUserId},
          });

          // Mevcut bildirimi (B'nin ekranındaki) güncelle ki "Arkadaş eklendiniz" yazsın
          // Not: Bildirim ID'si metoda gelmediği için burada 'follow_request' olan ve bu followId'ye sahip bildirimi bulup güncelleyebiliriz
          final notificationRes = await _pb.collection('notifications').getList(
            filter: 'userId = "$currentUserId" && data.followId = "$followId"',
            perPage: 1,
          );
          if (notificationRes.items.isNotEmpty) {
            await _pb.collection('notifications').update(notificationRes.items.first.id, body: {
              'type': 'system', // Butonların kaybolması için
              'title': 'Arkadaş Eklendi',
              'body': '$acceptorName ile artık arkadaşsınız.',
              'isRead': true,
            });
          }
        } catch (_) {}
      } else {
        // Reddedildi: follow kaydını sil
        await _pb.collection('follows').delete(followId);
      }
    } on ClientException catch (e) {
      throw ServerException('İstek işlenirken hata: ${e.response['message'] ?? e.toString()}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final result = await _pb.collection('follows').getFirstListItem(
        'user = "$currentUserId" && target = "$targetUserId"',
      );
      await _pb.collection('follows').delete(result.id);

      // Sayaçları güncelle (safe)
      try {
        await _pb.collection('users').update(currentUserId, body: {'followingCount-': 1});
        await _pb.collection('users').update(targetUserId, body: {'followersCount-': 1});
      } catch (_) {}
    } on ClientException catch (e) {
      throw ServerException('Takipten çıkma hatası: ${e.response['message'] ?? e.toString()}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Expand'den RecordModel çıkaran yardımcı
  RecordModel? _extractExpand(RecordModel item, String key) {
    try {
      // PocketBase single relation expand: get<RecordModel> ile al
      final record = item.get<RecordModel>('expand.$key');
      return record;
    } catch (_) {
      try {
        // Multi-relation olabilir: get<List<RecordModel>> ile al
        final list = item.get<List<RecordModel>>('expand.$key');
        if (list.isNotEmpty) return list.first;
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<List<UserModel>> getFollowers(String userId) async {
    try {
      final result = await _pb.collection('follows').getList(
        filter: 'target = "$userId" && status = "accepted"',
        expand: 'user',
      );
      final users = <UserModel>[];
      for (final item in result.items) {
        final userRecord = _extractExpand(item, 'user');
        if (userRecord != null) {
          users.add(UserModel.fromPocketBase(userRecord));
        }
      }
      return users;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<UserModel>> getFollowing(String userId) async {
    try {
      final result = await _pb.collection('follows').getList(
        filter: 'user = "$userId" && status = "accepted"',
        expand: 'target',
      );
      final users = <UserModel>[];
      for (final item in result.items) {
        final userRecord = _extractExpand(item, 'target');
        if (userRecord != null) {
          users.add(UserModel.fromPocketBase(userRecord));
        }
      }
      return users;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadAvatar({required String userId, required File file}) async {
    try {
      final record = await _pb.collection('users').update(
        userId,
        files: [await http.MultipartFile.fromPath('avatar', file.path)],
      );
      return UrlUtils.getUserAvatarUrl(record.id, record.getStringValue('avatar'));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadCover({required String userId, required File file}) async {
    try {
      final record = await _pb.collection('users').update(
        userId,
        files: [await http.MultipartFile.fromPath('cover', file.path)],
      );
      return UrlUtils.getFileUrl(record.collectionId, record.id, record.getStringValue('cover'));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
