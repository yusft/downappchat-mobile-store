import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/features/notifications/presentation/providers/notification_provider.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/features/profile/presentation/providers/profile_provider.dart';
import 'package:downapp/core/utils/formatters.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında tüm bildirimleri otomatik olarak okundu işaretle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(notificationNotifierProvider.notifier).markAllAsRead(user.uid).then((_) {
          ref.invalidate(notificationsProvider(user.uid));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bildirimler')),
        body: const Center(child: Text('Bildirimleri görmek için giriş yapmalısınız.')),
      );
    }

    final notificationsAsync = ref.watch(notificationsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Bildirimler'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationNotifierProvider.notifier).markAllAsRead(user.uid);
              ref.invalidate(notificationsProvider(user.uid));
            },
            child: const Text('Tümünü Oku'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64, color: theme.dividerColor),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz bildirim yok',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              final IconData icon = _getIconForType(n.type);
              final Color color = _getColorForType(n.type);

              return Container(
                color: n.isRead ? null : AppColors.primary.withValues(alpha: 0.05),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      title: Text(n.title, style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w600,
                      )),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.body, style: theme.textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Text(Formatters.formatTime(n.createdAt), 
                               style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                        ],
                      ),
                      onTap: () {
                        if (!n.isRead) {
                          ref.read(notificationNotifierProvider.notifier).markAsRead(n.notificationId);
                          ref.invalidate(notificationsProvider(user.uid));
                        }
                      },
                    ),
                    if (n.type == 'follow_request') 
                      Padding(
                        padding: const EdgeInsets.only(left: 72, bottom: 12, right: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final followId = n.data['followId'];
                                  final senderId = n.data['userId'];
                                  if (followId != null && senderId != null) {
                                    ref.read(profileNotifierProvider.notifier).respondToFollowRequest(
                                      followId: followId,
                                      currentUserId: user.uid,
                                      targetUserId: senderId,
                                      accept: true,
                                    );
                                    // Bildirimi okundu yap
                                    ref.read(notificationNotifierProvider.notifier).markAsRead(n.notificationId);
                                    // Listeyi yenile
                                    ref.invalidate(notificationsProvider(user.uid));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 36),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Kabul Et', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  final followId = n.data['followId'];
                                  final senderId = n.data['userId'];
                                  if (followId != null && senderId != null) {
                                    ref.read(profileNotifierProvider.notifier).respondToFollowRequest(
                                      followId: followId,
                                      currentUserId: user.uid,
                                      targetUserId: senderId,
                                      accept: false,
                                    );
                                    ref.read(notificationNotifierProvider.notifier).markAsRead(n.notificationId);
                                    // Listeyi yenile
                                    ref.invalidate(notificationsProvider(user.uid));
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 36),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Reddet', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ).animate().fadeIn(duration: 200.ms, delay: Duration(milliseconds: 40 * index));
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'follow':
      case 'follow_request':
      case 'follow_accepted': return Icons.person_add;
      case 'comment': return Icons.comment;
      case 'like': return Icons.favorite;
      case 'update': return Icons.update;
      case 'system': return Icons.info_outline;
      default: return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'follow': return AppColors.primary;
      case 'comment': return AppColors.accentGreen;
      case 'like': return AppColors.secondary;
      case 'update': return AppColors.accent;
      default: return AppColors.accentOrange;
    }
  }
}
