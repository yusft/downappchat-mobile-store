import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/app/di/providers.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/features/profile/presentation/providers/profile_provider.dart';

class AppSettingsPage extends ConsumerWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Kullanıcı bulunamadı')));
    }

    final preferences = user.preferences;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20), 
          onPressed: () => context.pop()
        ),
        title: const Text('Uygulama Ayarları'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16), 
        children: [
          Text('Tema', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...AppThemeMode.values.map((mode) => RadioListTile<AppThemeMode>(
            title: Text(switch (mode) {
              AppThemeMode.light => 'Aydınlık',
              AppThemeMode.dark => 'Karanlık',
              AppThemeMode.system => 'Sistem Varsayılanı',
            }),
            value: mode,
            // ignore: deprecated_member_use
            groupValue: themeMode,
            // ignore: deprecated_member_use
            onChanged: (v) {
              if (v == null) return;
              ref.read(themeModeProvider.notifier).state = v;
              ref.read(profileNotifierProvider.notifier).updateUserSettings(
                userId: user.uid,
                preferences: preferences.copyWith(theme: v.name),
              );
            },
          )),
          
          const Divider(height: 32),
          
          Text('Dil', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: const Text('Türkçe 🇹🇷'), 
            value: 'tr', 
            // ignore: deprecated_member_use
            groupValue: locale, 
            // ignore: deprecated_member_use
            onChanged: (v) {
              if (v == null) return;
              ref.read(localeProvider.notifier).state = v;
              ref.read(profileNotifierProvider.notifier).updateUserSettings(
                userId: user.uid,
                preferences: preferences.copyWith(language: v),
              );
            },
          ),
          RadioListTile<String>(
            title: const Text('English 🇬🇧'), 
            value: 'en', 
            // ignore: deprecated_member_use
            groupValue: locale, 
            // ignore: deprecated_member_use
            onChanged: (v) {
              if (v == null) return;
              ref.read(localeProvider.notifier).state = v;
              ref.read(profileNotifierProvider.notifier).updateUserSettings(
                userId: user.uid,
                preferences: preferences.copyWith(language: v),
              );
            },
          ),
          
          const Divider(height: 32),
          
          SwitchListTile(
            title: const Text('Veri Tasarruf Modu'), 
            subtitle: const Text('Düşük kalitede resimler yükle'), 
            value: preferences.dataSaver, 
            onChanged: (v) => ref.read(profileNotifierProvider.notifier).updateUserSettings(
              userId: user.uid,
              preferences: preferences.copyWith(dataSaver: v),
            ),
          ),
        ],
      ),
    );
  }
}

