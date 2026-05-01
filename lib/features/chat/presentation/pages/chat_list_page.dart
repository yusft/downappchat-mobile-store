import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/core/widgets/app_avatar.dart';
import 'package:downapp/features/chat/presentation/providers/chat_provider.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/core/utils/formatters.dart';

/// Sohbet listesi sayfası — Gerçek veri entegrasyonu ile
class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mesajlar')),
        body: const Center(child: Text('Mesajları görmek için giriş yapmalısınız.')),
      );
    }

    final chatsAsync = ref.watch(chatsStreamProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Yeni sohbet başlatmak için bir kullanıcının profiline gidin.')),
            ),
          ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 64, color: theme.dividerColor),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz mesajın yok',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Arkadaşlarınla konuşmaya başlamak için\nprofillerini ziyaret et.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherId = chat.participants.firstWhere(
                (id) => id != user.uid,
                orElse: () => chat.participants.first,
              );
              final details = (chat.participantDetails[otherId] as Map<String, dynamic>?) ?? {};
              final displayName = details['name'] ?? details['displayName'] ?? 'Kullanıcı';
              final avatarUrl = details['avatar'] ?? details['avatarUrl'] ?? '';
              final hasUnread = (chat.unreadCount[user.uid] ?? 0) > 0;

              return ListTile(
                leading: AppAvatar(
                  size: 52,
                  imageUrl: avatarUrl,
                  showOnlineIndicator: true,
                  isOnline: false,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      Formatters.formatTime(chat.lastMessageTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: hasUnread ? AppColors.primary : null,
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    if (!hasUnread && chat.lastMessageSenderId == user.uid) ...[
                      const Icon(Icons.done_all, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (hasUnread)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${chat.unreadCount[user.uid]}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                onTap: () => context.push('/chat/${chat.chatId}'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ).animate().fadeIn(
                duration: 200.ms,
                delay: Duration(milliseconds: 40 * index),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}
