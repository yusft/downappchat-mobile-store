import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/features/profile/presentation/providers/profile_provider.dart';
import 'package:downapp/app/theme/app_colors.dart';

class PrivacySettingsPage extends ConsumerWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Kullanıcı bulunamadı')));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20), 
          onPressed: () => context.pop()
        ),
        title: const Text('Gizlilik Ayarları'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16), 
        children: [
          SwitchListTile(
            title: const Text('Gizli Profil'), 
            subtitle: const Text('Sadece takipçileriniz profilinizi görebilir'), 
            value: user.isPrivate, 
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateUserSettings(
              userId: user.uid,
              isPrivate: v,
            ),
          ),
          SwitchListTile(
            title: const Text('Son Görülme'), 
            subtitle: const Text('Çevrimiçi durumunuzu gösterin'), 
            value: user.showLastSeen, 
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateUserSettings(
              userId: user.uid,
              showLastSeen: v,
            ),
          ),
          
          const Divider(height: 32),
          
          Text(
            'Mesaj İzinleri', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            )
          ),
          const SizedBox(height: 8),
          
          RadioListTile(
            title: const Text('Herkes'), 
            value: 'everyone', 
            // ignore: deprecated_member_use
            groupValue: user.allowMessages, 
            // ignore: deprecated_member_use
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateUserSettings(
              userId: user.uid,
              allowMessages: v,
            ),
          ),
          RadioListTile(
            title: const Text('Sadece Takipçiler'), 
            value: 'followers', 
            // ignore: deprecated_member_use
            groupValue: user.allowMessages, 
            // ignore: deprecated_member_use
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateUserSettings(
              userId: user.uid,
              allowMessages: v,
            ),
          ),
          RadioListTile(
            title: const Text('Kimse'), 
            value: 'nobody', 
            // ignore: deprecated_member_use
            groupValue: user.allowMessages, 
            // ignore: deprecated_member_use
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateUserSettings(
              userId: user.uid,
              allowMessages: v,
            ),
          ),
        ],
      ),
    );
  }
}

