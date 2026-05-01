import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/features/profile/presentation/providers/profile_provider.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Kullanıcı bulunamadı')));
    }

    final settings = user.notificationSettings;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20), 
          onPressed: () => context.pop()
        ),
        title: const Text('Bildirim Ayarları'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16), 
        children: [
          SwitchListTile(
            title: const Text('Mesaj Bildirimleri'), 
            subtitle: const Text('Yeni mesajlar için bildirim alın'), 
            value: settings.messages, 
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateUserSettings(
              userId: user.uid,
              notificationSettings: settings.copyWith(messages: v),
            ),
          ),
          SwitchListTile(
            title: const Text('Yorum Bildirimleri'), 
            subtitle: const Text('Yorumlar ve yanıtlar'), 
            value: settings.comments, 
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateUserSettings(
              userId: user.uid,
              notificationSettings: settings.copyWith(comments: v),
            ),
          ),
          SwitchListTile(
            title: const Text('Takip Bildirimleri'), 
            subtitle: const Text('Yeni takipçiler'), 
            value: settings.follows, 
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateUserSettings(
              userId: user.uid,
              notificationSettings: settings.copyWith(follows: v),
            ),
          ),
          SwitchListTile(
            title: const Text('Güncelleme Bildirimleri'), 
            subtitle: const Text('Uygulama güncellemeleri'), 
            value: settings.updates, 
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateUserSettings(
              userId: user.uid,
              notificationSettings: settings.copyWith(updates: v),
            ),
          ),
        ],
      ),
    );
  }
}

