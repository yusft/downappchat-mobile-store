import 'dart:async';
import 'package:pocketbase/pocketbase.dart';

/// Chat PocketBase data source
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final PocketBase _pb;
  ChatRemoteDataSourceImpl(this._pb);

  @override
  Stream<List<Map<String, dynamic>>> watchChats(String userId) {
    final controller = StreamController<List<Map<String, dynamic>>>();

    // Fonksiyon: Verileri çek ve stream'e bas
    Future<void> fetchAndAdd() async {
      try {
        final initial = await _pb.collection('chats').getList(
          filter: 'participants ~ "$userId"',
          sort: '-lastMessageAt',
          expand: 'participants',
        );
        if (!controller.isClosed) {
          controller.add(initial.items.map((item) {
            // Expand edilmiş katılımcıları Map'e çevir
            final expandedParticipants = item.get<List<RecordModel>>('expand.participants')
                .map((p) => {'id': p.id, ...p.data}).toList();
            
            return {
              'id': item.id,
              ...item.data,
              'expanded_participants': expandedParticipants,
            };
          }).toList());
        }
      } catch (e) {
        // debugPrint(e.toString());
      }
    }

    // İlk yükleme
    fetchAndAdd();

    // Değişiklikleri dinle
    _pb.collection('chats').subscribe('*', (event) async {
      await fetchAndAdd();
    });

    controller.onCancel = () {
      _pb.collection('chats').unsubscribe('*');
      controller.close();
    };

    return controller.stream;
  }

  @override
  Stream<List<Map<String, dynamic>>> watchMessages(String chatId) {
    final controller = StreamController<List<Map<String, dynamic>>>();

    Future<void> fetchAndAdd() async {
      try {
        final updated = await _pb.collection('messages').getList(
          filter: 'chatId = "$chatId"',
          sort: 'created',
          expand: 'senderId', // Mesajı gönderen bilgisini çek (opsiyonel)
        );
        if (!controller.isClosed) {
          controller.add(updated.items.map((item) {
            // Expand edilmiş göndericiyi Map'e çevir (Tekli ilişki)
            Map<String, dynamic>? expandedSender;
            try {
              final senderRecord = item.get<RecordModel>('expand.senderId');
              expandedSender = {'id': senderRecord.id, ...senderRecord.data};
            } catch (_) {}

            return {
              'id': item.id,
              ...item.data,
              'expanded_sender': expandedSender,
            };
          }).toList());
        }
      } catch (e) {
        // debugPrint(e.toString());
      }
    }

    // İlk yükleme
    fetchAndAdd();

    // Yeni mesajları dinle
    _pb.collection('messages').subscribe('*', (event) async {
      // Eğer bu chat için bir değişiklik ise veya herhangi bir mesaj ise (PB subscribe tüm tabloyu dinler bazen)
      // ChatId filtresi PocketBase tarafında subscribe opsiyonu olarak da verilebilir ama realtime API kısıtlı olabilir
      await fetchAndAdd();
    });

    controller.onCancel = () {
      _pb.collection('messages').unsubscribe('*');
      controller.close();
    };

    return controller.stream;
  }

  @override
  Future<void> sendMessage(String chatId, Map<String, dynamic> data) async {
    data['chatId'] = chatId;
    data['isRead'] = false;
    
    // Mesajı ekle
    await _pb.collection('messages').create(body: data);

    // Chat kaydını bul ve unread count'u güncelle
    final chatRecord = await _pb.collection('chats').getOne(chatId);
    final unreadCount = Map<String, dynamic>.from(chatRecord.data['unreadCount'] ?? {});
    final participants = List<String>.from(chatRecord.data['participants'] ?? []);
    
    // Gönderen dışındaki herkes için unread count artır
    for (final pId in participants) {
      if (pId != data['senderId']) {
        final currentCount = unreadCount[pId] ?? 0;
        unreadCount[pId] = currentCount + 1;
      }
    }

    // Chat'in lastMessage bilgisini ve unread count'u güncelle
    await _pb.collection('chats').update(chatId, body: {
      'lastMessage': data['content'],
      'lastMessageAt': DateTime.now().toIso8601String(),
      'lastMessageSenderId': data['senderId'],
      'unreadCount': unreadCount,
    });
  }

  @override
  Future<String> createChat(Map<String, dynamic> chatData) async {
    final record = await _pb.collection('chats').create(body: chatData);
    return record.id;
  }

  @override
  Future<void> markAsRead(String chatId, String userId) async {
    final record = await _pb.collection('chats').getOne(chatId);
    final unreadCount = Map<String, dynamic>.from(record.data['unreadCount'] ?? {});
    unreadCount[userId] = 0;
    
    await _pb.collection('chats').update(chatId, body: {
      'unreadCount': unreadCount,
    });
  }

  @override
  Future<void> updateTypingStatus(String chatId, String userId, bool isTyping) async {
    try {
      // Önce mevcut kaydı ara
      final result = await _pb.collection('typing_indicators').getList(
        filter: 'chatId = "$chatId" && userId = "$userId"',
      );

      if (result.items.isNotEmpty) {
        await _pb.collection('typing_indicators').update(result.items.first.id, body: {
          'isTyping': isTyping,
        });
      } else {
        await _pb.collection('typing_indicators').create(body: {
          'chatId': chatId,
          'userId': userId,
          'isTyping': isTyping,
        });
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }
}

// Interface tanımı aynı kaldı, sadece Firestore bağımlılığı kalktı
abstract class ChatRemoteDataSource {
  Stream<List<Map<String, dynamic>>> watchChats(String userId);
  Stream<List<Map<String, dynamic>>> watchMessages(String chatId);
  Future<void> sendMessage(String chatId, Map<String, dynamic> data);
  Future<String> createChat(Map<String, dynamic> chatData);
  Future<void> markAsRead(String chatId, String userId);
  Future<void> updateTypingStatus(String chatId, String userId, bool isTyping);
}
