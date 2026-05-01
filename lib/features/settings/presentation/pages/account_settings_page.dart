import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:downapp/core/widgets/app_text_field.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/app/theme/app_colors.dart';

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20), 
          onPressed: () => context.pop()
        ),
        title: const Text('Hesap Ayarları'),
      ),
      body: user == null
          ? const Center(child: Text('Kullanıcı bulunamadı'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppTextField(
                  label: 'Email', 
                  hint: 'email@ornek.com', 
                  initialValue: user.email,
                  prefixIcon: Icons.email_outlined,
                  enabled: false,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Kullanıcı Adı', 
                  hint: 'kullanici_adi', 
                  initialValue: user.username,
                  prefixIcon: Icons.alternate_email,
                  enabled: false,
                ),
                const SizedBox(height: 24),
                
                const Divider(),
                const SizedBox(height: 24),
                
                Text(
                  'Güvenlik', 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  )
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: AppColors.primary),
                  title: const Text('Şifre Değiştir'),
                  subtitle: const Text('Şifrenizi sıfırlamak için bir e-posta gönderin'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ref.read(authNotifierProvider.notifier).resetPassword(user.email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Şifre sıfırlama e-postası gönderildi')),
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  'Tehlikeli Bölge', 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  )
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.error),
                  title: const Text('Hesabı Sil', style: TextStyle(color: AppColors.error)),
                  subtitle: const Text('Bu işlem geri alınamaz'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hesabı Sil'),
                        content: const Text('Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinir.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ref.read(authNotifierProvider.notifier).deleteAccount();
                              // Notifier state unauthenticated olduğunda router otomatik olarak login sayfasına yönlendirecektir
                            },
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                            child: const Text('Evet, Sil'),
                          ),
                        ],
                      ),
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.error, width: 0.5),
                  ),
                ),
              ],
            ),
    );
  }
}

