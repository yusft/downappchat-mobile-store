import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/app/router.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';

/// Ayarlar ana sayfası
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(title: 'Hesap', children: [
            _SettingsTile(icon: Icons.person_outlined, title: 'Hesap Ayarları', subtitle: 'Email, şifre, kullanıcı adı', onTap: () => context.push(AppRoutes.accountSettings)),
            _SettingsTile(icon: Icons.lock_outlined, title: 'Gizlilik', subtitle: 'Profil gizliliği, mesaj izinleri', onTap: () => context.push(AppRoutes.privacySettings)),
            _SettingsTile(icon: Icons.notifications_outlined, title: 'Bildirimler', subtitle: 'Bildirim tercihleri', onTap: () => context.push(AppRoutes.notificationSettings)),
          ]),
          const SizedBox(height: 16),
          _SettingsSection(title: 'Uygulama', children: [
            _SettingsTile(icon: Icons.palette_outlined, title: 'Görünüm', subtitle: 'Tema, dil, veri tasarrufu', onTap: () => context.push(AppRoutes.appSettings)),
            _SettingsTile(icon: Icons.download_outlined, title: 'İndirme Geçmişi', onTap: () => context.push(AppRoutes.downloadHistory)),
            _SettingsTile(icon: Icons.code, title: 'Geliştirici Paneli', onTap: () => context.push(AppRoutes.developerPanel)),
          ]),
          const SizedBox(height: 16),
          _SettingsSection(title: 'Hakkında', children: [
            _SettingsTile(icon: Icons.feedback_outlined, title: 'Bize Ulaşın / Geri Bildirim', onTap: () => context.push(AppRoutes.feedback)),
            _SettingsTile(icon: Icons.description_outlined, title: 'Kullanım Koşulları', onTap: () => context.push(AppRoutes.terms)),
            _SettingsTile(icon: Icons.privacy_tip_outlined, title: 'Gizlilik Politikası', onTap: () => context.push(AppRoutes.privacy)),
            _SettingsTile(icon: Icons.info_outlined, title: 'Uygulama Versiyonu', subtitle: 'v1.0.0'),
          ]),
          const SizedBox(height: 24),
          // Çıkış yap
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Çıkış Yap'),
                    content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(authNotifierProvider.notifier).signOut();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('Çıkış Yap'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Çıkış Yap'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700, color: AppColors.primary,
        )),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle != null ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right, size: 20) : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
