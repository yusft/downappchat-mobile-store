import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/features/chat/presentation/providers/chat_provider.dart';
import 'package:downapp/features/chat/domain/entities/chat_entity.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/features/profile/presentation/providers/profile_provider.dart';
import 'package:downapp/app/di/providers.dart';

/// Mesajlaşma sayfası — PocketBase gerçek zamanlı chat
class ChatPage extends ConsumerStatefulWidget {
  final String chatId;
  const ChatPage({super.key, required this.chatId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _chatCreated = false;
  String? _activeChatId;

  @override
  void initState() {
    super.initState();
    _activeChatId = widget.chatId;
    _checkExistingChat();
    _markChatAsRead();
  }

  void _markChatAsRead() {
    if (_activeChatId != null && _activeChatId!.length == 15 && _chatCreated) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(chatNotifierProvider.notifier).markAsRead(
          chatId: _activeChatId!,
          userId: user.uid,
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _checkExistingChat() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _activeChatId == null) return;

    // Eğer _activeChatId bir userId ise (15 karakter ve harf/rakam), mevcut sohbeti ara
    // Eğer halihazırda bir sohbetin içindeysek (chatId gelmişse), aramaya gerek yok.
    // PocketBase ID'leri 15 karakter. Basit bir kontrol: 
    // Eğer chats koleksiyonunda bu ID ile bir kayıt varsa, bu bir chatId'dir.
    
    final pb = ref.read(pocketBaseProvider);
    
    try {
      // Önce bu bir chatId mi diye kontrol et
      try {
        await pb.collection('chats').getOne(_activeChatId!);
        setState(() {
          _chatCreated = true;
        });
        return; // Evet bir chatId, arama bitti.
      } catch (_) {
        // Chat kaydı bulunamadı, demek ki bu bir userId olabilir.
      }

      if (_activeChatId!.length == 15) {
        // İki katılımcının da olduğu sohbeti bul
        final result = await pb.collection('chats').getList(
          filter: 'participants ~ "${user.uid}" && participants ~ "$_activeChatId"',
          perPage: 1,
        );
        
        if (result.items.isNotEmpty) {
          setState(() {
            _activeChatId = result.items.first.id;
            _chatCreated = true;
          });
          _markChatAsRead(); // Sohbet bulunduğunda okundu yap
        }
      }
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    String chatId = _activeChatId!;
    
    // Eğer hala sohbet kurulmadıysa (ve elimizdeki bir userId ise) oluştur
    if (!_chatCreated && chatId.length == 15) {
      try {
        final newChatId = await ref.read(chatNotifierProvider.notifier).createChat(
          currentUserId: user.uid,
          targetUserId: chatId,
        );
        
        if (newChatId != null) {
          chatId = newChatId;
          setState(() {
            _activeChatId = newChatId;
            _chatCreated = true;
          });
          // Provider'ı yeni chatId ile yenilemek gerekebilir
          ref.invalidate(messagesStreamProvider(chatId));
        } else {
          throw Exception('Sohbet kimliği alınamadı');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sohbet oluşturulamadı: $e')),
          );
        }
        return;
      }
    }

    await ref.read(chatNotifierProvider.notifier).sendMessage(
      chatId: chatId,
      senderId: user.uid,
      content: content,
    );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final messagesAsync = ref.watch(messagesStreamProvider(_activeChatId!));
    final chat = ref.watch(singleChatProvider(_activeChatId!));
    
    // Mesajlar geldikçe okundu olarak işaretle (sohbet penceresi açıkken)
    ref.listen(messagesStreamProvider(_activeChatId!), (previous, next) {
      if (next.hasValue && next.value!.isNotEmpty) {
        _markChatAsRead();
      }
    });

    // Diğer katılımcı bilgisini bul (AppBar için)
    String otherUserId = '';
    String otherUserName = 'Sohbet';
    String otherAvatar = '';

    if (chat != null && user != null) {
      otherUserId = chat.participants.firstWhere((p) => p != user.uid, orElse: () => '');
      if (otherUserId.isNotEmpty) {
        final details = chat.participantDetails[otherUserId] as Map<String, dynamic>?;
        if (details != null) {
          otherUserName = details['displayName'] ?? details['username'] ?? 'Kullanıcı';
          otherAvatar = details['avatar'] ?? '';
        }
      }
    } else if (_activeChatId!.length == 15 && !_chatCreated) {
      // Eğer henüz chat yoksa ama bir userId'miz varsa (ilk mesaj durumu)
      otherUserId = _activeChatId!;
      final otherUserAsync = ref.watch(profileUserProvider(otherUserId));
      otherUserAsync.whenData((u) {
        otherUserName = u.displayName;
        otherAvatar = u.avatarUrl;
      });
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F13) : const Color(0xFFF8F9FE),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: GestureDetector(
          onTap: () {
            if (otherUserId.isNotEmpty) {
              context.push('/profile/$otherUserId');
            }
          },
          child: Row(
            children: [
              if (otherAvatar.isNotEmpty)
                CircleAvatar(radius: 18, backgroundImage: NetworkImage(otherAvatar))
              else
                CircleAvatar(
                  radius: 18, 
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, size: 18, color: AppColors.primary),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUserName, 
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Çevrimiçi',
                      style: theme.textTheme.labelSmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Mesajlar
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: theme.dividerColor),
                        const SizedBox(height: 16),
                        Text('Henüz mesaj yok', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                        const SizedBox(height: 8),
                        Text('İlk mesajı sen gönder! 💬', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  );
                }

                if (messages.isNotEmpty && !_chatCreated) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _chatCreated = true);
                  });
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == user?.uid;
                    return _MessageBubble(message: msg, isMe: isMe, isDark: isDark);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Mesajlar yüklenemedi: $err')),
            ),
          ),
          // Mesaj yazma alanı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A22).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : const Color(0xFFF1F4F9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 4,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Mesaj yaz...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final bool isDark;
  const _MessageBubble({required this.message, required this.isMe, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
              decoration: BoxDecoration(
                gradient: isMe ? AppColors.primaryGradient : null,
                color: isMe ? null : (isDark ? const Color(0xFF25252D) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isMe ? 0.15 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMe) ...[
                  Icon(Icons.done_all, size: 14, color: isDark ? Colors.grey : Colors.grey.shade400),
                  const SizedBox(width: 4),
                ],
                Text(
                  '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
